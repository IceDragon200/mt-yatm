local mod = yatm_machines
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local yatm_network = {
  kind = "energy_producer",
  groups = {
    device_controller = 3,
    item_consumer = 1,
    energy_producer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:coal_generator_error",
    error = "yatm_machines:coal_generator_error",
    idle = "yatm_machines:coal_generator_idle",
    off = "yatm_machines:coal_generator_off",
    on = "yatm_machines:coal_generator_on",
  },
  energy = {
    capacity = 8000,
  }
}

function yatm_network.energy.produce_energy(pos, node, dtime, ot)
  return 0
end

function yatm_network.update(pos, node, ot)
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_electric" }, function (loc, rect)
    if loc == "main_body" then
      return yatm_fspec.render_meta_energy_gauge(
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
  return "yatm_machines:coal_generator:"..Vector3.to_string(pos)
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
  yatm_energy_device = 1,
  item_interface_in = 1,
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("coal_generator"),

  basename = mod:make_name("coal_generator"),

  description = mod.S("Coal Generator"),
  groups = groups,

  drop = yatm_network.states.off,

  tiles = {
    "yatm_coal_generator_top.off.png",
    "yatm_coal_generator_bottom.png",
    "yatm_coal_generator_side.off.png",
    "yatm_coal_generator_side.off.png",
    "yatm_coal_generator_back.off.png",
    "yatm_coal_generator_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = yatm_network,

  refresh_infotext = refresh_infotext,

  on_rightclick = on_rightclick,
}, {
  on = {
    tiles = {
      --"yatm_coal_generator_top.on.png",
      {
        name = "yatm_coal_generator_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_coal_generator_bottom.png",
      "yatm_coal_generator_side.on.png",
      "yatm_coal_generator_side.on.png",
      "yatm_coal_generator_back.on.png",
      "yatm_coal_generator_front.on.png"
    },
  },
  idle = {
    tiles = {
      "yatm_coal_generator_top.idle.png",
      "yatm_coal_generator_bottom.png",
      "yatm_coal_generator_side.idle.png",
      "yatm_coal_generator_side.idle.png",
      "yatm_coal_generator_back.idle.png",
      "yatm_coal_generator_front.idle.png"
    },
  },
  error = {
    tiles = {
      "yatm_coal_generator_top.error.png",
      "yatm_coal_generator_bottom.png",
      "yatm_coal_generator_side.error.png",
      "yatm_coal_generator_side.error.png",
      "yatm_coal_generator_back.error.png",
      "yatm_coal_generator_front.error.png"
    },
  },
})
