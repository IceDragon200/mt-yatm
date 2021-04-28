local FakeMetaRef = assert(foundation.com.FakeMetaRef)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local spacetime_network = assert(yatm.spacetime.network)
local SpacetimeMeta = assert(yatm.spacetime.SpacetimeMeta)

local teleporter_port_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (1 / 16) - 0.5, 0.5},
  }
}

local function teleporter_port_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "S.Address: " .. SpacetimeMeta.to_infotext(meta)

  meta:set_string("infotext", infotext)
end

local function teleporter_port_after_place_node(pos, placer, itemstack, pointed_thing)
  print("teleporter_port_after_place_node/4")
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()

  SpacetimeMeta.copy_address(old_meta, new_meta)
  local address = SpacetimeMeta.patch_address(new_meta)
  local node = minetest.get_node(pos)
  spacetime_network:maybe_register_node(pos, node)

  yatm.devices.device_after_place_node(pos, placer, itemstack, pointed_thing)

  yatm.queue_refresh_infotext(pos, node)

  minetest.after(0, mesecon.on_placenode, pos, node)
end

local function teleporter_port_on_destruct(pos)
  print("teleporter_port_on_destruct/1")
  spacetime_network:unregister_device(pos)
  yatm.devices.device_on_destruct(pos)
end

local function teleporter_port_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = FakeMetaRef:new(old_meta_table)
  local new_meta = stack:get_meta()
  SpacetimeMeta.copy_address(old_meta, new_meta)
end

--
-- Ports are teleporter destinations, by themselves they don't actually do any teleporting.
--
local teleporter_port_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter_port = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_spacetime:teleporter_port_error",
    error = "yatm_spacetime:teleporter_port_error",
    off = "yatm_spacetime:teleporter_port_off",
    on = "yatm_spacetime:teleporter_port_on",
    inactive = "yatm_spacetime:teleporter_port_inactive",
  },
  energy = {
    capacity = 100,
    passive_lost = 5,
    network_charge_bandwidth = 10,
    startup_threshold = 20,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_spacetime:teleporter_port",

  description = "Teleporter Port",

  codex_entry_id = "yatm_spacetime:teleporter_port",

  groups = {
    cracky = 1,
    spacetime_device = 1,
    addressable_spacetime_device = 1
  },

  drop = teleporter_port_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_port_top.off.png",
    "yatm_teleporter_port_bottom.png",
    "yatm_teleporter_port_side.off.png",
    "yatm_teleporter_port_side.off.png^[transformFX",
    "yatm_teleporter_port_side.off.png",
    "yatm_teleporter_port_side.off.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_port_node_box,

  refresh_infotext = teleporter_port_refresh_infotext,

  yatm_network = teleporter_port_yatm_network,
  yatm_spacetime = {},

  after_place_node = teleporter_port_after_place_node,
  on_destruct = teleporter_port_on_destruct,
  preserve_metadata = teleporter_port_preserve_metadata,
}, {
  error = {
    tiles = {
      "yatm_teleporter_port_top.error.png",
      "yatm_teleporter_port_bottom.png",
      "yatm_teleporter_port_side.error.png",
      "yatm_teleporter_port_side.error.png^[transformFX",
      "yatm_teleporter_port_side.error.png",
      "yatm_teleporter_port_side.error.png",
    },
  },
  inactive = {
    tiles = {
      "yatm_teleporter_port_top.inactive.png",
      "yatm_teleporter_port_bottom.png",
      "yatm_teleporter_port_side.inactive.png",
      "yatm_teleporter_port_side.inactive.png^[transformFX",
      "yatm_teleporter_port_side.inactive.png",
      "yatm_teleporter_port_side.inactive.png",
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_teleporter_port_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_teleporter_port_bottom.png",
      "yatm_teleporter_port_side.on.png",
      "yatm_teleporter_port_side.on.png^[transformFX",
      "yatm_teleporter_port_side.on.png",
      "yatm_teleporter_port_side.on.png",
    },

    yatm_spacetime = {
      groups = {
        player_teleporter_destination = 1,
      },
    },
  }
})

local teleporter_port_data_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter_port = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_spacetime:teleporter_port_data_error",
    error = "yatm_spacetime:teleporter_port_data_error",
    off = "yatm_spacetime:teleporter_port_data_off",
    on = "yatm_spacetime:teleporter_port_data_on",
    inactive = "yatm_spacetime:teleporter_port_data_inactive",
  },
  energy = {
    capacity = 100,
    passive_lost = 5,
    network_charge_bandwidth = 10,
    startup_threshold = 20,
  },
}

--
-- DATA Variant of the Teleporter Port
--
yatm.devices.register_stateful_network_device({
  basename = "yatm_spacetime:teleporter_port_data",

  description = "Teleporter Port [DATA]",

  codex_entry_id = "yatm_spacetime:teleporter_port_data",

  groups = {
    cracky = 1,
    spacetime_device = 1,
    addressable_spacetime_device = 1,
    yatm_data_device = 1,
  },

  drop = teleporter_port_data_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_port_top.data.off.png",
    "yatm_teleporter_port_bottom.png",
    "yatm_teleporter_port_side.off.png",
    "yatm_teleporter_port_side.off.png^[transformFX",
    "yatm_teleporter_port_side.off.png",
    "yatm_teleporter_port_side.off.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_port_node_box,

  refresh_infotext = teleporter_port_refresh_infotext,

  yatm_network = teleporter_port_data_yatm_network,
  yatm_spacetime = {},

  after_place_node = teleporter_port_after_place_node,
  on_destruct = teleporter_port_on_destruct,
  preserve_metadata = teleporter_port_preserve_metadata,
}, {
  error = {
    tiles = {
      "yatm_teleporter_port_top.data.error.png",
      "yatm_teleporter_port_bottom.png",
      "yatm_teleporter_port_side.error.png",
      "yatm_teleporter_port_side.error.png^[transformFX",
      "yatm_teleporter_port_side.error.png",
      "yatm_teleporter_port_side.error.png",
    },
  },
  inactive = {
    tiles = {
      "yatm_teleporter_port_top.data.inactive.png",
      "yatm_teleporter_port_bottom.png",
      "yatm_teleporter_port_side.inactive.png",
      "yatm_teleporter_port_side.inactive.png^[transformFX",
      "yatm_teleporter_port_side.inactive.png",
      "yatm_teleporter_port_side.inactive.png",
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_teleporter_port_top.data.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_teleporter_port_bottom.png",
      "yatm_teleporter_port_side.on.png",
      "yatm_teleporter_port_side.on.png^[transformFX",
      "yatm_teleporter_port_side.on.png",
      "yatm_teleporter_port_side.on.png",
    },

    yatm_spacetime = {
      groups = {
        player_teleporter_destination = 1,
      },
    },
  }
})
