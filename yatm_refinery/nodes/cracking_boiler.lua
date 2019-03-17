local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local Network = assert(yatm.network)

local boiler_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1, -- Use the machine worker behaviour
    energy_consumer = 1, -- This device consumes energy on the network
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_refinery:cracking_boiler_error",
    error = "yatm_refinery:cracking_boiler_error",
    off = "yatm_refinery:cracking_boiler_off",
    on = "yatm_refinery:cracking_boiler_on",
  },
  passive_energy_lost = 0,
  startup_energy_threshold = 0,
  energy_capacity = 16000,
  network_charge_bandwidth = 1000,
}

local STEAM_TANK = "steam_tank"
local WATER_TANK = "water_tank"

local function get_fluid_tank_name(self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_UP then
    return STEAM_TANK, self.capacity
  else
    return WATER_TANK, self.capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface.capacity = 16000
fluid_interface.bandwidth = fluid_interface.capacity

local groups = {cracky = 1, fluid_interface_in = 1, fluid_interface_out = 1}

yatm.devices.register_network_device("yatm_refinery:cracking_boiler_off", {
  description = "Cracking Boiler",

  groups = yatm_core.table_merge(groups, {}),

  drop = boiler_yatm_network.states.off,
  tiles = {
    "yatm_cracking_boiler_top.off.png",
    "yatm_cracking_boiler_bottom.off.png",
    "yatm_cracking_boiler_side.off.png",
    "yatm_cracking_boiler_side.off.png",
    "yatm_cracking_boiler_side.off.png",
    "yatm_cracking_boiler_side.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = yatm_core.table_merge(boiler_yatm_network, {state = "off"}),

  fluid_interface = fluid_interface,
})

yatm.devices.register_network_device("yatm_refinery:cracking_boiler_error", {
  description = "Cracking Boiler",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
})

yatm.devices.register_network_device("yatm_refinery:cracking_boiler_on", {
  description = "Cracking Boiler",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
})

