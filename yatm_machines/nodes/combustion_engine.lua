local FluidStack = assert(yatm.fluids.FluidStack)
local FluidUtils = assert(yatm.fluids.Utils)

local combustion_engine_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, 0.375, -0.375, 0.5, 0.5}, -- NodeBox1
    {0.375, -0.5, -0.5, 0.5, 0.5, -0.375}, -- NodeBox2
    {-0.375, -0.375, -0.5, 0.375, 0.3125, 0.5}, -- Core
    {-0.1875, 0.3125, -0.1875, 0.1875, 0.375, 0.1875}, -- NodeBox4
    {-0.5, 0.375, -0.5, 0.5, 0.5, -0.375}, -- NodeBox5
    {-0.5, 0.375, 0.375, 0.5, 0.5, 0.5}, -- NodeBox6
    {-0.5, -0.5, -0.5, -0.375, 0.5, -0.375}, -- NodeBox7
    {-0.5, -0.5, 0.375, 0.5, -0.375, 0.5}, -- NodeBox8
    {-0.5, -0.5, -0.5, 0.5, -0.375, -0.375}, -- NodeBox9
    {0.375, -0.5, 0.375, 0.5, 0.5, 0.5}, -- NodeBox10
    {0.375, -0.25, -0.25, 0.5, 0.25, 0.25}, -- NodeBox11
    {-0.5, -0.25, -0.25, -0.375, 0.25, 0.25}, -- NodeBox12
  }
}

local combustion_engine_yatm_network = {
  kind = "energy_producer",
  groups = {energy_producer = 1, energy_consumer = 1},
  states = {
    conflict = "yatm_machines:combustion_engine_error",
    error = "yatm_machines:combustion_engine_error",
    off = "yatm_machines:combustion_engine_off",
    on = "yatm_machines:combustion_engine_on",
  },
}

function combustion_engine_yatm_network.produce_energy(pos, node, should_commit)
  local meta = minetest.get_meta(pos)
  if meta then
    return 100
  end
  return 0
end

local fluid_interface = yatm.fluids.FluidInterface.new_simple("tank", 16000)

local groups = {cracky = 1, yatm_network_host = 3, fluid_interface_in = 1}

yatm.devices.register_network_device(combustion_engine_yatm_network.states.off, {
  description = "Combustion Engine",
  groups = groups,
  drop = combustion_engine_yatm_network.states.off,
  tiles = {
    "yatm_combustion_engine_top.off.png",
    "yatm_combustion_engine_bottom.off.png",
    "yatm_combustion_engine_side.off.png",
    "yatm_combustion_engine_side.off.png",
    "yatm_combustion_engine_back.off.png",
    "yatm_combustion_engine_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = combustion_engine_nodebox,
  yatm_network = combustion_engine_yatm_network,
  fluid_interface = fluid_interface,
})

yatm.devices.register_network_device(combustion_engine_yatm_network.states.error, {
  description = "Combustion Engine",
  groups = yatm_core.table_merge({not_in_creative_inventory = 1}),
  drop = combustion_engine_yatm_network.states.off,
  tiles = {
    "yatm_combustion_engine_top.error.png",
    "yatm_combustion_engine_bottom.error.png",
    "yatm_combustion_engine_side.error.png",
    "yatm_combustion_engine_side.error.png",
    "yatm_combustion_engine_back.error.png",
    "yatm_combustion_engine_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = combustion_engine_nodebox,
  yatm_network = combustion_engine_yatm_network,
  fluid_interface = fluid_interface,
})

yatm.devices.register_network_device(combustion_engine_yatm_network.states.on, {
  description = "Combustion Engine",
  groups = yatm_core.table_merge({not_in_creative_inventory = 1}),
  drop = combustion_engine_yatm_network.states.off,
  tiles = {
    "yatm_combustion_engine_top.on.png",
    "yatm_combustion_engine_bottom.on.png",
    "yatm_combustion_engine_side.on.png",
    "yatm_combustion_engine_side.on.png",
    "yatm_combustion_engine_back.on.png",
    "yatm_combustion_engine_front.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = combustion_engine_nodebox,
  yatm_network = combustion_engine_yatm_network,
  fluid_interface = fluid_interface,
})
