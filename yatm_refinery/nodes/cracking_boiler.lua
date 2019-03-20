local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local Network = assert(yatm.network)
local Energy = assert(yatm.energy)

local cracking_boiler_yatm_network = {
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
local FLUID_TANK = "fluid_tank"

local function get_fluid_tank_name(self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_UP then
    return STEAM_TANK, self.capacity
  else
    return FLUID_TANK, self.capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface.capacity = 16000
fluid_interface.bandwidth = fluid_interface.capacity

function cracking_boiler_yatm_network.work(pos, node, available_energy, work_rate, ot)
  return 0
end

function cracking_boiler_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local steam_fluid_stack = FluidMeta.get_fluid(meta, STEAM_TANK)
  local fluid_stack = FluidMeta.get_fluid(meta, FLUID_TANK)

  local infotext =
    "Network ID: " .. Network.to_infotext(meta) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Steam Tank: " .. FluidStack.pretty_format(steam_fluid_stack, fluid_interface.capacity) .. "\n" ..
    "Fluid Tank: " .. FluidStack.pretty_format(fluid_stack, fluid_interface.capacity)

  meta:set_string("infotext", infotext)
end

yatm.devices.register_stateful_network_device({
  description = "Cracking Boiler",

  groups = {
    cracky = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
    yatm_energy_device = 1,
  },

  drop = cracking_boiler_yatm_network.states.off,

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

  yatm_network = yatm_core.table_merge(cracking_boiler_yatm_network, {state = "off"}),

  fluid_interface = fluid_interface,

  refresh_infotext = cracking_boiler_refresh_infotext,
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
