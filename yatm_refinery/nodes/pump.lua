local Directions = assert(foundation.com.Directions)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidRegistry = assert(yatm.fluids.FluidRegistry)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local Energy = assert(yatm.energy)

local pump_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_refinery:pump_error",
    error = "yatm_refinery:pump_error",
    off = "yatm_refinery:pump_off",
    on = "yatm_refinery:pump_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 16000,
    network_charge_bandwidth = 1000,
    startup_threshold = 1000,
  }
}

local TANK_NAME = "tank"
local fluid_interface = yatm.fluids.FluidInterface.new_simple(TANK_NAME, 16000)

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

local old_fill = fluid_interface.fill
function fluid_interface:fill(pos, dir, fluid_stack, commit)
  local node = minetest.get_node(pos)
  local pump_in_dir = Directions.facedir_to_face(node.param2, Directions.D_DOWN)
  if dir == pump_in_dir then
    return old_fill(self, pos, dir, fluid_stack, commit)
  else
    return nil
  end
end

local function pump_refresh_infotext(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  local meta = minetest.get_meta(pos)
  local fluid_stack = FluidMeta.get_fluid_stack(meta, TANK_NAME)

  local capacity = fluid_interface._private.capacity

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Tank: " .. FluidStack.pretty_format(fluid_stack, capacity)

  meta:set_string("infotext", infotext)
end

function pump_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  local energy_consumed = 0
  local meta = minetest.get_meta(pos)
  local nodedef = minetest.registered_nodes[node.name]

  local pump_dir = Directions.facedir_to_face(node.param2, Directions.D_DOWN)
  local target_pos = vector.add(pos, Directions.DIR6_TO_VEC3[pump_dir])
  local target_node = minetest.get_node(target_pos)
  local fluid_name = FluidRegistry.item_name_to_fluid_name(target_node.name)

  local capacity = nodedef.fluid_interface._private.capacity

  if fluid_name then
    local used_stack = FluidMeta.fill_fluid(meta, "tank", FluidStack.new(fluid_name, 1000), capacity, capacity, true)
    if used_stack and used_stack.amount > 0 then
      energy_consumed = energy_consumed + math.floor(100 * used_stack.amount / 1000)
      minetest.remove_node(target_pos)
    end
  else
    local inverted_dir = Directions.invert_dir(pump_dir)
    local drained_stack = FluidTanks.drain_fluid(target_pos, inverted_dir, FluidStack.new_wildcard(1000), false)
    if drained_stack and drained_stack.amount > 0 then
      local existing = FluidTanks.get_fluid(pos, pump_dir)
      local filled_stack = FluidMeta.fill_fluid(meta, "tank", drained_stack, capacity, capacity, true)

      if filled_stack and filled_stack.amount > 0 then
        FluidTanks.drain_fluid(target_pos,
          inverted_dir,
          filled_stack, true)
        energy_consumed = energy_consumed + math.floor(100 * filled_stack.amount / 1000)
      end
    end
  end

  do
    local new_dir = Directions.facedir_to_face(node.param2, Directions.D_UP)
    local target_pos = vector.add(pos, Directions.DIR6_TO_VEC3[new_dir])
    local stack = FluidMeta.drain_fluid(meta,
      "tank",
      FluidStack.new_wildcard(1000),
      capacity, capacity, false)

    if stack and stack.amount > 0 then
      local target_dir = Directions.invert_dir(new_dir)
      local filled_stack = FluidTanks.fill_fluid(target_pos, target_dir, stack, true)
      if filled_stack and filled_stack.amount > 0 then
        energy_consumed = energy_consumed + math.floor(100 * filled_stack.amount / 1000)
        FluidMeta.drain_fluid(meta,
          "tank",
          filled_stack,
          capacity, capacity, true)
      end
    end
  end

  return energy_consumed
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_refinery:pump",

  description = "Pump",

  codex_entry_id = "yatm_refinery:pump",

  groups = {
    cracky = 1,
    fluid_interface_out = 1,
    yatm_energy_device = 1,
  },

  drop = pump_yatm_network.states.off,

  tiles = {
    "yatm_pump_top.png",
    "yatm_pump_bottom.png",
    "yatm_pump_side.off.png",
    "yatm_pump_side.off.png^[transformFX",
    "yatm_pump_back.off.png",
    "yatm_pump_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = pump_yatm_network,
  fluid_interface = fluid_interface,
  refresh_infotext = pump_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_pump_top.png",
      "yatm_pump_bottom.png",
      "yatm_pump_side.error.png",
      "yatm_pump_side.error.png^[transformFX",
      "yatm_pump_back.error.png",
      "yatm_pump_front.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_pump_top.png",
      "yatm_pump_bottom.png",
      "yatm_pump_side.on.png",
      "yatm_pump_side.on.png^[transformFX",
      "yatm_pump_back.on.png",
      "yatm_pump_front.on.png",
    },
  }
})
