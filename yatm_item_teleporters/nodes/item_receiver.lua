--[[
Item Teleporters behave slightly different from ducts, they will have a 1-frame delay since they will
take items into their internal inventory, and then teleport them to a connected teleporter.

Like all other wireless devices, it has it's own address scheme and registration process.
]]
local SpacetimeNetwork = assert(yatm.spacetime.Network)
local SpacetimeMeta = assert(yatm.spacetime.SpacetimeMeta)

local function teleporter_after_place_node(pos, _placer, _itemstack, _pointed_thing)
  local node = minetest.get_node(pos)
  SpacetimeNetwork:maybe_register_node(pos, node)

  assert(yatm_core.trigger_refresh_infotext(pos))
end

local function teleporter_on_destruct(pos)
end

local function teleporter_after_destruct(pos, _old_node)
  SpacetimeNetwork:unregister_device(pos)
end

local states = {"error", "off", "on"}

local groups = {
  cracky = 1,
  item_interface_out = 1,
  addressable_spacetime_device = 1,
}
for _,state in ipairs(states) do
  local new_groups = groups
  if state ~= "off" then
    new_groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1})
  end
  minetest.register_node("yatm_item_teleporters:item_receiver_" .. state, {
    description = "Item Receiver",
    drop = "yatm_item_teleporters:item_receiver_off",

    groups = new_groups,

    paramtype = "light",
    paramtype2 = "facedir",

    tiles = {
      "yatm_item_teleporter_top.receiver." .. state .. ".png",
      "yatm_item_teleporter_top.receiver." .. state .. ".png",
      "yatm_item_teleporter_side.receiver." .. state .. ".png",
      "yatm_item_teleporter_side.receiver." .. state .. ".png",
      "yatm_item_teleporter_side.receiver." .. state .. ".png",
      "yatm_item_teleporter_side.receiver." .. state .. ".png",
    },

    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        {-0.5, -0.5, -0.5, 0.5, 0.375, 0.5}, -- NodeBox1
        {-0.375, 0.375, -0.375, 0.375, 0.5, 0.375}, -- NodeBox2
      }
    },

    yatm_spacetime = {
      groups = {item_receiver = 1},
    },

    on_destruct = teleporter_on_destruct,
    after_place_node = teleporter_after_place_node,
    after_destruct = teleporter_after_destruct,
  })
end
