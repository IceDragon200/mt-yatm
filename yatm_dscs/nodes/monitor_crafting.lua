--
-- Various DSCS Crafting Monitors
--
local table_merge = assert(foundation.com.table_merge)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    "Monitor\n" ..
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  monitor = 1,
  crafting_monitor = 1,
  yatm_dscs_device = 1,
  yatm_energy_device = 1,
  yatm_network_device = 1,
}

--[[

]]
local monitor_crafting_yatm_network = {
  basename = "yatm_dscs:monitor_crafting",

  kind = "monitor",

  groups = {
    monitor = 1,
    energy_consumer = 1,
  },

  default_state = "off",

  states = {
    error = "yatm_dscs:monitor_crafting_error",
    conflict = "yatm_dscs:monitor_crafting_error",
    off = "yatm_dscs:monitor_crafting_off",
    on = "yatm_dscs:monitor_crafting_on",
  },

  energy = {
    capacity = 4000,
    network_charge_bandwidth = 100,
    passive_lost = 1,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:monitor_crafting",

  codex_entry_id = "yatm_dscs:monitor_crafting",
  description = "Monitor (crafting)",

  groups = table_merge(groups, {}),

  drop = monitor_crafting_yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.crafting.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = monitor_crafting_yatm_network,

  refresh_infotext = refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_monitor_top.png",
      "yatm_monitor_bottom.png",
      "yatm_monitor_side.png",
      "yatm_monitor_side.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.crafting.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_monitor_top.png",
      "yatm_monitor_bottom.png",
      "yatm_monitor_side.png",
      "yatm_monitor_side.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.crafting.on.png",
    },
  }
})


local monitor_crafting_yatm_network = {
  kind = "monitor",
  groups = {
    monitor = 1,
    crafting_monitor = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_dscs:flat_monitor_crafting_error",
    conflict = "yatm_dscs:flat_monitor_crafting_error",
    off = "yatm_dscs:flat_monitor_crafting_off",
    on = "yatm_dscs:flat_monitor_crafting_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 100,
    passive_lost = 10,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:flat_monitor_crafting",

  codex_entry_id = "yatm_dscs:flat_monitor",
  description = "Flat Monitor (crafting)",

  groups = table_merge(groups, {}),

  drop = monitor_crafting_yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.crafting.off.png",
  },
  drawtype = "nodebox",
  node_box = yatm.dscs.make_flat_monitor_node_box(),

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = monitor_crafting_yatm_network,

  refresh_infotext = refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_monitor_top.flat.png",
      "yatm_monitor_bottom.flat.png",
      "yatm_monitor_side.flat.png",
      "yatm_monitor_side.flat.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.crafting.error.png",
    },
  },

  on = {
    tiles = {
      "yatm_monitor_top.flat.png",
      "yatm_monitor_bottom.flat.png",
      "yatm_monitor_side.flat.png",
      "yatm_monitor_side.flat.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.crafting.on.png",
    },
  }
})
