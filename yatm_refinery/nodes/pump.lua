local fspec = assert(foundation.com.formspec.api)
local fluid_fspec = assert(yatm.fluids.formspec)
local Directions = assert(foundation.com.Directions)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local FluidStack = assert(yatm.fluids.FluidStack)
local fluid_registry = assert(yatm.fluids.fluid_registry)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local Energy = assert(yatm.energy)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

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
local TANK_CAPACITY = 16000
local fluid_interface = yatm.fluids.FluidInterface.new_simple(TANK_NAME, TANK_CAPACITY)

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
    return nil, "incorrect pumping direction"
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
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Tank: " .. FluidStack.pretty_format(fluid_stack, capacity)

  meta:set_string("infotext", infotext)
end

function pump_yatm_network:work(ctx)
  local meta = ctx.meta
  local pos = ctx.pos
  local node = ctx.node
  local nodedef = ctx.nodedef

  local energy_consumed = 0

  local pump_dir = Directions.facedir_to_face(node.param2, Directions.D_DOWN)
  local target_pos = vector.add(pos, Directions.DIR6_TO_VEC3[pump_dir])
  local target_node = minetest.get_node(target_pos)
  local fluid_name = fluid_registry.item_name_to_fluid_name(target_node.name)

  local capacity = nodedef.fluid_interface._private.capacity

  if fluid_name then
    -- try filling internal tank with fluid from node
    local used_stack = FluidMeta.fill_fluid(meta, TANK_NAME, FluidStack.new(fluid_name, 1000), capacity, capacity, true)
    if used_stack and used_stack.amount > 0 then
      energy_consumed = energy_consumed + math.floor(100 * used_stack.amount / 1000)
      minetest.remove_node(target_pos)
    end
  else
    -- try extracting fluid from connected node
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
    local stack = FluidMeta.drain_fluid(
      meta,
      TANK_NAME,
      FluidStack.new_wildcard(1000),
      capacity,
      capacity,
      false
    )

    if stack and stack.amount > 0 then
      local target_dir = Directions.invert_dir(new_dir)
      local filled_stack = FluidTanks.fill_fluid(target_pos, target_dir, stack, true)
      if filled_stack and filled_stack.amount > 0 then
        energy_consumed = energy_consumed + math.floor(100 * filled_stack.amount / 1000)
        FluidMeta.drain_fluid(
          meta,
          TANK_NAME,
          filled_stack,
          capacity,
          capacity,
          true
        )
      end
    end
  end

  return energy_consumed
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  -- local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, 8, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      local fluid_tank = FluidMeta.get_fluid_stack(meta, TANK_NAME)

      return fluid_fspec.render_fluid_stack(rect.x, rect.y, 1, cis(4), fluid_tank, TANK_CAPACITY)
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_machines:pump:"..Vector3.to_string(pos)
end

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, user)
  local state = {
    pos = pos,
  }
  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
      timers = {
        -- steam turbines have a fluid tank, so their formspecs need to be routinely updated
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
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

  on_rightclick = on_rightclick,
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
