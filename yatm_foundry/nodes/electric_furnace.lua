local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)
local energy_fspec = assert(yatm.energy.formspec)
local player_service = assert(nokore.player_service)
local Vector3 = assert(foundation.com.Vector3)

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  -- We only really care about the integral heat, it's only a float because of the dtime.
  local heat = math.floor(meta:get_float("heat"))

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
    -- heat_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_foundry:electric_furnace_error",
    error = "yatm_foundry:electric_furnace_error",
    off = "yatm_foundry:electric_furnace_off",
    on = "yatm_foundry:electric_furnace_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 400,
  },
}

function yatm_network:work(ctx)
  return 0
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_heated" }, function (loc, rect)
    if loc == "main_body" then
      return energy_fspec.render_meta_energy_gauge(
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
  return "yatm_foundry:electric_heater:"..Vector3.to_string(pos)
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
  item_interface_in = 1,
  item_interface_out = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_foundry:electric_furnace",

  description = "Electric Furnace",

  codex_entry_id = "yatm_foundry:electric_furnace",

  groups = groups,

  drop = yatm_network.states.off,

  tiles = {
    "yatm_electric_furnace_top.off.png",
    "yatm_electric_furnace_bottom.png",
    "yatm_electric_furnace_side.off.png",
    "yatm_electric_furnace_side.off.png^[transformFX",
    "yatm_electric_furnace_back.png",
    "yatm_electric_furnace_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = yatm_network,

  refresh_infotext = refresh_infotext,

  on_construct = function (pos)
    yatm.devices.device_on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    --inv:set_size("input_slot", 1)
    --inv:set_size("processing_slot", 1)
  end,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_electric_furnace_top.error.png",
      "yatm_electric_furnace_bottom.png",
      "yatm_electric_furnace_side.error.png",
      "yatm_electric_furnace_side.error.png^[transformFX",
      "yatm_electric_furnace_back.png",
      "yatm_electric_furnace_front.error.png"
    },
  },

  on = {
    tiles = {
      "yatm_electric_furnace_top.on.png",
      "yatm_electric_furnace_bottom.png",
      "yatm_electric_furnace_side.on.png",
      "yatm_electric_furnace_side.on.png^[transformFX",
      "yatm_electric_furnace_back.png",
      "yatm_electric_furnace_front.on.png"
    },
    light_source = 7,
  },
})

