--
-- Packages can be used to store items, they are however not item interface compatible.
-- In addition they can be adorned with a ribbon and sealed to prevent anyone except the recipient
-- from opening it.
--
function get_package_formspec(pos)
  local meta = minetest.get_meta(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  local formspec =
    "size[8,9]" ..
    yatm.bg.wood ..
    "label[0,0;Package]" ..
    "list[nodemeta:" .. spos .. ";main;0,0.5;3,3;]" ..
    "field[4,1;4,1;addressed_from;From;" .. meta:get_string("addressed_from") .. "]" ..
    "field[4,3;4,1;addressed_to;To;" .. meta:get_string("addressed_to") .. "]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";main]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)

  return formspec
end

local package_nodebox = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new(1, 0, 1, 14, 8, 14):fast_node_box(),
  },
}

local function package_on_construct(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  inv:set_size("main", 9)

  meta:set_string("addressed_from", "")
  meta:set_string("addressed_to", "")
end

local function package_after_place_node(pos, placer, item_stack, pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = item_stack:get_meta()

  new_meta:set_string("addressed_to", old_meta:get_string("addressed_to"))
  new_meta:set_string("addressed_from", old_meta:get_string("addressed_from"))

  local new_inv = new_meta:get_inventory()

  local old_inv_list = old_meta:get_string("inventory_dump")
  if not yatm_core.is_blank(old_inv_list) then
    local dumped = minetest.deserialize(old_inv_list)
    local list = new_inv:get_list("main")
    list = yatm_item_storage.InventorySerializer.deserialize(dumped, list)
    new_inv:set_list("main", list)
  end
end

local function package_preserve_metadata(pos, _old_node, _old_meta_table, drops)
  local stack = drops[1]

  local old_meta = minetest.get_meta(pos)
  local new_meta = stack:get_meta()

  local old_inv = old_meta:get_inventory()
  local list = old_inv:get_list("main")

  local dumped = yatm_item_storage.InventorySerializer.serialize(list)

  --print("preserve_metadata", dump(dumped))
  new_meta:set_string("addressed_to", old_meta:get_string("addressed_to"))
  new_meta:set_string("addressed_from", old_meta:get_string("addressed_from"))
  new_meta:set_string("inventory_dump", minetest.serialize(dumped))
  local description = "Package (to: " .. old_meta:get_string("addressed_to") .. ", from: " .. old_meta:get_string("addressed_from") .. ")"
  new_meta:set_string("description", description)
end

local function package_on_receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)

  if fields["addressed_from"] then
    meta:set_string("addressed_from", fields["addressed_from"])
  end

  if fields["addressed_to"] then
    meta:set_string("addressed_to", fields["addressed_to"])
  end

  return true
end

local function package_on_rightclick(pos, node, clicker)
  local formspec_name = "yatm_mail:package_formspec:" .. minetest.pos_to_string(pos)
  yatm_core.bind_on_player_receive_fields(clicker, formspec_name,
                                          { pos = pos, node = node },
                                          package_on_receive_fields)
  minetest.show_formspec(
    clicker:get_player_name(),
    formspec_name,
    get_package_formspec(pos)
  )
end

-- Plain package
minetest.register_node("yatm_mail:package", {
  basename = "yatm_mail:package",
  description = "Package",

  groups = {
    cracky = 1,
    package = 1,
  },

  stack_max = 1,

  tiles = {
    "yatm_package_plain_top.png",
    "yatm_package_plain_bottom.png",
    "yatm_package_plain_side.png",
    "yatm_package_plain_side.png",
    "yatm_package_plain_side.png",
    "yatm_package_plain_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = package_nodebox,

  on_construct = package_on_construct,
  after_place_node = package_after_place_node,
  preserve_metadata = package_preserve_metadata,
  on_rightclick = package_on_rightclick,
})

local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

-- Packages with Ribbons!
for _,color_pair in ipairs(colors) do
  color_basename = color_pair[1]
  color_name = color_pair[2]

  minetest.register_node("yatm_mail:package_with_ribbon_" .. color_basename, {
    basename = "yatm_mail:package_with_ribbon",
    description = "Package (" .. color_name .. " Ribbon)",

    groups = {
      cracky = 1,
      package = 1,
      package_with_ribbon = 1,
    },

    stack_max = 1,

    tiles = {
      "yatm_package_" .. color_basename .. "_top.ribbon.png",
      "yatm_package_" .. color_basename .. "_bottom.ribbon.png",
      "yatm_package_" .. color_basename .. "_side.ribbon.png",
      "yatm_package_" .. color_basename .. "_side.ribbon.png",
      "yatm_package_" .. color_basename .. "_side.ribbon.png",
      "yatm_package_" .. color_basename .. "_side.ribbon.png",
    },

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = package_nodebox,

    on_construct = package_on_construct,
    after_place_node = package_after_place_node,
    preserve_metadata = package_preserve_metadata,
    on_rightclick = package_on_rightclick,
  })
end
