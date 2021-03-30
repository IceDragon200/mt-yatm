local Directions = assert(foundation.com.Directions)
local Groups = assert(foundation.com.Groups)
local table_merge = assert(foundation.com.table_merge)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidExchange = assert(yatm.fluids.FluidExchange)
local Energy = assert(yatm.energy)
local vapour_registry = assert(yatm.refinery.vapour_registry)

local vapourizer_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1, -- Use the machine worker behaviour
    energy_consumer = 1, -- This device consumes energy on the network
  },
  default_state = "off",
  states = {
    conflict = "yatm_refinery:vapourizer_error",
    error = "yatm_refinery:vapourizer_error",
    off = "yatm_refinery:vapourizer_off",
    on = "yatm_refinery:vapourizer_on",
    idle = "yatm_refinery:vapourizer_idle",
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
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_UP then
    return VAPOUR_TANK, self.capacity
  else
    return FLUID_TANK, self.capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface._private.capacity = 16000
fluid_interface._private.bandwidth = fluid_interface._private.capacity

function fluid_interface:allow_fill(pos, dir, fluid_stack)
  local tank_name = get_fluid_tank_name(self, pos, dir)
  if tank_name == FLUID_TANK then
    return true
  end
  return false
end

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

local auto_transfer = false

function vapourizer_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  local energy_consumed = 0
  local need_refresh = false
  local meta = minetest.get_meta(pos)

  if auto_transfer then
    -- Fluid transfer from input
    local input_tank_dir = Directions.facedir_to_face(node.param2, Directions.D_DOWN)
    local input_tank_pos = vector.add(pos, Directions.DIR6_TO_VEC3[input_tank_dir])

    local fs = FluidExchange.transfer_from_tank_to_meta(
      input_tank_pos, Directions.invert_dir(input_tank_dir),
      FluidStack.new_wildcard(1000),
      meta, { tank_name = FLUID_TANK, capacity = fluid_interface._private.capacity, bandwidth = fluid_interface._private.bandwidth },
      true
    )

    if fs and fs.amount > 0 then
      need_refresh = true
    end
  end

  -- Conversion
  local fluid_stack = FluidMeta.get_fluid_stack(meta, FLUID_TANK)
  if fluid_stack and fluid_stack.amount > 0 then
    local fluid_name = fluid_stack.name
    local recipe = vapour_registry:find_recipe_for_fluid(fluid_name)
    if recipe then
      local vapour_stack = FluidStack.new(recipe.vapour_name, math.min(fluid_stack.amount, 100))
      fluid_stack.amount = vapour_stack.amount
      if fluid_stack.amount > 0 then
        local filled_stack = FluidMeta.fill_fluid(meta, VAPOUR_TANK, vapour_stack, fluid_interface._private.capacity, fluid_interface._private.capacity, true)
        if filled_stack and filled_stack.amount > 0 then
          fluid_stack.amount = filled_stack.amount
          local drained_stack = FluidMeta.drain_fluid(meta, FLUID_TANK, fluid_stack, fluid_interface._private.capacity, fluid_interface._private.capacity, true)
          need_refresh = true
          energy_consumed = energy_consumed + math.max(math.floor(drained_stack.amount / 100), 1)
        end
      end
      meta:set_string("error_text", nil)
    else
      meta:set_string("error_text", "no recipe")
      need_refresh = true
    end
  end

  if auto_transfer then
    -- Fluid transfer to output - and only to fluid_tanks
    local output_tank_dir = Directions.facedir_to_face(node.param2, Directions.D_UP)
    local output_tank_pos = vector.add(pos, Directions.DIR6_TO_VEC3[output_tank_dir])

    local output_tank_node = minetest.get_node_or_nil(output_tank_pos)

    if output_tank_node then
      local output_tank_nodedef = minetest.registered_nodes[output_tank_node.name]

      if Groups.has_group(output_tank_nodedef, 'fluid_tank') then
        local fs = FluidExchange.transfer_from_meta_to_tank(
          meta,
          {
            tank_name = VAPOUR_TANK,
            capacity = fluid_interface._private.capacity,
            bandwidth = fluid_interface._private.capacity
          },
          FluidStack.new_wildcard(100),
          output_tank_pos, Directions.invert_dir(output_tank_dir),
          true
        )

        if fs and fs.amount > 0 then
          need_refresh = true
        end
      end
    end
  end

  if need_refresh then
    yatm.queue_refresh_infotext(pos, node)
  end

  return energy_consumed
end

function vapourizer_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local vapour_fluid_stack = FluidMeta.get_fluid_stack(meta, VAPOUR_TANK)
  local fluid_stack = FluidMeta.get_fluid_stack(meta, FLUID_TANK)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. " (" .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. " E)" .. "\n" ..
    "Vapour Tank: " .. FluidStack.pretty_format(vapour_fluid_stack, fluid_interface._private.capacity) .. "\n" ..
    "Fluid Tank: " .. FluidStack.pretty_format(fluid_stack, fluid_interface._private.capacity)

  meta:set_string("infotext", infotext)
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_refinery:vapourizer",

  description = "Vapourizer",

  codex_entry_id = "yatm_refinery:vapourizer",

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

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = table_merge(vapourizer_yatm_network, {state = "off"}),

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
  idle = {
    tiles = {
      "yatm_vapourizer_top.idle.png",
      "yatm_vapourizer_bottom.idle.png",
      "yatm_vapourizer_side.idle.png",
      "yatm_vapourizer_side.idle.png",
      "yatm_vapourizer_side.idle.png",
      "yatm_vapourizer_side.idle.png"
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
