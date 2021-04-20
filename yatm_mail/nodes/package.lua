--
-- Packages can be used to store items, they are however not item interface compatible.
-- In addition they can be adorned with a ribbon and sealed to prevent anyone except the recipient
-- from opening it.
--
local Cuboid = assert(foundation.com.Cuboid)
local is_blank = assert(foundation.com.is_blank)
local fspec = assert(foundation.com.formspec.api)

function get_package_formspec(pos, entity)
  local meta = minetest.get_meta(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  local w = yatm.get_player_hotbar_size(entity)
  local h = 10

  local formspec =
    fspec.size(w, h) ..
    yatm.formspec_bg_for_player(entity:get_player_name(), "wood") ..
    "label[0,0;Package]" ..
    "list[nodemeta:" .. spos .. ";main;0,0.5;3,3;]" ..
    fspec.field_area(4, 1, w - 4, 1, "addressed_from", "From", meta:get_string("addressed_from")) ..
    fspec.field_area(4, 3, w - 4, 1, "addressed_to", "To", meta:get_string("addressed_to")) ..
    yatm.player_inventory_lists_fragment(entity, 0, 5.85) ..
    "listring[nodemeta:" .. spos .. ";main]" ..
    "listring[current_player;main]"

  return formspec
end

local package_nodebox = {
  type = "fixed",
  fixed = {
    Cuboid.new_fast_node_box(1, 0, 1, 14, 8, 14),
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
  if not is_blank(old_inv_list) then
    local dumped = minetest.deserialize(old_inv_list)
    local list = new_inv:get_list("main")
    list = yatm.items.InventorySerializer.deserialize_list(dumped, list)
    new_inv:set_list("main", list)
  end
end

local function package_preserve_metadata(pos, _old_node, _old_meta_table, drops)
  local stack = drops[1]

  local old_meta = minetest.get_meta(pos)
  local new_meta = stack:get_meta()

  local old_inv = old_meta:get_inventory()
  local list = old_inv:get_list("main")

  local dumped = yatm.items.InventorySerializer.serialize(list)

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

local function package_on_rightclick(pos, node, user)
  local formspec_name = "yatm_mail:package_formspec:" .. minetest.pos_to_string(pos)
  local assigns = { pos = pos, node = node }
  local formspec = get_package_formspec(pos, user)

  yatm_core.show_bound_formspec(user:get_player_name(), formspec_name, formspec, {
    state = assigns,
    on_receive_fields = package_on_receive_fields
  })
end

-- Plain package
minetest.register_node("yatm_mail:package", {
  basename = "yatm_mail:package",
  description = yatm_mail.S("Package"),

  codex_entry_id = "yatm_mail:package",

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
  use_texture_alpha = "opaque",

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = package_nodebox,

  on_construct = package_on_construct,
  after_place_node = package_after_place_node,
  preserve_metadata = package_preserve_metadata,
  on_rightclick = package_on_rightclick,
})

-- Packages with Ribbons!
for _,row in ipairs(yatm.colors) do
  local basename = row.name
  local name = row.description

  minetest.register_node("yatm_mail:package_with_ribbon_" .. basename, {
    basename = "yatm_mail:package_with_ribbon",

    base_description = yatm_mail.S("Package (Ribbon)"),
    description = yatm_mail.S("Package (" .. name .. " Ribbon)"),

    codex_entry_id = "yatm_mail:package",

    groups = {
      cracky = 1,
      package = 1,
      package_with_ribbon = 1,
    },

    stack_max = 1,

    tiles = {
      "yatm_package_" .. basename .. "_top.ribbon.png",
      "yatm_package_" .. basename .. "_bottom.ribbon.png",
      "yatm_package_" .. basename .. "_side.ribbon.png",
      "yatm_package_" .. basename .. "_side.ribbon.png",
      "yatm_package_" .. basename .. "_side.ribbon.png",
      "yatm_package_" .. basename .. "_side.ribbon.png",
    },
    use_texture_alpha = "opaque",

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
