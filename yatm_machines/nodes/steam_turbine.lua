local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidStack = assert(yatm.fluids.FluidStack)

--[[
Steam turbines produce energy by consuming steam, they have the byproduct of water which can be cycled again into a boiler.
]]
local steam_turbine_yatm_network = {
  kind = "energy_producer",
  groups = {
    energy_producer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:steam_turbine_error",
    error = "yatm_machines:steam_turbine_error",
    off = "yatm_machines:steam_turbine_off",
    on = "yatm_machines:steam_turbine_on",
  },
  energy = {
    capacity = 4000,
  },
}

local capacity = 16000
local WATER_TANK = "water_tank"
local STEAM_TANK = "steam_tank"
local function get_fluid_tank_name(_self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)

  if new_dir == yatm_core.D_DOWN then
    return WATER_TANK, capacity
  elseif new_dir == yatm_core.D_EAST or
         new_dir == yatm_core.D_WEST or
         new_dir == yatm_core.D_NORTH or
         new_dir == yatm_core.D_SOUTH then
    return STEAM_TANK, capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface.capacity = capacity

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

function steam_turbine_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local water_tank_fluid_stack = FluidMeta.get_fluid_stack(meta, WATER_TANK)
  local steam_tank_fluid_stack = FluidMeta.get_fluid_stack(meta, STEAM_TANK)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Water Tank: " .. FluidStack.pretty_format(water_tank_fluid_stack, fluid_interface.capacity) .. "\n" ..
    "Steam Tank: " .. FluidStack.pretty_format(steam_tank_fluid_stack, fluid_interface.capacity)

  meta:set_string("infotext", infotext)
end

function steam_turbine_yatm_network.energy.produce_energy(pos, node, dtime, ot)
  local need_refresh = false
  local energy_produced = 0
  local meta = minetest.get_meta(pos)
  local drained_stack, new_amount = FluidMeta.drain_fluid(meta,
    STEAM_TANK,
    FluidStack.new("group:steam", 100),
    capacity, capacity, false)
  if drained_stack and drained_stack.amount > 0 then
    local water_from_steam = FluidStack.new("default:water", drained_stack.amount / 2)
    local filled_stack, new_amount = FluidMeta.fill_fluid(meta,
      WATER_TANK,
      water_from_steam,
      capacity, capacity, true)

    if filled_stack then
      local stack, new_amount = FluidMeta.drain_fluid(meta,
        STEAM_TANK,
        drained_stack,
        capacity, capacity, true)

      need_refresh = true
      energy_produced = energy_produced +  filled_stack.amount
    end
  end
  if need_refresh then
    yatm.queue_refresh_infotext(pos, node)
  end
  return energy_produced
end

function steam_turbine_yatm_network.update(pos, node, ot)
  local need_refresh = false

  for _, dir in ipairs(yatm_core.DIR4) do
    local new_dir = yatm_core.facedir_to_face(node.param2, dir)

    local npos = vector.add(pos, yatm_core.DIR6_TO_VEC3[new_dir])
    local nnode = minetest.get_node(npos)
    local nnodedef = minetest.registered_nodes[nnode.name]
    if nnodedef then
      if yatm_core.groups.get_item(nnodedef, "fluid_tank") then
        local target_dir = yatm_core.invert_dir(new_dir)
        local stack = FluidTanks.drain_fluid(npos, target_dir, FluidStack.new("group:steam", 200), false)
        if stack then
          local filled_stack = FluidTanks.fill_fluid(pos, new_dir, stack, true)
          if filled_stack then
            FluidTanks.drain_fluid(npos, target_dir, filled_stack, true)
            need_refresh = true
          end
        end
      end
    end
  end

  local meta = minetest.get_meta(pos)

  do -- Deposit water to a bottom tank
    local stack, new_amount = FluidMeta.drain_fluid(meta,
      WATER_TANK,
      FluidStack.new("group:water", 1000),
      capacity, capacity, false)
    -- Was any water drained?
    if stack then
      local tank_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
      local tank_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[tank_dir])
      local tank_node = minetest.get_node(tank_pos)
      local tank_nodedef = minetest.registered_nodes[tank_node.name]
      if tank_nodedef then
        if yatm_core.groups.get_item(tank_nodedef, "fluid_tank") then
          local drained_stack, new_amount = FluidTanks.fill_fluid(tank_pos, yatm_core.invert_dir(tank_dir), stack, true)
          if drained_stack and drained_stack.amount > 0 then
            FluidMeta.drain_fluid(meta,
              WATER_TANK,
              FluidStack.set_amount(stack, drained_stack.amount),
              capacity, capacity, true)
            need_refresh = true
          end
        end
      end
    end
  end

  if need_refresh then
    yatm.queue_refresh_infotext(pos, node)
  end
end

local groups = {
  cracky = 1,
  device_cluster_controller = 2,
  fluid_interface_in = 1,
  fluid_interface_out = 1,
  yatm_energy_device = 1,
}

local table_merge = assert(yatm_core.table_merge)

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:steam_turbine",

  description = "Steam Turbine",

  groups = groups,

  drop = steam_turbine_yatm_network.states.off,

  sounds = default.node_sound_metal_defaults(),

  tiles = {
    "yatm_steam_turbine_top.off.png",
    "yatm_steam_turbine_bottom.png",
    "yatm_steam_turbine_side.off.png",
    "yatm_steam_turbine_side.off.png",
    "yatm_steam_turbine_side.off.png",
    "yatm_steam_turbine_side.off.png"
  },
  paramtype = "none",
  paramtype2 = "facedir",
  yatm_network = steam_turbine_yatm_network,

  fluid_interface = fluid_interface,

  refresh_infotext = steam_turbine_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_steam_turbine_top.error.png",
      "yatm_steam_turbine_bottom.png",
      "yatm_steam_turbine_side.error.png",
      "yatm_steam_turbine_side.error.png",
      "yatm_steam_turbine_side.error.png",
      "yatm_steam_turbine_side.error.png"
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_steam_turbine_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.4
        },
      },
      "yatm_steam_turbine_bottom.png",
      "yatm_steam_turbine_side.on.png",
      "yatm_steam_turbine_side.on.png",
      "yatm_steam_turbine_side.on.png",
      "yatm_steam_turbine_side.on.png"
    },
  },
})
