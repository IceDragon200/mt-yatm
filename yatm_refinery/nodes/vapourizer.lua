local cluster_devices = assert(yatm.cluster.devices)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidExchange = assert(yatm.fluids.FluidExchange)
local Energy = assert(yatm.energy)
local VapourRegistry = assert(yatm.refinery.VapourRegistry)

local vapourizer_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1, -- Use the machine worker behaviour
    energy_consumer = 1, -- This device consumes energy on the network
    has_update = 1, -- the device should be updated every network step
  },
  default_state = "off",
  states = {
    conflict = "yatm_refinery:vapourizer_error",
    error = "yatm_refinery:vapourizer_error",
    off = "yatm_refinery:vapourizer_off",
    on = "yatm_refinery:vapourizer_on",
  },
  energy = {
    passive_lost = 0,
    startup_threshold = 0,
    capacity = 16000,
    network_charge_bandwidth  = 1000,
  },
}

local VAPOUR_TANK = "vapour_tank"
local FLUID_TANK = "fluid_tank"

local function get_fluid_tank_name(self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_UP then
    return VAPOUR_TANK, self.capacity
  else
    return FLUID_TANK, self.capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface.capacity = 16000
fluid_interface.bandwidth = fluid_interface.capacity

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  yatm.queue_refresh_infotext(pos)
end

function vapourizer_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  local energy_consumed = 0
  local need_refresh = false
  local meta = minetest.get_meta(pos)

  -- Fluid transfer from input
  local input_tank_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
  local input_tank_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[input_tank_dir])

  local fs = FluidExchange.transfer_from_tank_to_meta(
    input_tank_pos, yatm_core.invert_dir(input_tank_dir),
    FluidStack.new_wildcard(1000),
    meta, { tank_name = FLUID_TANK, capacity = fluid_interface.capacity, bandwidth = fluid_interface.bandwidth },
    true
  )

  if fs and fs.amount > 0 then
    need_refresh = true
  end

  -- Conversion
  local fluid_stack = FluidMeta.get_fluid_stack(meta, FLUID_TANK)
  if fluid_stack and fluid_stack.amount > 0 then
    local fluid_name = fluid_stack.name
    local recipe = VapourRegistry:get_recipe_for_fluid(fluid_name)
    if recipe then
      local vapour_stack = FluidStack.new(recipe.vapour_name, math.min(fluid_stack.amount, 100))
      fluid_stack.amount = vapour_stack.amount
      if fluid_stack.amount > 0 then
        local filled_stack = FluidMeta.fill_fluid(meta, VAPOUR_TANK, vapour_stack, fluid_interface.capacity, fluid_interface.capacity, true)
        if filled_stack and filled_stack.amount > 0 then
          fluid_stack.amount = filled_stack.amount
          local drained_stack = FluidMeta.drain_fluid(meta, FLUID_TANK, fluid_stack, fluid_interface.capacity, fluid_interface.capacity, true)
          need_refresh = true
          energy_consumed = energy_consumed + math.max(math.floor(drained_stack.amount / 100), 1)
        end
      end
    end
  end

  -- Fluid transfer to output
  local output_tank_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_UP)
  local output_tank_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[output_tank_dir])

  local fs = FluidExchange.transfer_from_meta_to_tank(
    meta, { tank_name = VAPOUR_TANK, capacity = fluid_interface.capacity, bandwidth = fluid_interface.capacity },
    FluidStack.new_wildcard(100),
    output_tank_pos, yatm_core.invert_dir(output_tank_dir),
    true
  )

  if fs and fs.amount > 0 then
    need_refresh = true
  end

  if need_refresh then
    yatm.queue_refresh_infotext(pos)
  end

  return energy_consumed
end

function vapourizer_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local vapour_fluid_stack = FluidMeta.get_fluid_stack(meta, VAPOUR_TANK)
  local fluid_stack = FluidMeta.get_fluid_stack(meta, FLUID_TANK)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Vapour Tank: " .. FluidStack.pretty_format(vapour_fluid_stack, fluid_interface.capacity) .. "\n" ..
    "Fluid Tank: " .. FluidStack.pretty_format(fluid_stack, fluid_interface.capacity)

  meta:set_string("infotext", infotext)
end

yatm.devices.register_stateful_network_device({
  description = "Vapourizer",

  groups = {
    cracky = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
    yatm_energy_device = 1,
  },

  drop = vapourizer_yatm_network.states.off,

  tiles = {
    "yatm_vapourizer_top.off.png",
    "yatm_vapourizer_bottom.off.png",
    "yatm_vapourizer_side.off.png",
    "yatm_vapourizer_side.off.png",
    "yatm_vapourizer_side.off.png",
    "yatm_vapourizer_side.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = yatm_core.table_merge(vapourizer_yatm_network, {state = "off"}),

  fluid_interface = fluid_interface,

  refresh_infotext = vapourizer_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_vapourizer_top.error.png",
      "yatm_vapourizer_bottom.error.png",
      "yatm_vapourizer_side.error.png",
      "yatm_vapourizer_side.error.png",
      "yatm_vapourizer_side.error.png",
      "yatm_vapourizer_side.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_vapourizer_top.on.png",
      "yatm_vapourizer_bottom.on.png",
      "yatm_vapourizer_side.on.png",
      "yatm_vapourizer_side.on.png",
      "yatm_vapourizer_side.on.png",
      "yatm_vapourizer_side.on.png"
    },
    light_source = 7,
  },
})
