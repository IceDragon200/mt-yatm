--[[

  RTGs produce energy passively for free, you just need to secure the radioactive material to craft
  it in the first place.

]]
local mod = assert(yatm_reactors)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)
local device_swap_node_by_state = assert(yatm.devices.device_swap_node_by_state)

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local burn_time = meta:get_float("burn_time")
  local burn_time_max = meta:get_float("burn_time_max")

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Burn Time: " .. math.floor(burn_time) .. " / " .. math.floor(burn_time_max) .. "\n" ..
    "EN/t: " .. meta:get_float("last_energy_produced")

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
    conflict = mod:make_name("rtg_error"),
    error = mod:make_name("rtg_error"),
    off = mod:make_name("rtg_off"),
    on = mod:make_name("rtg_on"),
  },
  energy = {
    capacity = 8000,
  }
}

--- @spec energy.produce_energy(
---   pos: Vector3,
---   node: NodeRef,
---   dtime: Float,
---   trace: Trace
--- ): (energy: Number)
function yatm_network.energy.produce_energy(pos, node, dtime, trace)
  local meta = minetest.get_meta(pos)

  --- RTGs produce a fixed amount of energy per-second
  local en_amount = 10 * dtime

  meta:set_float("last_energy_produced", en_amount)

  yatm.queue_refresh_infotext(pos, node)

  return en_amount
end

--- @spec update(pos: Vector3, node: NodeRef, dtime: Float, trace: Trace): void
function yatm_network.update(pos, node, dtime, trace)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  if inv:is_empty("fuel_slot") or meta:get_float("burn_time_max") <= 0 then
    device_swap_node_by_state(pos, node, "idle")
  else
    device_swap_node_by_state(pos, node, "on")
  end

  --
end

local function maybe_initialize_inventory(meta)
  local inv = meta:get_inventory()

  inv:set_size("fuel_slot", 1)
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)

  maybe_initialize_inventory(meta)
end

--- @spec.private render_formspec(pos: Vector3, user: PlayerRef, state: Table): String
local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_electric" }, function (loc, rect)
    if loc == "main_body" then
      return ""
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
  return "yatm_reactors:rtg:"..Vector3.to_string(pos)
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
  local meta = minetest.get_meta(pos)
  local formspec = render_formspec(pos, user, state)

  maybe_initialize_inventory(meta)

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
  cracky = nokore.dig_class("copper"),
  --
  yatm_energy_device = 1,
  item_interface_in = 1,
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("rtg"),

  basename = mod:make_name("rtg"),

  description = mod.S("RTG"),
  groups = groups,

  drop = yatm_network.states.off,

  tiles = {
    "yatm_rtg_top.off.png",
    "yatm_rtg_bottom.png",
    "yatm_rtg_side.off.png",
    "yatm_rtg_side.off.png",
    "yatm_rtg_back.off.png",
    "yatm_rtg_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = yatm_network,

  refresh_infotext = refresh_infotext,

  on_construct = on_construct,
  on_rightclick = on_rightclick,
}, {
  on = {
    tiles = {
      --"yatm_rtg_top.on.png",
      {
        name = "yatm_rtg_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_rtg_bottom.png",
      "yatm_rtg_side.on.png",
      "yatm_rtg_side.on.png",
      "yatm_rtg_back.on.png",
      "yatm_rtg_front.on.png"
    },
  },
  error = {
    tiles = {
      "yatm_rtg_top.error.png",
      "yatm_rtg_bottom.png",
      "yatm_rtg_side.error.png",
      "yatm_rtg_side.error.png",
      "yatm_rtg_back.error.png",
      "yatm_rtg_front.error.png"
    },
  },
})
