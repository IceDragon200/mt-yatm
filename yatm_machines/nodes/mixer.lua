local mod = yatm_machines
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

local yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:mixer_error",
    error = "yatm_machines:mixer_error",
    off = "yatm_machines:mixer_off",
    on = "yatm_machines:mixer_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 100,
  },
}

function yatm_network:work(ctx)
  ctx:set_up_state("idle")
  return 0
end

local function maybe_initialize_inventory(meta)
  local inv = meta:get_inventory()

  inv:set_size("item_input", 1)
  inv:set_size("item_processing", 1)
  inv:set_size("item_output", 1)
end

local function on_construct(pos)
  yatm.devices.device_on_construct(pos)

  local meta = minetest.get_meta(pos)
  maybe_initialize_inventory(meta)
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(node_inv_name, "item_input", rect.x, rect.y, 1, 1) ..
        fspec.list(node_inv_name, "item_processing", rect.x + cio(2), rect.y, 1, 1) ..
        fspec.list(node_inv_name, "item_output", rect.x + cio(4), rect.y, 1, 1) ..
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
      return fspec.list_ring(node_inv_name, "roller_input") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(node_inv_name, "roller_output") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_machines:mixer:"..Vector3.to_string(pos)
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

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("mixer"),

  basename = mod:make_name("mixer"),

  description = mod.S("Mixer"),

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    item_interface_in = 1,
    item_interface_out = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
    yatm_energy_device = 1,
  },

  drop = yatm_network.states.off,

  tiles = {
    "yatm_mixer_top.off.png",
    "yatm_mixer_bottom.png",
    "yatm_mixer_side.off.png",
    "yatm_mixer_side.off.png^[transformFX",
    "yatm_mixer_back.png",
    "yatm_mixer_front.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = yatm_network,

  on_construct = on_construct,
  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_mixer_top.error.png",
      "yatm_mixer_bottom.png",
      "yatm_mixer_side.error.png",
      "yatm_mixer_side.error.png^[transformFX",
      "yatm_mixer_back.png",
      "yatm_mixer_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_mixer_top.on.png",
      "yatm_mixer_bottom.png",
      "yatm_mixer_side.on.png",
      "yatm_mixer_side.on.png^[transformFX",
      "yatm_mixer_back.png",
      {
        name = "yatm_mixer_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.25
        },
      },
    },
  }
})
