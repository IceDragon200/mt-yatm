local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local Fluids = assert(yatm.fluids)

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

local function get_fluid_tank_name(self, pos, dir, node)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_UP then
    return STEAM_TANK, self.capacity
  elseif new_dir == yatm_core.D_EAST or
         new_dir == yatm_core.D_WEST or
         new_dir == yatm_core.D_NORTH or
         new_dir == yatm_core.D_SOUTH then
    return WATER_TANK, self.capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface.capacity = 16000
fluid_interface.bandwidth = fluid_interface.capacity

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
        local stack = yatm_core.fluid_tanks.drain(water_tank_pos,
          target_dir,
          FluidStack.new("group:water", 1000), false)
        if stack then
          local filled_stack = yatm_core.fluid_tanks.fill(pos, water_tank_dir, stack, true)
          if filled_stack and filled_stack.amount > 0 then
            yatm_core.fluid_tanks.drain(water_tank_pos, target_dir, filled_stack, true)
            energy_consumed = energy_consumed + 1
          end
        end
      end
    end
  end

  local meta = minetest.get_meta(pos)

  -- Convert water into steam
  do
    local stack = Fluids.drain_fluid(meta,
      WATER_TANK,
      FluidStack.new("group:water", 50),
      fluid_interface.bandwidth, fluid_interface.capacity, false)
    if stack then
      local filled_stack = Fluids.fill_fluid(meta,
        STEAM_TANK,
        FluidStack.set_name(stack, "yatm_core:steam"),
        fluid_interface.bandwidth, fluid_interface.capacity, true)
      if filled_stack and filled_stack.amount > 0 then
        Fluids.drain_fluid(meta,
          WATER_TANK,
          FluidStack.set_amount(stack, filled_stack.amount),
          fluid_interface.bandwidth, fluid_interface.capacity, true)
        energy_consumed = energy_consumed + filled_stack.amount
      end
    end
  end

  -- Fill tank on the UP face of the boiler with steam, if available
  do
    local stack, _new_stack = Fluids.drain_fluid(meta,
      STEAM_TANK,
      FluidStack.new("group:steam", 1000),
      fluid_interface.capacity, fluid_interface.capacity, false)

    if stack then
      local steam_tank_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_UP)
      local steam_tank_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[steam_tank_dir])
      local steam_tank_node = minetest.get_node(steam_tank_pos)
      local steam_tank_nodedef = minetest.registered_nodes[steam_tank_node.name]

      if steam_tank_nodedef then
        local filled_stack = yatm_core.fluid_tanks.fill(steam_tank_pos,
          yatm_core.invert_dir(steam_tank_dir), stack, true)
        if filled_stack and filled_stack.amount > 0 then
          yatm_core.fluid_tanks.drain(pos, steam_tank_dir, filled_stack, true)
          energy_consumed = energy_consumed + 1
        end
      end
    end
  end

  return energy_consumed
end

yatm.devices.register_network_device(boiler_yatm_network.states.off, {
  description = "Boiler",
  groups = {cracky = 1},
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
  groups = {cracky = 1, not_in_creative_inventory = 1},
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
  groups = {cracky = 1, not_in_creative_inventory = 1},
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
