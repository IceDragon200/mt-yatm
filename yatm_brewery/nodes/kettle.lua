local ItemInterface = assert(yatm.items.ItemInterface)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local HeatInterface = assert(yatm.heating.HeatInterface)

local tank_capacity = 4000
local fluid_interface = FluidInterface.new_directional(function (self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_DOWN then
    return "input_fluid_tank", tank_capacity
  else
    return "output_fluid_tank", tank_capacity
  end
end)

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
end)

local heat_interface = HeatInterface.new_simple("heat", 400)

local function kettle_on_construct(pos)
end

local groups = {
  -- Tool groups
  cracky = 1,
  -- Node type
  kettle = 1,
  -- Item Interface groups
  item_interface_in = 1,
  item_interface_out = 1,
  -- Fluid Interface groups
  fluid_interface_in = 1,
  fluid_interface_out = 1,
  -- Heat Interface groups
  heat_interface_in = 1,
  heated_device = 1,
}

local kettle_node_box = {
  type = "fixed",
  fixed = {
    -- legs
    yatm_core.Cuboid:new(2, 0, 2, 3, 2, 3):fast_node_box(),
    yatm_core.Cuboid:new(11,0, 2, 3, 2, 3):fast_node_box(),
    yatm_core.Cuboid:new(2, 0,11, 3, 2, 3):fast_node_box(),
    yatm_core.Cuboid:new(11,0,11, 3, 2, 3):fast_node_box(),
    --
    yatm_core.Cuboid:new(1, 2, 1,14, 3,14):fast_node_box(), -- base plate
    --
    yatm_core.Cuboid:new(0, 4, 0,16,12, 2):fast_node_box(), -- north side
    yatm_core.Cuboid:new(0, 4,14,16,12, 2):fast_node_box(), -- south side
    yatm_core.Cuboid:new(0, 4, 0, 2,12,16):fast_node_box(), -- west side
    yatm_core.Cuboid:new(14,4, 0, 2,12,16):fast_node_box(), -- east side
  },
}

minetest.register_node("yatm_brewery:kettle_off", {
  description = "Kettle",

  groups = groups,

  drawtype = "nodebox",
  node_box = kettle_node_box,
  tiles = {
    "yatm_kettle_top.png",
    "yatm_kettle_bottom.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = kettle_on_construct,

  fluid_interface = fluid_interface,
  item_interface = item_interface,
  heat_interface = heat_interface,
})

minetest.register_node("yatm_brewery:kettle_on", {
  description = "Kettle",

  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = "yatm_brewery:kettle_off",

  drawtype = "nodebox",
  node_box = kettle_node_box,
  tiles = {
    "yatm_kettle_top.png",
    "yatm_kettle_bottom.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = kettle_on_construct,

  fluid_interface = fluid_interface,
  item_interface = item_interface,
  heat_interface = heat_interface,
})
