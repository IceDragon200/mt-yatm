--
-- Inventory Controller
--
-- Inventory controllers are required in a yatm network to store recipes
-- And management automatic crafting, the node in question will remember
-- all active requests.
local Energy = assert(yatm.energy)
local Vector3 = assert(foundation.com.Vector3)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)

local inventory_controller_yatm_network = {
  kind = "machine",
  groups = {
    energy_consumer = 1,
    dscs_inventory_controller = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:inventory_controller_error",
    error = "yatm_dscs:inventory_controller_error",
    idle = "yatm_dscs:inventory_controller_idle",
    off = "yatm_dscs:inventory_controller_off",
    on = "yatm_dscs:inventory_controller_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 10,
    network_charge_bandwidth = 100,
  },
  dscs = {
    inventory_controller = {
      max_children = 6,
      child_key_prefix = "ivc_child_",
    },
  },
}

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    "Inventory Controller\n" ..
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

-- @spec.private render_formspec(pos: Vector3, user: PlayerRef, state: Table): String
local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "dscs" }, function (loc, rect)
    if loc == "main_body" then
      return yatm.dscs.formspec.render_inventory_controller_children_at{
          pos = pos,
          node = state.node,
          x = rect.x,
          y = rect.y,
          cols = 2,
          rows = 3
        } ..
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
      return fspec.list_ring(node_inv_name, "drive_bay") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)
  local inv = meta:get_inventory()
  local needs_refresh = false

  -- TODO: do stuff

  return true
end

local function make_formspec_name(pos)
  return "yatm_dscs:inventory_controller:" .. minetest.pos_to_string(pos)
end

local function refresh_formspec(pos, _player)
  nokore.formspec_bindings:trigger_form_timer(make_formspec_name(pos), "refresh")
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

--- @spec.private on_rightclick(
---   pos: Vector3,
---   node: NodeRef,
---   user: PlayerRef,
---   item_stack: ItemStack,
---   pointed_thing: PointedThing
--- ): void
local function on_rightclick(pos, node, user, item_stack, pointed_thing)
  local state = {
    pos = pos,
    node = node
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
  cracky = nokore.dig_class("copper"),
  --
  yatm_network_device = 1,
  yatm_energy_device = 1,
  yatm_inventory_controller = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:inventory_controller",

  codex_entry_id = "yatm_dscs:inventory_controller",
  description = "Inventory Controller",

  groups = groups,

  drop = inventory_controller_yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_inventory_controller_side.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = inventory_controller_yatm_network,

  refresh_infotext = refresh_infotext,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {"yatm_inventory_controller_side.error.png"},
  },
  idle = {
    tiles = {"yatm_inventory_controller_side.idle.png"},
  },
  on = {
    tiles = {
      {
        name = "yatm_inventory_controller_side.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
    },
  },
})
