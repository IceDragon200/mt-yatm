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
    conflict = "yatm_refinery:boiler_error",
    error = "yatm_refinery:boiler_error",
    off = "yatm_refinery:boiler_off",
    on = "yatm_refinery:boiler_on",
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

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  boiler_yatm_network.refresh_infotext(pos, nil, minetest.get_meta(pos), { cause = "fluid_changed" })
end

function boiler_yatm_network.refresh_infotext(pos, node, meta, event)
  local new_node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[new_node.name]
  local state = nodedef.yatm_network.state
  local network_id = Network.get_meta_network_id(meta)
  local steam_fluid_stack = FluidMeta.get_fluid(meta, STEAM_TANK)
  local water_fluid_stack = FluidMeta.get_fluid(meta, WATER_TANK)
  meta:set_string("infotext",
    "Network ID <" .. Network.format_id(network_id) .. "> " .. state .. "\n" ..
    "Steam Tank <" .. FluidStack.to_string(steam_fluid_stack, fluid_interface.capacity) .. ">\n" ..
    "Water Tank <" .. FluidStack.to_string(water_fluid_stack, fluid_interface.capacity) .. ">"
  )
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
        local stack = FluidTanks.drain(water_tank_pos,
          target_dir,
          FluidStack.new("group:water", 1000), false)
        if stack then
          local filled_stack = FluidTanks.fill(pos, water_tank_dir, stack, true)
          if filled_stack and filled_stack.amount > 0 then
            FluidTanks.drain(water_tank_pos, target_dir, filled_stack, true)
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
        local filled_stack = FluidTanks.fill(steam_tank_pos,
          yatm_core.invert_dir(steam_tank_dir), stack, true)
        if filled_stack and filled_stack.amount > 0 then
          FluidTanks.drain(pos, steam_tank_dir, filled_stack, true)
          energy_consumed = energy_consumed + 1
        end
      end
    end
  end

  return energy_consumed
end

local groups = { cracky = 1, fluid_interface_out = 1, fluid_interface_in = 1 }

yatm.devices.register_network_device(boiler_yatm_network.states.off, {
  description = "Boiler",
  groups = groups,
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
})

yatm.devices.register_network_device(boiler_yatm_network.states.error, {
  description = "Boiler",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = boiler_yatm_network.states.off,
  tiles = {
    "yatm_boiler_top.error.png",
    "yatm_boiler_bottom.error.png",
    "yatm_boiler_side.error.png",
    "yatm_boiler_side.error.png",
    "yatm_boiler_side.error.png",
    "yatm_boiler_side.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(boiler_yatm_network, {state = "error"}),
  fluid_interface = fluid_interface,
})

yatm.devices.register_network_device(boiler_yatm_network.states.on, {
  description = "Boiler",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = boiler_yatm_network.states.off,
  tiles = {
    "yatm_boiler_top.on.png",
    "yatm_boiler_bottom.on.png",
    "yatm_boiler_side.on.png",
    "yatm_boiler_side.on.png",
    "yatm_boiler_side.on.png",
    "yatm_boiler_side.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(boiler_yatm_network, {state = "on"}),
  fluid_interface = fluid_interface,
})
