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

minetest.register_node("yatm_brewery:kettle_off", {
  description = "Kettle",

  groups = groups,

  tiles = {
    "yatm_kettle_top.off.png",
    "yatm_kettle_bottom.off.png",
    "yatm_kettle_side.off.png",
    "yatm_kettle_side.off.png",
    "yatm_kettle_side.off.png",
    "yatm_kettle_side.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = kettle_on_construct,
  on_destruct = kettle_on_destruct,

  fluid_interface = fluid_interface,
  item_interface = item_interface,
  heat_interface = heat_interface,
})

minetest.register_node("yatm_brewery:kettle_on", {
  description = "Kettle",

  groups = groups,
  drop = "yatm_brewery:kettle_off",

  tiles = {
    "yatm_kettle_top.on.png",
    "yatm_kettle_bottom.on.png",
    "yatm_kettle_side.on.png",
    "yatm_kettle_side.on.png",
    "yatm_kettle_side.on.png",
    "yatm_kettle_side.on.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = kettle_on_construct,
  on_destruct = kettle_on_destruct,

  fluid_interface = fluid_interface,
  item_interface = item_interface,
  heat_interface = heat_interface,
})
