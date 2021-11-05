--
-- Inventory DSCS Monitor
--
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)

local groups = {
  cracky = 1,
  monitor = 1,
  yatm_energy_device = 1,
  yatm_network_device = 1,
}

local function get_formspec_name(pos)
  return "yatm_dscs:drive_case:" .. minetest.pos_to_string(pos)
end

local function get_formspec(pos, user, assigns)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos

  assigns.tab = assigns.tab or 1

  return yatm.formspec_render_split_inv_panel(user, 2, 4, { bg = "dscs" }, function (loc, rect)
    if loc == "header" then
      return fspec.tabheader(0, 0, nil, nil, "tab", { "Items", "Fluids" }, assigns.tab)
    elseif loc == "main_body" then
      return fspec.list(node_inv_name, "drive_bay", rect.x, rect.y, 2, 4)
    elseif loc == "footer" then
      return fspec.list_ring(node_inv_name, "drive_bay") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    "Inventory Monitor\n" ..
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. " [" .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "]\n"

  meta:set_string("infotext", infotext)
end

local function receive_fields(player, formname, fields, assigns)
  local needs_refresh = false

  -- TODO: do stuff

  return true
end

local function on_rightclick(pos, node, user, item_stack, pointed_thing)
  local assigns = { pos = pos, node = node }
  local formspec = get_formspec(pos, user, assigns)
  local formspec_name = get_formspec_name(pos)

  nokore.formspec_bindings:show_formspec(user:get_player_name(), formspec_name, formspec, {
    state = assigns,
    on_receive_fields = receive_fields
  })
end

local monitor_inventory_yatm_network = {
  basename = "yatm_dscs:monitor_inventory",
  kind = "monitor",
  groups = {
    monitor = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_dscs:monitor_inventory_error",
    conflict = "yatm_dscs:monitor_inventory_error",
    off = "yatm_dscs:monitor_inventory_off",
    on = "yatm_dscs:monitor_inventory_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 100,
    passive_lost = 1,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:monitor_ele",

  codex_entry_id = "yatm_dscs:inventory_monitor",
  description = "Monitor (inventory)",

  groups = groups,

  drop = monitor_inventory_yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.inventory.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  on_rightclick = on_rightclick,

  yatm_network = monitor_inventory_yatm_network,

  refresh_infotext = refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_monitor_top.png",
      "yatm_monitor_bottom.png",
      "yatm_monitor_side.png",
      "yatm_monitor_side.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.inventory.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_monitor_top.png",
      "yatm_monitor_bottom.png",
      "yatm_monitor_side.png",
      "yatm_monitor_side.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.inventory.on.png",
    },
  }
})

--
-- Inventory Monitor
--
local flat_monitor_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, 0.25, 0.5, 0.5, 0.5}, -- NodeBox1
  }
}

local flat_monitor_inventory_yatm_network = {
  kind = "monitor",
  groups = {
    monitor = 1,
    inventory_monitor = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_dscs:flat_monitor_inventory_error",
    conflict = "yatm_dscs:flat_monitor_inventory_error",
    off = "yatm_dscs:flat_monitor_inventory_off",
    on = "yatm_dscs:flat_monitor_inventory_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 100,
    passive_lost = 10,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:flat_monitor_inventory",

  codex_entry_id = "yatm_dscs:monitor_inventory",
  description = "Flat Monitor (inventory)",

  groups = groups,

  drop = flat_monitor_inventory_yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.inventory.off.png",
  },

  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  on_rightclick = on_rightclick,

  yatm_network = flat_monitor_inventory_yatm_network,

  refresh_infotext = refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_monitor_top.flat.png",
      "yatm_monitor_bottom.flat.png",
      "yatm_monitor_side.flat.png",
      "yatm_monitor_side.flat.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.inventory.error.png",
    },
  },

  on = {
    tiles = {
      "yatm_monitor_top.flat.png",
      "yatm_monitor_bottom.flat.png",
      "yatm_monitor_side.flat.png",
      "yatm_monitor_side.flat.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.inventory.on.png",
    },
  },
})
