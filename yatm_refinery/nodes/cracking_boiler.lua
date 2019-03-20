local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local Network = assert(yatm.network)
local Energy = assert(yatm.energy)

local boiler_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1, -- Use the machine worker behaviour
    energy_consumer = 1, -- This device consumes energy on the network
    has_update = 1, -- the device should be updated every network step
  },
  default_state = "off",
  states = {
    conflict = "yatm_refinery:cracking_boiler_error",
    error = "yatm_refinery:cracking_boiler_error",
    off = "yatm_refinery:cracking_boiler_off",
    on = "yatm_refinery:cracking_boiler_on",
  },
  energy = {
    passive_lost = 0,
    startup_threshold = 0,
    capacity = 16000,
    network_charge_bandwidth  = 1000,
  },
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

function boiler_yatm_network.work(pos, node, available_energy, work_rate, ot)
  return 0
end

local groups = {cracky = 1, fluid_interface_in = 1, fluid_interface_out = 1}

yatm.devices.register_stateful_network_device({
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
}, {
  error = {
    tiles = {
      "yatm_cracking_boiler_top.error.png",
      "yatm_cracking_boiler_bottom.error.png",
      "yatm_cracking_boiler_side.error.png",
      "yatm_cracking_boiler_side.error.png",
      "yatm_cracking_boiler_side.error.png",
      "yatm_cracking_boiler_side.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_cracking_boiler_top.on.png",
      "yatm_cracking_boiler_bottom.on.png",
      "yatm_cracking_boiler_side.on.png",
      "yatm_cracking_boiler_side.on.png",
      "yatm_cracking_boiler_side.on.png",
      "yatm_cracking_boiler_side.on.png"
    },
  },
})
