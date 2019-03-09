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

--[[
  return "size[8,8.5]"..
    "list[context;src;2.75,0.5;1,1;]"..
    "list[context;fuel;2.75,2.5;1,1;]"..
    "image[2.75,1.5;1,1;default_furnace_fire_bg.png^[lowpart:"..
    (100-fuel_percent)..":default_furnace_fire_fg.png]"..
    "image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
    (item_percent)..":gui_furnace_arrow_fg.png^[transformR270]"..
    "list[context;dst;4.75,0.96;2,2;]"..
    "list[current_player;main;0,4.25;8,1;]"..
    "list[current_player;main;0,5.5;8,3;8]"..
    "listring[context;dst]"..
    "listring[current_player;main]"..
    "listring[context;src]"..
    "listring[current_player;main]"..
    "listring[context;fuel]"..
    "listring[current_player;main]"..
    default.get_hotbar_bg(0, 4.25)
]]

local closed_mailbox_form = yatm_core.UI.Form.new()
closed_mailbox_form:set_size(8, 8.5)
closed_mailbox_form:new_label(0, 0, "Mailbox")
closed_mailbox_form:new_list("context", "access_key", 0, 0.5, 1, 1, "")
closed_mailbox_form:new_list("context", "dropoff", 2, 0.5, 4, 1, "")
closed_mailbox_form:new_list("current_player", "main", 0, 4.25, 8, 1, "")
closed_mailbox_form:new_list("current_player", "main", 0, 5.5, 8, 3, 8)
closed_mailbox_form:new_list_ring("context", "access_key")
closed_mailbox_form:new_list_ring("current_player", "main")
closed_mailbox_form:new_list_ring("context", "dropoff")
closed_mailbox_form:new_list_ring("current_player", "main")

local opened_mailbox_form = yatm_core.UI.Form.new()
opened_mailbox_form:set_size(8, 8.5)
opened_mailbox_form:new_label(0, 0, "Mailbox")
opened_mailbox_form:new_list("context", "access_key", 0, 0.5, 1, 1, "")
opened_mailbox_form:new_list("context", "dropoff", 2, 0.5, 4, 1, "")
opened_mailbox_form:new_list("context", "inbox", 0, 2.0, 8, 2, "")
opened_mailbox_form:new_list("current_player", "main", 0, 4.25, 8, 1, "")
opened_mailbox_form:new_list("current_player", "main", 0, 5.5, 8, 3, 8)
opened_mailbox_form:new_list_ring("context", "access_key")
opened_mailbox_form:new_list_ring("current_player", "main")
opened_mailbox_form:new_list_ring("context", "dropoff")
opened_mailbox_form:new_list_ring("current_player", "main")
opened_mailbox_form:new_list_ring("context", "inbox")
opened_mailbox_form:new_list_ring("current_player", "main")

local function mailbox_get_formspec(is_full)
  local formspec = ""
  if is_full then
    formspec = opened_mailbox_form:to_formspec()
  else
    formspec = closed_mailbox_form:to_formspec()
  end

  formspec =
    default.gui_bg ..
    default.gui_bg_img ..
    default.gui_slots ..
    formspec ..
    default.get_hotbar_bg(0, 4.25)
  return formspec
end

local function mailbox_configure_inventory(_pos, meta)
  local inv = meta:get_inventory()

  inv:set_size("access_key", 1) -- slot used for the mailbox key, unless it's an open box
  inv:set_size("dropoff", 4) -- dropoff will just transfer it to the inbox /shrug
  inv:set_size("inbox", 16)
end

local function is_mailbox_open(pos)
  local meta = minetest.get_meta(pos)

  local pubkey = yatm_mail.get_lockable_key_key(meta)
  if yatm_core.is_blank(pubkey) then
    -- if the mailbox has no pubkey then it's open by default
    return true
  else
    local inv = meta:get_inventory()

    local key_stack = inv:get_stack("access_key", 1)
    local is_open = yatm_mail.is_stack_a_key_for_locked_node(key_stack, pos)
    print("mailbox is open?", yatm_core.vec3_to_string(pos), is_open)
    return is_open
  end
end

local function mailbox_configure_formspec(pos, meta)
  meta:set_string("formspec", mailbox_get_formspec(is_mailbox_open(pos)))
end

local function mailbox_on_construct(pos)
  local meta = minetest.get_meta(pos)

  mailbox_configure_formspec(pos, meta)
  mailbox_configure_inventory(pos, meta)
end

local function mailbox_on_destruct(pos)
end

local function mailbox_allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  return 0
end

local function mailbox_allow_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "access_key" then
    if yatm_mail.is_stack_lockable_toothed_key(stack) then
      return 1
    end
  else
    return stack:get_count()
  end
  return 0
end

local function mailbox_allow_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "access_key" then
    return 1
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
  if listname == "access_key" then
    local meta = minetest.get_meta(pos)
    mailbox_configure_formspec(pos, meta)
  elseif listname == "dropoff" then
    try_dropoff(pos)
  end
end

local function mailbox_on_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "access_key" then
    local meta = minetest.get_meta(pos)
    mailbox_configure_formspec(pos, meta)
  end
end

local function mailbox_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = yatm_core.FakeMetaRef.new(old_meta_table)
  local new_meta = stack:get_meta()
  yatm_mail.copy_lockable_object_key(old_meta, new_meta)
  new_meta:set_string(old_meta:get_string("description"))
  new_meta:set_string(old_meta:get_string("box_title"))
end

local function mailbox_after_place_node(pos, _placer, itemstack, _pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()

  yatm_mail.copy_lockable_object_key(assert(old_meta), new_meta)
  new_meta:set_string(old_meta:get_string("description"))
  new_meta:set_string(old_meta:get_string("box_title"))
end

for _,pair in ipairs(colors) do
  local basename = pair[1]
  local name = pair[2]

  local mailbox_basename = "yatm_mail:mailbox_wood_" .. basename
  minetest.register_node(mailbox_basename, {
    description = "Wood Mailbox (" .. name .. ")",
    groups = { mailbox = 1, cracky = 1, lockable_object = 1 },
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
    description = "Metal Mailbox (" .. name .. ")",
    groups = { mailbox = 1, cracky = 1, lockable_object = 1 },
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

    after_place_node = mailbox_after_place_node,


    allow_metadata_inventory_move = mailbox_allow_metadata_inventory_move,
    allow_metadata_inventory_put = mailbox_allow_metadata_inventory_put,
    allow_metadata_inventory_take = mailbox_allow_metadata_inventory_take,

    on_metadata_inventory_put = mailbox_on_metadata_inventory_put,
    on_metadata_inventory_take = mailbox_on_metadata_inventory_take,

    preserve_metadata = mailbox_preserve_metadata,
  })
end
