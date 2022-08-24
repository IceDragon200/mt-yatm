local list_concat = assert(foundation.com.list_concat)
local is_blank = assert(foundation.com.is_blank)
local FakeMetaRef = assert(foundation.com.FakeMetaRef)
local fspec = assert(foundation.com.formspec.api)

local mailbox_nodebox  = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.4375, 0.375, 0.25, 0.4375}, -- NodeBox1
    {-0.375, -0.5, -0.5, -0.3125, 0.25, -0.4375}, -- NodeBox2
    {0.3125, -0.5, -0.5, 0.375, 0.25, -0.4375}, -- NodeBox4
    {-0.3125, 0.1875, -0.5, 0.3125, 0.25, -0.4375}, -- NodeBox5
    {-0.3125, 0.1875, 0.4375, 0.3125, 0.25, 0.5}, -- NodeBox6
    {0.3125, -0.5, 0.4375, 0.375, 0.25, 0.5}, -- NodeBox7
    {-0.375, -0.5, 0.4375, -0.3125, 0.25, 0.5}, -- NodeBox8
  }
}

local function is_mailbox_open(pos)
  local meta = minetest.get_meta(pos)

  local lockable_pubkey = yatm_security.get_lockable_object_pubkey(meta)
  local chipped_pubkey = yatm_security.get_chipped_object_pubkey(meta)

  local is_open = true
  local inv = meta:get_inventory()

  if not is_blank(lockable_pubkey) then
    -- if the mailbox has no pubkey for either a physical lock or digital chip lock
    -- then it's open by default
    local key_stack = inv:get_stack("access_key", 1)
    is_open = yatm_security.is_stack_a_key_for_locked_node(key_stack, pos)
  end

  if not is_open then
    return false
  end

  if not is_blank(chipped_pubkey) then
    local card_stack = inv:get_stack("access_card", 1)
    is_open = yatm_security.is_stack_an_access_card_for_chipped_node(card_stack, pos)
  end

  return is_open
end

local function get_mailbox_formspec_id(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  return "yatm_mail:mailbox:" .. spos
end

local function mailbox_get_formspec(user, assigns)
  local pos = assigns.pos
  assigns.is_unlocked = is_mailbox_open(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  local meta = minetest.get_meta(pos)
  local cio = fspec.calc_inventory_offset

  local bg
  if nodedef.material_basename == "wood" then
    bg = "wood"
  elseif nodedef.material_basename == "metal" then
    bg = "default"
  end

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = bg }, function (slot, rect)
    if slot == "main_body" then
      local formspec =
        fspec.label(0, 0, "Mailbox")

      if yatm_security.is_lockable_node(pos) then
        -- if it's lockable, show the access key slot
        formspec =
          formspec ..
          fspec.list("nodemeta:"..spos, "access_key", rect.x, rect.y, 1, 1)
      end

      if yatm_security.is_chipped_node(pos) then
        -- if it's lockable, show the access key slot
        formspec =
          formspec ..
          fspec.list("nodemeta:"..spos, "access_card", rect.x + cio(1), rect.y, 1, 1)
      end

      formspec =
        formspec ..
        fspec.list("nodemeta:"..spos, "dropoff", rect.x + rect.w - cio(4), rect.y, 4, 1)

      if assigns.is_unlocked then
        formspec =
          formspec ..
          fspec.list("nodemeta:"..spos, "inbox", rect.x, rect.y + 2, 8, 2)

        if yatm_security.is_lockable_node(pos) then
          formspec =
            formspec ..
            "listring[nodemeta:" .. spos .. ";access_key]" ..
            "listring[current_player;main]"
        end

        if yatm_security.is_chipped_node(pos) then
          formspec =
            formspec ..
            "listring[nodemeta:" .. spos .. ";access_card]" ..
            "listring[current_player;main]"
        end

        formspec =
          formspec ..
          "listring[nodemeta:" .. spos .. ";inbox]" ..
          "listring[current_player;main]"
      end

      return formspec
    elseif slot == "footer" then
      return ""
    end
    return ""
  end)
