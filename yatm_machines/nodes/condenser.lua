--[[

  Condensers turn gases into liquids, primarily steam back into water.

]]
local mod = yatm_machines
local Directions = assert(foundation.com.Directions)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

local condenser_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:condenser_error",
    error = "yatm_machines:condenser_error",
    idle = "yatm_machines:condenser_idle",
    off = "yatm_machines:condenser_off",
    on = "yatm_machines:condenser_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 200,
    passive_lost = 50,
    startup_threshold = 100,
  }
}

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local LIQUID_TANK_NAME = "liquid_tank"
local GAS_TANK_NAME = "gas_tank"
local TANK_CAPACITY = 16000

local function get_fluid_tank_name(_self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_DOWN then
    return LIQUID_TANK_NAME, capacity
  elseif new_dir == Directions.D_UP or
         new_dir == Directions.D_EAST or
         new_dir == Directions.D_WEST or
         new_dir == Directions.D_NORTH or
         new_dir == Directions.D_SOUTH then
    return GAS_TANK_NAME, capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)

function condenser_yatm_network:work(ctx)
  local pos = ctx.pos
  local meta = ctx.meta
  local node = ctx.node

  local gas_fluid_stack = FluidMeta.get_fluid_stack(meta, GAS_TANK_NAME)
  return 0
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_cooled" }, function (loc, rect)
    if loc == "main_body" then
      local gas_stack = FluidMeta.get_fluid_stack(meta, GAS_TANK_NAME)
      local liquid_stack = FluidMeta.get_fluid_stack(meta, LIQUID_TANK_NAME)

      return yatm_fspec.render_fluid_stack(
          rect.x,
          rect.y,
          1,
          rect.h,
          gas_stack,
          TANK_CAPACITY
        ) ..
        yatm_fspec.render_fluid_stack(
          rect.x + cio(1),
          rect.y,
          1,
          rect.h,
          liquid_stack,
          TANK_CAPACITY
        ) ..
        yatm_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cio(1),
          rect.y,
          1,
          rect.h,
          meta,
          yatm.devices.ENERGY_BUFFER_KEY,
          yatm.devices.get_energy_capacity(pos, state.node)
        )
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
  return "yatm_machines:condenser:"..Vector3.to_string(pos)
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
    node = node,
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
        -- routinely update the formspec
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
end

local groups = {
  cracky = 1,
  fluid_interface_in = 1,
  fluid_interface_out = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = mod:make_name("condenser"),

  codex_entry_id = mod:make_name("condenser"),

  description = mod.S("Condenser"),

  groups = groups,

  drop = condenser_yatm_network.states.off,

  tiles = {
    "yatm_condenser_top.off.png",
    "yatm_condenser_bottom.off.png",
    "yatm_condenser_side.off.png",
    "yatm_condenser_side.off.png^[transformFX",
    "yatm_condenser_back.off.png",
    "yatm_condenser_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = condenser_yatm_network,

  fluid_interface = fluid_interface,

  refresh_infotext = refresh_infotext,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_condenser_top.error.png",
      "yatm_condenser_bottom.error.png",
      "yatm_condenser_side.error.png",
      "yatm_condenser_side.error.png^[transformFX",
      "yatm_condenser_back.error.png",
      "yatm_condenser_front.error.png"
    },
  },
  idle = {
    tiles = {
      "yatm_condenser_top.idle.png",
      "yatm_condenser_bottom.idle.png",
      "yatm_condenser_side.idle.png",
      "yatm_condenser_side.idle.png^[transformFX",
      "yatm_condenser_back.idle.png",
      "yatm_condenser_front.idle.png"
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_condenser_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.4
        },
      },
      "yatm_condenser_bottom.on.png",
      "yatm_condenser_side.on.png",
      "yatm_condenser_side.on.png^[transformFX",
      {
        name = "yatm_condenser_back.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.4
        },
      },
      "yatm_condenser_front.on.png"
    },
  }
})
