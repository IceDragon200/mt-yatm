local Network = assert(yatm_core.Network)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local Energy = assert(yatm.energy)

local distillation_unit_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    fluid_consumer = 1,
    fluid_producer = 1,
    distillation_unit = 1,
  },

  default_state = "off",
  states = {
    on = "yatm_refinery:distillation_unit_on",
    off = "yatm_refinery:distillation_unit_off",
    error = "yatm_refinery:distillation_unit_error",
    conflict = "yatm_refinery:distillation_unit_conflict",
  },

  energy = {
    capacity = 4000,
    passive_energy_lost = 0,
    network_charge_bandwidth = 1000,
    startup_threshold = 100,
  },
}

local OUTPUT_STEAM_TANK = "output_steam_tank"
local INPUT_STEAM_TANK = "input_steam_tank"
local DISTILLED_TANK = "distilled_tank"

local function get_fluid_tank_name(self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_UP then
    return OUTPUT_STEAM_TANK, self.capacity
  elseif new_dir == yatm_core.D_DOWN then
    return INPUT_STEAM_TANK, self.capacity
  else
    return DISTILLED_TANK, self.capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface.capacity = 16000
fluid_interface.bandwidth = fluid_interface.capacity

function distillation_unit_yatm_network.work(pos, node, available_energy, work_rate, ot)
  return 10
end

function distillation_unit_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local output_steam_fluid_stack = FluidMeta.get_fluid(meta, OUTPUT_STEAM_TANK)
  local input_steam_fluid_stack = FluidMeta.get_fluid(meta, INPUT_STEAM_TANK)
  local distilled_fluid_stack = FluidMeta.get_fluid(meta, DISTILLED_TANK)

  local infotext =
    "Network ID: " .. Network.to_infotext(meta) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "I.Steam Tank: " .. FluidStack.pretty_format(input_steam_fluid_stack, fluid_interface.capacity) .. "\n" ..
    "O.Steam Tank: " .. FluidStack.pretty_format(output_steam_fluid_stack, fluid_interface.capacity) .. "\n" ..
    "Distilled Tank: " .. FluidStack.pretty_format(distilled_fluid_stack, fluid_interface.capacity)

  meta:set_string("infotext", infotext)
end

yatm.devices.register_stateful_network_device({
  description = "Distillation Unit",

  groups = {cracky = 1, fluid_interface_in = 1, fluid_interface_out = 1},

  tiles = {
    "yatm_distillation_unit_top.off.png",
    "yatm_distillation_unit_bottom.off.png",
    "yatm_distillation_unit_side.off.png",
    "yatm_distillation_unit_side.off.png",
    "yatm_distillation_unit_side.off.png",
    "yatm_distillation_unit_side.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
      {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, -- NodeBox2
      {-0.4375, -0.25, -0.4375, 0.4375, 0.3125, 0.4375}, -- NodeBox3
      {-0.5, -0.25, -0.25, 0.5, 0.25, 0.25}, -- NodeBox4
      {-0.25, -0.25, -0.5, 0.25, 0.25, 0.5}, -- NodeBox5
    }
  },

  yatm_network = distillation_unit_yatm_network,

  fluid_interface = fluid_interface,

  refresh_infotext = distillation_unit_refresh_infotext,
}, {
  error = {
  },
  on = {
    tiles = {
      "yatm_distillation_unit_top.on.png",
      "yatm_distillation_unit_bottom.on.png",
      "yatm_distillation_unit_side.on.png",
      "yatm_distillation_unit_side.on.png",
      "yatm_distillation_unit_side.on.png",
      "yatm_distillation_unit_side.on.png",
    },
  }
})