end

local function mailbox_show_formspec(pos, user)
  local options = {
    state = {
      pos = pos,
    }
  }
  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    get_mailbox_formspec_id(pos),
    mailbox_get_formspec(user, options.state),
    options
  )
end

local function mailbox_on_rightclick(pos, _node, user, itemstack, _pointed_thing)
  mailbox_show_formspec(pos, user)
end

local function refresh_mailbox_formspec(pos, _user)
  --
  nokore.formspec_bindings:refresh_formspecs(get_mailbox_formspec_id(pos), function (player_name, state)
    local user = minetest.get_player_by_name(player_name)
    mailbox_show_formspec(state.pos, user)
  end)
end

local function mailbox_configure_inventory(_pos, meta)
  local inv = meta:get_inventory()

  inv:set_size("access_key", 1) -- slot used for the mailbox key, unless it's an open box
  inv:set_size("access_card", 1) -- slot used for the mailbox access card, unless it's an open box
  inv:set_size("dropoff", 4) -- dropoff will just transfer it to the inbox /shrug
  inv:set_size("inbox", 16)
end

local function mailbox_on_construct(pos)
  local meta = minetest.get_meta(pos)

  mailbox_configure_inventory(pos, meta)
end

local function mailbox_on_destruct(pos)
end

local function mailbox_on_dig(pos, node, digger)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  if inv:is_empty("access_key") and
     inv:is_empty("access_card") and
     inv:is_empty("dropoff") and
     inv:is_empty("inbox") then
    return minetest.node_dig(pos, node, digger)
  end

  return false
end

local function mailbox_allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  return 0
end

local function mailbox_allow_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "access_key" then
    if yatm_security.is_stack_lockable_toothed_key(stack) then
      return 1
    end
  elseif listname == "access_card" then
    if yatm_security.is_stack_access_card(stack) then
      return 1
    end
  else
    return stack:get_count()
  end
  return 0
end

local function mailbox_allow_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "access_key" then
    return stack:get_count()
  elseif listname == "access_card" then
    return stack:get_count()
  elseif listname == "inbox" then
    if is_mailbox_open(pos) then
      return stack:get_count()
    end
  elseif listname == "dropoff" then
    return stack:get_count()
  else
    return stack:get_count()
  end
  return 0
end

