local mod = yatm_machines
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

local crystal_cauldron_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
    fluid_consumer = 1,
    fluid_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:crystal_cauldron_error",
    error = "yatm_machines:crystal_cauldron_error",
    idle = "yatm_machines:crystal_cauldron_idle",
    off = "yatm_machines:crystal_cauldron_off",
    on = "yatm_machines:crystal_cauldron_on",
  },
  energy = {
    passive_lost = 50,
    capacity = 12000,
    startup_threshold = 1000,
    network_charge_bandwidth = 2000,
  },
}

function crystal_cauldron_yatm_network:work(ctx)
  ctx:set_up_state("idle")
  return 0
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine" }, function (loc, rect)
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
  return "yatm_machines:crystal_cauldron:"..Vector3.to_string(pos)
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

local crysytal_cauldron_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.375, -0.5, 0.5, 0.5, -0.375}, -- NodeBox1
    {-0.5, -0.375, 0.375, 0.5, 0.5, 0.5}, -- NodeBox2
    {-0.5, -0.375, -0.375, -0.375, 0.5, 0.375}, -- NodeBox3
    {0.375, -0.375, -0.375, 0.5, 0.5, 0.375}, -- NodeBox4
    {-0.5, -0.375, -0.5, 0.5, -0.1875, 0.5}, -- NodeBox5
    {-0.5, -0.5, -0.5, -0.375, -0.375, -0.375}, -- NodeBox6
    {0.375, -0.5, -0.5, 0.5, -0.375, -0.375}, -- NodeBox8
    {-0.5, -0.5, 0.375, -0.375, -0.375, 0.5}, -- NodeBox9
    {0.375, -0.5, 0.375, 0.5, -0.375, 0.5}, -- NodeBox10
  }
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("crystal_cauldron"),

  basename = mod:make_name("crystal_cauldron"),

  description = mod.S("Crystal Cauldron"),

  groups =  {
    cracky = nokore.dig_class("copper"),
    item_interface_in = 1,
    item_interface_out = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
  },

  drop = crystal_cauldron_yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_crystal_cauldron_top.png",
    "yatm_crystal_cauldron_bottom.png",
    "yatm_crystal_cauldron_side.off.png",
    "yatm_crystal_cauldron_side.off.png",
    "yatm_crystal_cauldron_side.off.png",
    "yatm_crystal_cauldron_side.off.png",
  },
  drawtype = "nodebox",
  node_box = crysytal_cauldron_node_box,

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = crystal_cauldron_yatm_network,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_crystal_cauldron_top.png",
      "yatm_crystal_cauldron_bottom.png",
      "yatm_crystal_cauldron_side.error.png",
      "yatm_crystal_cauldron_side.error.png",
      "yatm_crystal_cauldron_side.error.png",
      "yatm_crystal_cauldron_side.error.png",
    },
  },
  idle = {
    tiles = {
      "yatm_crystal_cauldron_top.png",
      "yatm_crystal_cauldron_bottom.png",
      "yatm_crystal_cauldron_side.idle.png",
      "yatm_crystal_cauldron_side.idle.png",
      "yatm_crystal_cauldron_side.idle.png",
      "yatm_crystal_cauldron_side.idle.png",
    },
  },
  on = {
    tiles = {
      "yatm_crystal_cauldron_top.png",
      "yatm_crystal_cauldron_bottom.png",
      "yatm_crystal_cauldron_side.on.png",
      "yatm_crystal_cauldron_side.on.png",
      "yatm_crystal_cauldron_side.on.png",
      "yatm_crystal_cauldron_side.on.png",
    },
  },
})
