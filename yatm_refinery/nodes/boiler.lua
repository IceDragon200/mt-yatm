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
    conflict = "yatm_refinery:boiler_error",
    error = "yatm_refinery:boiler_error",
    off = "yatm_refinery:boiler_off",
    on = "yatm_refinery:boiler_on",
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

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  yatm_core.queue_refresh_infotext(pos)
end

local function boiler_refresh_infotext(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    local meta = minetest.get_meta(pos)
    local state = nodedef.yatm_network.state
    local network_id = Network.get_meta_network_id(meta)
    local steam_fluid_stack = FluidMeta.get_fluid(meta, STEAM_TANK)
    local water_fluid_stack = FluidMeta.get_fluid(meta, WATER_TANK)
    meta:set_string("infotext",
      "Network ID: <" .. Network.format_id(network_id) .. "> " .. state .. "\n" ..
      "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
      "Steam Tank: <" .. FluidStack.pretty_format(steam_fluid_stack, fluid_interface.capacity) .. ">\n" ..
      "Water Tank: <" .. FluidStack.pretty_format(water_fluid_stack, fluid_interface.capacity) .. ">"
    )
  end
end

function boiler_yatm_network.work(pos, node, available_energy, work_rate, ot)
  local energy_consumed = 0
  -- Drain water from adjacent tanks
  for _, dir in ipairs(yatm_core.DIR4) do
    local water_tank_dir = yatm_core.facedir_to_face(node.param2, dir)

    local water_tank_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[water_tank_dir])
    local water_tank_node = minetest.get_node(water_tank_pos)
    local water_tank_nodedef = minetest.registered_nodes[water_tank_node.name]
    if water_tank_nodedef then
      if yatm_core.groups.get_item(water_tank_nodedef, "fluid_tank") then
        local target_dir = yatm_core.invert_dir(water_tank_dir)
        local stack = FluidTanks.drain_fluid(water_tank_pos,
          target_dir,
          FluidStack.new("group:water", 1000), false)
        if stack then
          local filled_stack = FluidTanks.fill_fluid(pos, water_tank_dir, stack, true)
          if filled_stack and filled_stack.amount > 0 then
            FluidTanks.drain_fluid(water_tank_pos, target_dir, filled_stack, true)
            energy_consumed = energy_consumed + 1
          end
        end
      end
    end
  end

  local meta = minetest.get_meta(pos)

  -- Convert water into steam
  do
    local stack = FluidMeta.drain_fluid(meta,
      WATER_TANK,
      FluidStack.new("group:water", 50),
      fluid_interface.bandwidth, fluid_interface.capacity, false)
    if stack then
      local filled_stack = FluidMeta.fill_fluid(meta,
        STEAM_TANK,
        FluidStack.set_name(stack, "yatm_core:steam"),
        fluid_interface.bandwidth, fluid_interface.capacity, true)
      if filled_stack and filled_stack.amount > 0 then
        FluidMeta.drain_fluid(meta,
          WATER_TANK,
          FluidStack.set_amount(stack, filled_stack.amount),
          fluid_interface.bandwidth, fluid_interface.capacity, true)
        energy_consumed = energy_consumed + filled_stack.amount
      end
    end
  end

  -- Fill tank on the UP face of the boiler with steam, if available
  do
    local stack, _new_stack = FluidMeta.drain_fluid(meta,
      STEAM_TANK,
      FluidStack.new("group:steam", 1000),
      fluid_interface.capacity, fluid_interface.capacity, false)

    if stack then
      local steam_tank_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_UP)
      local steam_tank_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[steam_tank_dir])
      local steam_tank_node = minetest.get_node(steam_tank_pos)
      local steam_tank_nodedef = minetest.registered_nodes[steam_tank_node.name]

      if steam_tank_nodedef then
        local filled_stack = FluidTanks.fill_fluid(steam_tank_pos,
          yatm_core.invert_dir(steam_tank_dir), stack, true)
        if filled_stack and filled_stack.amount > 0 then
          FluidTanks.drain_fluid(pos, steam_tank_dir, filled_stack, true)
          energy_consumed = energy_consumed + 1
        end
      end
    end
  end

  return energy_consumed
end

yatm.devices.register_stateful_network_device({
  description = "Boiler",

  groups = {
    cracky = 1,
    fluid_interface_out = 1,
    fluid_interface_in = 1,
    yatm_energy_device = 1,
  },

  drop = boiler_yatm_network.states.off,

  tiles = {
    "yatm_boiler_top.off.png",
    "yatm_boiler_bottom.off.png",
    "yatm_boiler_side.off.png",
    "yatm_boiler_side.off.png",
    "yatm_boiler_side.off.png",
    "yatm_boiler_side.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(boiler_yatm_network, {state = "off"}),

  fluid_interface = fluid_interface,
  refresh_infotext = boiler_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_boiler_top.error.png",
      "yatm_boiler_bottom.error.png",
      "yatm_boiler_side.error.png",
      "yatm_boiler_side.error.png",
      "yatm_boiler_side.error.png",
      "yatm_boiler_side.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_boiler_top.on.png",
      "yatm_boiler_bottom.on.png",
      "yatm_boiler_side.on.png",
      "yatm_boiler_side.on.png",
      "yatm_boiler_side.on.png",
      "yatm_boiler_side.on.png",
    },
    light_source = 7,
  },
})