local function try_dropoff(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  local dropoff_list = inv:get_list("dropoff")

  for index,itemstack in ipairs(dropoff_list) do
    local leftover = inv:add_item("inbox", itemstack)

    inv:set_stack("dropoff", index, leftover)
  end
end

local function mailbox_on_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "access_key" or listname == "access_card" then
    local meta = minetest.get_meta(pos)
    refresh_mailbox_formspec(pos, player)
  elseif listname == "dropoff" then
    try_dropoff(pos)
  end
end

local function mailbox_on_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "access_key" or listname == "access_card" then
    local meta = minetest.get_meta(pos)
    refresh_mailbox_formspec(pos, player)
  end
end

local function mailbox_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = FakeMetaRef:new(old_meta_table)
  local new_meta = stack:get_meta()
  yatm_security.copy_lockable_object_pubkey(old_meta, new_meta)
  yatm_security.copy_chipped_object(old_meta, new_meta)

  new_meta:set_string("description", old_meta:get_string("description"))
  new_meta:set_string("box_title", old_meta:get_string("box_title"))
end

local function mailbox_after_place_node(pos, _placer, itemstack, _pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()

  yatm_security.copy_lockable_object_pubkey(assert(old_meta), new_meta)
  yatm_security.copy_chipped_object(assert(old_meta), new_meta)

  new_meta:set_string("description", old_meta:get_string("description"))
  new_meta:set_string("box_title", old_meta:get_string("box_title"))

  new_meta:set_string("infotext", new_meta:get_string("description"))
end

for _,row in ipairs(yatm.colors_with_default) do
  local basename = row.name
  local name = row.description

  local mailbox_basename = "yatm_mail:mailbox_wood_" .. basename
  minetest.register_node(mailbox_basename, {
    basename = "yatm_mail:mailbox_wood",
    base_description = yatm_mail.S("Wood Mailbox"),

    description = yatm_mail.S("Wood Mailbox [" .. name .. "]"),

    codex_entry_id = "yatm_mail:mailbox",

    material_basename = "wood",

    groups = {
      mailbox = 1,
      cracky = 1,
      lockable_object = 1,
      chippable_object = 1,
      item_interface_in = 1,
      item_interface_out = 1,
    },

    sounds = yatm.node_sounds:build("wood"),
    is_ground_content = false,
    tiles = {
      "yatm_mailbox_wood_" .. basename .. "_top.png",
      "yatm_mailbox_wood_" .. basename .. "_bottom.png",
      "yatm_mailbox_wood_" .. basename .. "_side.png",
      "yatm_mailbox_wood_" .. basename .. "_side.png^[transformFX",
      "yatm_mailbox_wood_" .. basename .. "_back.png",
      "yatm_mailbox_wood_" .. basename .. "_front.png"
    },
    use_texture_alpha = "opaque",

    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = mailbox_nodebox,

    on_construct = mailbox_on_construct,
    on_destruct = mailbox_on_destruct,
    on_dig = mailbox_on_dig,

    after_place_node = mailbox_after_place_node,

    allow_metadata_inventory_move = mailbox_allow_metadata_inventory_move,
    allow_metadata_inventory_put = mailbox_allow_metadata_inventory_put,
    allow_metadata_inventory_take = mailbox_allow_metadata_inventory_take,

    on_metadata_inventory_put = mailbox_on_metadata_inventory_put,
    on_metadata_inventory_take = mailbox_on_metadata_inventory_take,

    preserve_metadata = mailbox_preserve_metadata,

    on_rightclick = mailbox_on_rightclick,
  })

  local mailbox_basename = "yatm_mail:mailbox_metal_" .. basename
  minetest.register_node(mailbox_basename, {
    basename = "yatm_mail:mailbox_metal",
    base_description = yatm_mail.S("Metal Mailbox"),

    description = yatm_mail.S("Metal Mailbox [" .. name .. "]"),

    codex_entry_id = "yatm_mail:mailbox",

    material_basename = "metal",

    groups = {
      mailbox = 1,
      cracky = 1,
      chippable_object = 1,
      lockable_object = 1,
      item_interface_in = 1,
      item_interface_out = 1,
    },

    sounds = yatm.node_sounds:build("metal"),
    is_ground_content = false,
    tiles = {
      "yatm_mailbox_metal_" .. basename .. "_top.png",
      "yatm_mailbox_metal_" .. basename .. "_bottom.png",
      "yatm_mailbox_metal_" .. basename .. "_side.png",
      "yatm_mailbox_metal_" .. basename .. "_side.png^[transformFX",
      "yatm_mailbox_metal_" .. basename .. "_back.png",
      "yatm_mailbox_metal_" .. basename .. "_front.png"
    },
    use_texture_alpha = "opaque",

    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = mailbox_nodebox,

    on_construct = mailbox_on_construct,
    on_destruct = mailbox_on_destruct,
    on_dig = mailbox_on_dig,

    after_place_node = mailbox_after_place_node,

    allow_metadata_inventory_move = mailbox_allow_metadata_inventory_move,
    allow_metadata_inventory_put = mailbox_allow_metadata_inventory_put,
    allow_metadata_inventory_take = mailbox_allow_metadata_inventory_take,

    on_metadata_inventory_put = mailbox_on_metadata_inventory_put,
    on_metadata_inventory_take = mailbox_on_metadata_inventory_take,

    preserve_metadata = mailbox_preserve_metadata,

    on_rightclick = mailbox_on_rightclick,
  })
end
