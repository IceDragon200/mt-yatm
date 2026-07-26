local mod = assert(yatm_codex)

local sounds = assert(yatm.sounds)
local get_node = assert(tetra.get_node)

local function receive_codex_fields(user, form_name, fields, state)
  if fields.prev_page then
    state.page_id = ((state.page_id - 2) % state.page_count) + 1
  elseif fields.next_page then
    state.page_id = ((state.page_id) % state.page_count) + 1
  end

  if fields.demo then
    local item_stack = ItemStack("yatm_codex:codex_deploy")
    local meta = item_stack:get_meta()
    meta:set_string("codex_demo_id", fields.demo)
    local inv = user:get_inventory()
    inv:add_item("main", item_stack)
  end

  if fields.quit then
    sounds:play("action_close", { to_player = user:get_player_name() })
  end

  return true, yatm.codex.render_codex_entry_formspec(user, state)
end

local function show_codex_entry(user, domain_name, codex_entry_id, codex_entry, context)
  local state = {
    domain_name = domain_name,
    original_codex_entry_id = codex_entry_id,
    codex_entry = codex_entry,
    page_id = 1,
    page_count = #codex_entry.pages,
    context = context
  }
  local formspec = yatm.codex.render_codex_entry_formspec(user, state)
  local formspec_name = "yatm_codex:codex"

  local options = {
    state = state,
    on_receive_fields = receive_codex_fields
  }
  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    formspec_name,
    formspec,
    options
  )
end

local function on_codex_entry_not_found(domain_name, codex_entry_id, user)
  sounds:play("action_error", { to_player = user:get_player_name() })
  core.chat_send_player(user:get_player_name(), "Missing CODEX entry: " .. codex_entry_id)
end

local function on_codex_entry_unavailable(user)
  sounds:play("action_error", { to_player = user:get_player_name() })
  core.chat_send_player(user:get_player_name(), "CODEX entry unavailable")
end

local function maybe_show_codex_entry(
  domain_name,
  codex_entry_id,
  context,
  itemstack, user, pointed_thing
)
  if codex_entry_id then
    local codex_entry = yatm.codex.registry:get_entry(domain_name, codex_entry_id)
    if codex_entry then
      sounds:play("codex_entry", { to_player = user:get_player_name() })
      show_codex_entry(user, domain_name, codex_entry_id, codex_entry, context)
    else
      on_codex_entry_not_found(domain_name, codex_entry_id, user)
    end
  else
    on_codex_entry_unavailable(user)
  end
  return nil
end

local function on_use(itemstack, user, pointed_thing)
  print(dump(pointed_thing))
  if pointed_thing.type == "object" then
    local ref = pointed_thing.ref
    local ent = ref:get_luaentity()
    if ent then
      if ent.name == "__builtin:item" then
        -- __builtin:item  has special handling, we will unpack the entity
        local target_item_stack = ItemStack(ent.itemstring)
        local itemdef = target_item_stack:get_definition()

        return maybe_show_codex_entry(
          "items",
          itemdef and itemdef.codex_entry_id,
          { item_name = target_item_stack:get_name(), origin = "entity" },
          itemstack,
          user,
          pointed_thing
        )
      end

      if ent.codex_entry_id == false then
        -- Entity intentionally doesn't want to have a codex page
        on_codex_entry_unavailable(user)
      else
        return maybe_show_codex_entry(
          "entities",
          ent.codex_entry_id or ent.name,
          { item_name = ent.name, origin = "entity" },
          itemstack,
          user,
          pointed_thing
        )
      end
    end
  elseif pointed_thing.type == "node" then
    -- when pointing at something, pull up the associated codex entry for that item
    local pos = pointed_thing.under

    if pos then
      local node = get_node(pos)
      local nodedef = core.registered_nodes[node.name]

      return maybe_show_codex_entry(
        "items",
        nodedef and nodedef.codex_entry_id,
        { item_name = node.name, origin = "node" },
        itemstack,
        user,
        pointed_thing
      )
    end
  end

  sounds:play("action_error", { to_player = user:get_player_name() })
  core.chat_send_player(user:get_player_name(), "Not a valid target")
  return nil
end

local function on_place(itemstack, user, pointed_thing)
  core.chat_send_player(user:get_player_name(), "No CODEX demo set")
  return nil
end

local function on_secondary_use(itemstack, user, pointed_thing)
  if user and core.is_player(user) then
    local options = {
      state = {}
    }
    nokore.formspec_bindings:show_formspec(
      user:get_player_name(),
      mod:make_name("codex"),
      yatm.codex.render_wiki_formspec(user, options.state),
      options
    )
  end
  return nil
end

local function construct_demo(user, pos, demo, itemstack, pointed_thing)
  local assigns = demo:init(pos)
  demo:build(pos, assigns)
  demo:configure(pos, assigns)
  demo:finalize(pos, assigns)

  core.chat_send_player(user:get_player_name(), "Demo placed!")
  return true
end

core.register_tool("yatm_codex:codex", {
  short_description = mod.S("CODEX"),
  description = mod.S("CODEX\nLeft-Click to check information on a node if available"),

  codex_entry_id = "yatm_codex:codex",

  groups = {
    codex = 1,
  },

  inventory_image = "yatm_codex.png",

  on_use = on_use,

  on_place = on_place,

  on_secondary_use = on_secondary_use,
})

core.register_tool("yatm_codex:codex_deploy", {
  short_description = mod.S("CODEX [Deployment Mode]"),
  description = mod.S("CODEX [Deployment Mode]") .. "\n"
    .. "Left-Click to check information on a node if available\nRight-Click to place demo",

  codex_entry_id = "yatm_codex:codex_deploy",

  groups = {
    codex = 1,
    codex_mode_deploy = 1,
    not_in_creative_inventory = 1,
  },

  inventory_image = "yatm_codex_deploy.png",

  on_use = on_use,

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
        core.chat_send_player(user:get_player_name(), "Not enough space for demo")
        return itemstack
      end
    else
      core.chat_send_player(user:get_player_name(), "Invalid CODEX demo set")
      return ItemStack("yatm_codex:codex")
    end
  end,

  on_secondary_use = on_secondary_use,
})
