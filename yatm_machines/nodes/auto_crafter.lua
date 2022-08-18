local mod = yatm_machines
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)
local energy_fspec = assert(yatm.energy.formspec)
local player_service = assert(nokore.player_service)
local Vector3 = assert(foundation.com.Vector3)

local yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1, -- this is a worker module, it will consume energy to complete 'work'
    item_auto_crafter = 1,
    energy_consumer = 1,
    item_producer = 1,
    item_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:auto_crafter_error",
    error = "yatm_machines:auto_crafter_error",
    off = "yatm_machines:auto_crafter_off",
    on = "yatm_machines:auto_crafter_on",
    idle = "yatm_machines:auto_crafter_idle",
  },
  energy = {
    capacity = 4000,
    passive_lost = 0,
    network_charge_bandwidth = 1000,
    startup_threshold = 100,
  },
}

function yatm_network:work(ctx)
  return 0
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  -- local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, 8, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      return energy_fspec.render_meta_energy_gauge(
          rect.x + cis(7),
          rect.y,
          1,
          cis(4),
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
  return "yatm_machines:auto_crafter:"..Vector3.to_string(pos)
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
  item_interface_out = 1,
  item_interface_in = 1,
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("auto_crafter"),

  basename = mod:make_name("auto_crafter"),

  description = mod.S("Auto Crafter"),
  groups = groups,

  drop = yatm_network.states.off,

  tiles = {
    "yatm_auto_crafter_top.off.png",
    "yatm_auto_crafter_bottom.png",
    "yatm_auto_crafter_side.off.png",
    "yatm_auto_crafter_side.off.png^[transformFX",
    "yatm_auto_crafter_back.off.png",
    "yatm_auto_crafter_front.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = yatm_network,

  on_rightclick = on_rightclick,
}, {
  on = {
    tiles = {
      -- "yatm_auto_crafter_top.off.png",
      {
        name = "yatm_auto_crafter_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_auto_crafter_bottom.png",
      "yatm_auto_crafter_side.on.png",
      "yatm_auto_crafter_side.on.png^[transformFX",
      "yatm_auto_crafter_back.on.png",
      -- "yatm_auto_crafter_front.off.png"
      {
        name = "yatm_auto_crafter_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
    },
  },
  idle = {
    tiles = {
      "yatm_auto_crafter_top.idle.png",
      "yatm_auto_crafter_bottom.png",
      "yatm_auto_crafter_side.idle.png",
      "yatm_auto_crafter_side.idle.png^[transformFX",
      "yatm_auto_crafter_back.idle.png",
      "yatm_auto_crafter_front.idle.png",
    },
  },
  error = {
    tiles = {
      "yatm_auto_crafter_top.error.png",
      "yatm_auto_crafter_bottom.png",
      "yatm_auto_crafter_side.error.png",
      "yatm_auto_crafter_side.error.png^[transformFX",
      "yatm_auto_crafter_back.error.png",
      "yatm_auto_crafter_front.error.png",
    },
  },
})
