local function get_codex_entry_formspec(user, assigns)
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "codex")

  local page = assert(assigns.codex_entry.pages[assigns.page_id])

  if page.heading_item then
    local item_name
    local ty = type(page.heading_item)
    if ty == "table" then
      if page.heading_item.context then
        item_name = assigns.context.item_name
      end

      if not item_name then
        item_name = page.heading_item.default
      end
    elseif ty == "string" then
      item_name = page.heading_item
    else
      item_name = "air"
    end

    formspec =
      formspec ..
      -- For the love of code, WTF, last time I put the grid before it, it appeared above it!
      -- this gives the illusion of a grid around the item
      "item_image[0,0;1.5,1.5;yatm_core:grid_block]" ..
      "item_image[0,0;1.5,1.5;" .. item_name .. "]" ..
      ""
  end

  if page.heading then
    if page.heading_item then
      formspec =
        formspec ..
        "label[1.5,0.5;" .. page.heading .. "]"
    else
      formspec =
        formspec ..
        "label[0,0.5;" .. page.heading .. "]"
    end
  end

  local y = 0.5

  local dy = y
  if page.lines then
    for i, line in ipairs(page.lines) do
      dy = y + (i - 1) * 0.2
      formspec =
        formspec ..
        -- 0.125 vertical spacing is a bit too compact
        -- 0.2 the sweet spot
        -- 0.25 vertical spacing has adequate spacing, but can only fit 16 lines
        -- But in all honestly it's like the inventory based sizing doesn't even apply to hypertext...
        "hypertext[0.125," .. dy .. ";8,1;line" .. i .. ";" .. minetest.formspec_escape(line) .. "]"
    end
  end

  if page.demos then
    y = dy
    for i, demo_name in ipairs(page.demos) do
      dy = y + (i) * 0.2
      formspec =
        formspec ..
        "button[0.125," .. dy .. ";8,1;demo;" .. minetest.formspec_escape(demo_name) .. "]"
    end
  end

  if assigns.page_count > 1 then
    if assigns.page_id > 1 then
      formspec =
        formspec ..
        "button[0,8;2,1;prev_page;<]"
    end

    if assigns.page_id < assigns.page_count then
      formspec =
        formspec ..
        "button[6,8;2,1;next_page;>]"
    end
  end

  return formspec
end

local function receive_codex_fields(user, form_name, fields, assigns)
  if fields.prev_page then
    assigns.page_id = ((assigns.page_id - 2) % assigns.page_count) + 1
  elseif fields.next_page then
    assigns.page_id = ((assigns.page_id) % assigns.page_count) + 1
  end

  if fields.demo then
    local item_stack = ItemStack("yatm_codex:codex_deploy")
    local meta = item_stack:get_meta()
    meta:set_string("codex_demo_id", fields.demo)
    local inv = user:get_inventory()
    inv:add_item("main", item_stack)
  end

  return true, get_codex_entry_formspec(user, assigns)
end

local function show_codex_entry(user, codex_entry_id, codex_entry, context)
  local assigns = { original_codex_entry_id = codex_entry_id,
                    codex_entry = codex_entry,
                    page_id = 1,
                    page_count = #codex_entry.pages,
                    context = context }
  local formspec = get_codex_entry_formspec(user, assigns)
  local formspec_name = "yatm_codex:codex"

  yatm_core.bind_on_player_receive_fields(user, formspec_name,
                                          assigns,
                                          receive_codex_fields)

  minetest.show_formspec(user:get_player_name(), formspec_name, formspec)
end

local function on_use_codex(itemstack, user, pointed_thing)
  -- when pointing at something, pull up the associated codex entry for that item
  local pos = pointed_thing.under

  if pos then
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]

    local codex_entry
    local codex_entry_id
    if nodedef then
      codex_entry_id = nodedef.codex_entry_id
      if codex_entry_id then
        codex_entry = yatm.codex.get_entry(codex_entry_id)
      end
    end

    if codex_entry then
      show_codex_entry(user, codex_entry_id, codex_entry, { item_name = node.name })
    else
      if codex_entry_id then
        minetest.chat_send_player(user:get_player_name(), "Missing CODEX entry: " .. codex_entry_id)
      else
        minetest.chat_send_player(user:get_player_name(), "No CODEX entry available")
      end
    end
  else
    minetest.chat_send_player(user:get_player_name(), "Not a valid target")
  end
end

local function construct_demo(user, pos, demo, itemstack, pointed_thing)
  local assigns = demo:init(pos)
  demo:build(pos, assigns)
  demo:configure(pos, assigns)
  demo:finalize(pos, assigns)

  minetest.chat_send_player(user:get_player_name(), "Demo placed!")
  return true
end

minetest.register_tool("yatm_codex:codex", {
  description = "CODEX",

  groups = {
    codex = 1,
  },

  inventory_image = "yatm_codex.png",

  on_use = on_use_codex,

  on_place = function (itemstack, user, pointed_thing)
    minetest.chat_send_player(user:get_player_name(), "No CODEX demo set")
    return itemstack
  end,
})

minetest.register_tool("yatm_codex:codex_deploy", {
  description = "CODEX [Deployment Mode]",

  groups = {
    codex = 1,
    not_in_creative_inventory = 1,
  },

  inventory_image = "yatm_codex_deploy.png",

  on_use = on_use_codex,

  on_place = function (itemstack, user, pointed_thing)
    local meta = itemstack:get_meta()
    local demo = yatm.codex.get_demo(meta:get_string("codex_demo_id"))
    if demo then
      local pos = pointed_thing.above
      if demo:check_space(pos) then
        construct_demo(user, pos, demo, itemstack, pointed_thing)
        --return ItemStack("yatm_codex:codex")
        return itemstack
      else
        minetest.chat_send_player(user:get_player_name(), "Not enough space for demo")
        return itemstack
      end
    else
      minetest.chat_send_player(user:get_player_name(), "Invalid CODEX demo set")
      return ItemStack("yatm_codex:codex")
    end
  end,
})
