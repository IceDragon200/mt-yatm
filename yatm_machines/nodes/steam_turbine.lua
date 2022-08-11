local fspec = assert(foundation.com.formspec.api)
local fluid_fspec = assert(yatm.fluids.formspec)
local Groups = assert(foundation.com.Groups)
local Directions = assert(foundation.com.Directions)
local table_merge = assert(foundation.com.table_merge)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidStack = assert(yatm.fluids.FluidStack)
local Vector3 = assert(foundation.com.Vector3)

--
-- Steam turbines produce energy by consuming steam, they have the byproduct of water which can be cycled again into a boiler.
--
local yatm_network = {
  kind = "energy_producer",
  groups = {
    energy_producer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:steam_turbine_error",
    error = "yatm_machines:steam_turbine_error",
    idle = "yatm_machines:steam_turbine_idle",
    off = "yatm_machines:steam_turbine_off",
    on = "yatm_machines:steam_turbine_on",
  },
  energy = {
    capacity = 4000,
  },
}

local TANK_CAPACITY = 16000
local WATER_TANK = "water_tank"
local STEAM_TANK = "steam_tank"
local function get_fluid_tank_name(_self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)

  if new_dir == Directions.D_DOWN then
    return WATER_TANK, TANK_CAPACITY
  elseif new_dir == Directions.D_EAST or
         new_dir == Directions.D_WEST or
         new_dir == Directions.D_NORTH or
         new_dir == Directions.D_SOUTH then
    return STEAM_TANK, TANK_CAPACITY
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface._private.capacity = TANK_CAPACITY

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local water_tank_fluid_stack = FluidMeta.get_fluid_stack(meta, WATER_TANK)
  local steam_tank_fluid_stack = FluidMeta.get_fluid_stack(meta, STEAM_TANK)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Water Tank: " .. FluidStack.pretty_format(water_tank_fluid_stack, TANK_CAPACITY) .. "\n" ..
    "Steam Tank: " .. FluidStack.pretty_format(steam_tank_fluid_stack, TANK_CAPACITY)

  meta:set_string("infotext", infotext)
end

function yatm_network.energy.produce_energy(pos, node, dtime, ot)
  local need_refresh = false
  local energy_produced = 0
  local meta = minetest.get_meta(pos)
  local drained_stack, new_amount =
    FluidMeta.drain_fluid(
      meta,
      STEAM_TANK,
      FluidStack.new("group:steam", 100),
      TANK_CAPACITY,
      TANK_CAPACITY,
      false
    )

  if drained_stack and drained_stack.amount > 0 then
    local water_from_steam = FluidStack.new("default:water", drained_stack.amount / 2)
    local filled_stack, new_amount = FluidMeta.fill_fluid(meta,
      WATER_TANK,
      water_from_steam,
      TANK_CAPACITY,
      TANK_CAPACITY,
      true
    )

    if filled_stack then
      local stack, new_amount = FluidMeta.drain_fluid(meta,
        STEAM_TANK,
        drained_stack,
        TANK_CAPACITY,
        TANK_CAPACITY,
        true
      )

      need_refresh = true
      energy_produced = energy_produced +  filled_stack.amount
    end
  end
  if need_refresh then
    yatm.queue_refresh_infotext(pos, node)
  end
  return energy_produced
end

function yatm_network.update(pos, node, ot)
  local need_refresh = false
  local new_dir
  local npos
  local nnode
  local nnodedef
  local target_dir
  local stack
  local filled_stack

  local tank_drain_fluid = FluidTanks.drain_fluid
  local tank_fill_fluid = FluidTanks.fill_fluid

  for _, dir in ipairs(Directions.DIR4) do
    new_dir = Directions.facedir_to_face(node.param2, dir)

    npos = vector.add(pos, Directions.DIR6_TO_VEC3[new_dir])
    nnode = minetest.get_node(npos)
    nnodedef = minetest.registered_nodes[nnode.name]
    if nnodedef then
      if Groups.get_item(nnodedef, "fluid_tank") then
        target_dir = Directions.invert_dir(new_dir)
        stack = tank_drain_fluid(npos, target_dir, FluidStack.new("group:steam", 200), false)
        if stack then
          filled_stack = tank_fill_fluid(pos, new_dir, stack, true)
          if filled_stack then
            tank_drain_fluid(npos, target_dir, filled_stack, true)
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
      TANK_CAPACITY, TANK_CAPACITY, false)
    -- Was any water drained?
    if stack then
      local tank_dir = Directions.facedir_to_face(node.param2, Directions.D_DOWN)
      local tank_pos = vector.add(pos, Directions.DIR6_TO_VEC3[tank_dir])
      local tank_node = minetest.get_node(tank_pos)
      local tank_nodedef = minetest.registered_nodes[tank_node.name]
      if tank_nodedef then
        if Groups.get_item(tank_nodedef, "fluid_tank") then
          local drained_stack, new_amount = FluidTanks.fill_fluid(tank_pos, Directions.invert_dir(tank_dir), stack, true)
          if drained_stack and drained_stack.amount > 0 then
            FluidMeta.drain_fluid(meta,
              WATER_TANK,
              FluidStack.set_amount(stack, drained_stack.amount),
              TANK_CAPACITY, TANK_CAPACITY, true)
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

local function render_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, 8, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      local steam_stack = FluidMeta.get_fluid_stack(meta, STEAM_TANK)
      local water_stack = FluidMeta.get_fluid_stack(meta, WATER_TANK)

      return fluid_fspec.render_fluid_stack(rect.x, rect.y, 1, cio(4), steam_stack, TANK_CAPACITY) ..
        fluid_fspec.render_fluid_stack(rect.x + cio(7), rect.y, 1, cio(4), water_stack, TANK_CAPACITY)
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)

end

local function make_formspec_name(pos)
  return "yatm_machines:steam_turbine:"..Vector3.to_string(pos)
end

local function on_rightclick(pos, node, user)
  local state = {}
  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
    }
  )
end

local groups = {
  cracky = 1,
  device_cluster_controller = 2,
  fluid_interface_in = 1,
  fluid_interface_out = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_machines:steam_turbine",

  basename = "yatm_machines:steam_turbine",

  description = "Steam Turbine",

  groups = groups,

  drop = yatm_network.states.off,

  sounds = yatm.node_sounds:build("metal"),

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
  yatm_network = yatm_network,

  fluid_interface = fluid_interface,

  refresh_infotext = refresh_infotext,

  on_rightclick = on_rightclick,
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
  error = {
    tiles = {
      "yatm_steam_turbine_top.idle.png",
      "yatm_steam_turbine_bottom.png",
      "yatm_steam_turbine_side.idle.png",
      "yatm_steam_turbine_side.idle.png",
      "yatm_steam_turbine_side.idle.png",
      "yatm_steam_turbine_side.idle.png"
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
