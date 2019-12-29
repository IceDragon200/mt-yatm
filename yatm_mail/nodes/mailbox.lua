local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

colors = yatm_core.list_concat({{"default", "Default"}}, colors)

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

local function mailbox_get_formspec(pos, is_unlocked)
  local meta = minetest.get_meta(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  local bg
  if nodedef.material_basename == "wood" then
    bg = yatm.bg.wood
  elseif nodedef.material_basename == "metal" then
    bg = yatm.bg.default
  end

  local formspec =
    "size[8,9]" ..
    bg ..
    "label[0,0;Mailbox]"

  if yatm_security.is_lockable_node(pos) then
    -- if it's lockable, show the access key slot
    formspec =
      formspec ..
      "list[nodemeta:" .. spos .. ";access_key;0,0.5;1,1;]"
  end

  if yatm_security.is_chipped_node(pos) then
    -- if it's lockable, show the access key slot
    formspec =
      formspec ..
      "list[nodemeta:" .. spos .. ";access_card;1.5,0.5;1,1;]"
  end

  formspec =
    formspec ..
    "list[nodemeta:" .. spos .. ";dropoff;3,0.5;4,1;]" ..
    "listring[nodemeta:" .. spos .. ";dropoff]" ..
    "listring[current_player;main]"

  if is_unlocked then
    formspec =
      formspec ..
      "list[nodemeta:" .. spos .. ";inbox;0,2.0;8,2;]"

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

  formspec =
    formspec ..
    "list[current_player;main;0,5.85;8,1;]" ..
    "list[current_player;main;0,7.08;8,3;8]" ..
    default.get_hotbar_bg(0, 5.85)

  return formspec
end

local function mailbox_configure_inventory(_pos, meta)
  local inv = meta:get_inventory()

  inv:set_size("access_key", 1) -- slot used for the mailbox key, unless it's an open box
  inv:set_size("access_card", 1) -- slot used for the mailbox access card, unless it's an open box
  inv:set_size("dropoff", 4) -- dropoff will just transfer it to the inbox /shrug
  inv:set_size("inbox", 16)
end

local function is_mailbox_open(pos)
  local meta = minetest.get_meta(pos)

  local lockable_pubkey = yatm_security.get_lockable_object_pubkey(meta)
  local chipped_pubkey = yatm_security.get_chipped_object_pubkey(meta)

  local is_open = true
  local inv = meta:get_inventory()

  if not yatm_core.is_blank(lockable_pubkey) then
    -- if the mailbox has no pubkey for either a physical lock or digital chip lock
    -- then it's open by default
    local key_stack = inv:get_stack("access_key", 1)
    is_open = yatm_security.is_stack_a_key_for_locked_node(key_stack, pos)
  end

  if not is_open then
    return false
  end

  if not yatm_core.is_blank(chipped_pubkey) then
    local card_stack = inv:get_stack("access_card", 1)
    is_open = yatm_security.is_stack_an_access_card_for_chipped_node(card_stack, pos)
  end

  return is_open
end

local function mailbox_configure_formspec(pos, meta)
  meta:set_string("formspec", mailbox_get_formspec(pos, is_mailbox_open(pos)))
end

local function mailbox_on_construct(pos)
  local meta = minetest.get_meta(pos)

  mailbox_configure_formspec(pos, meta)
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
    mailbox_configure_formspec(pos, meta)
  elseif listname == "dropoff" then
    try_dropoff(pos)
  end
end

local function mailbox_on_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "access_key" or listname == "access_card" then
    local meta = minetest.get_meta(pos)
    mailbox_configure_formspec(pos, meta)
  end
end

local function mailbox_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = yatm_core.FakeMetaRef:new(old_meta_table)
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

  mailbox_configure_formspec(pos, new_meta)
end

for _,pair in ipairs(colors) do
  local basename = pair[1]
  local name = pair[2]

  local mailbox_basename = "yatm_mail:mailbox_wood_" .. basename
  minetest.register_node(mailbox_basename, {
    basename = "yatm_mail:mailbox_wood",
    base_description = "Wood Mailbox",

    description = "Wood Mailbox [" .. name .. "]",

    codex_entry_id = "yatm_mail:mailbox",

    material_basename = "metal",

    groups = {
      mailbox = 1,
      cracky = 1,
      lockable_object = 1,
      chippable_object = 1,
      item_interface_in = 1,
      item_interface_out = 1,
    },

    sounds = default.node_sound_wood_defaults(),
    is_ground_content = false,
    tiles = {
      "yatm_mailbox_wood_" .. basename .. "_top.png",
      "yatm_mailbox_wood_" .. basename .. "_bottom.png",
      "yatm_mailbox_wood_" .. basename .. "_side.png",
      "yatm_mailbox_wood_" .. basename .. "_side.png^[transformFX",
      "yatm_mailbox_wood_" .. basename .. "_back.png",
      "yatm_mailbox_wood_" .. basename .. "_front.png"
    },
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
  })

  local mailbox_basename = "yatm_mail:mailbox_metal_" .. basename
  minetest.register_node(mailbox_basename, {
    basename = "yatm_mail:mailbox_metal",
    base_description = "Metal Mailbox",

    description = "Metal Mailbox [" .. name .. "]",

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

    sounds = default.node_sound_metal_defaults(),
    is_ground_content = false,
    tiles = {
      "yatm_mailbox_metal_" .. basename .. "_top.png",
      "yatm_mailbox_metal_" .. basename .. "_bottom.png",
      "yatm_mailbox_metal_" .. basename .. "_side.png",
      "yatm_mailbox_metal_" .. basename .. "_side.png^[transformFX",
      "yatm_mailbox_metal_" .. basename .. "_back.png",
      "yatm_mailbox_metal_" .. basename .. "_front.png"
    },
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
  })
end
