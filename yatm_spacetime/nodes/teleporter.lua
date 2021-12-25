local FakeMetaRef = assert(foundation.com.FakeMetaRef)
local list_sample = assert(foundation.com.list_sample)
local table_keys = assert(foundation.com.table_keys)
local is_blank = assert(foundation.com.is_blank)
local is_table_empty = assert(foundation.com.is_table_empty)
local table_copy = assert(foundation.com.table_copy)
local Directions = assert(foundation.com.Directions)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local Network = assert(yatm.spacetime.network)
local SpacetimeMeta = assert(yatm.spacetime.SpacetimeMeta)

local teleporter_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (1 / 16) - 0.5, 0.5},
  }
}

local function find_all_connected_relays(pos, collected)
  local to_visit = {
    vector.add(pos, Directions.V3_NORTH),
    vector.add(pos, Directions.V3_EAST),
    vector.add(pos, Directions.V3_SOUTH),
    vector.add(pos, Directions.V3_WEST),
    vector.add(pos, Directions.V3_DOWN),
    vector.add(pos, Directions.V3_UP),
  }

  local visited = {}

  for hash,vpos in pairs(collected) do
    visited[hash] = vpos
  end

  while not is_table_empty(to_visit) do
    local old_to_visit = to_visit
    to_visit = {}

    for _,vpos in ipairs(old_to_visit) do
      local vhash = minetest.hash_node_position(vpos)
      if not visited[vhash] then
        visited[vhash] = vpos
        local node = minetest.get_node(vpos)
        if node then
          local nodedef = minetest.registered_nodes[node.name]
          if nodedef then
            if nodedef.groups.teleporter_relay then
              collected[vhash] = vpos
              table.insert(to_visit, vector.add(vpos, Directions.V3_NORTH))
              table.insert(to_visit, vector.add(vpos, Directions.V3_EAST))
              table.insert(to_visit, vector.add(vpos, Directions.V3_SOUTH))
              table.insert(to_visit, vector.add(vpos, Directions.V3_WEST))
              table.insert(to_visit, vector.add(vpos, Directions.V3_DOWN))
              table.insert(to_visit, vector.add(vpos, Directions.V3_UP))
            end
          end
        end
      end
    end
  end
  return collected
end

local function maybe_teleport_all_players_on_teleporter(pos, node)
  local meta = minetest.get_meta(pos)
  local address = SpacetimeMeta.get_address(meta)
  if not is_blank(address) then
    local hash = minetest.hash_node_position(pos)
    local positions = {}

    Network:each_member_in_group_by_address("player_teleporter_destination", address, function (member_hash, member)
      if member_hash ~= hash then
        positions[member_hash] = member.pos
      end
      return true
    end)

    if is_table_empty(positions) then
      print(minetest.pos_to_string(pos), address, "No target positions!")
    else
      local all_sources = find_all_connected_relays(pos, { [hash] = pos })
      local hashes = table_keys(positions)
      for _,source_pos in pairs(all_sources) do
        local objects = minetest.get_objects_inside_radius(source_pos, 1)
        for _,object in ipairs(objects) do
          if object:is_player() then
            local h = list_sample(hashes)
            local target_pos = positions[h]
            object:set_pos(target_pos)
          end
        end
      end
    end
  else
    print(minetest.pos_to_string(pos), "No address present!")
  end
end

local default_rules = {
  {x =  0, y =  0, z = -1},
  {x =  1, y =  0, z =  0},
  {x = -1, y =  0, z =  0},
  {x =  0, y =  0, z =  1},
  {x =  1, y =  1, z =  0},
  {x =  1, y = -1, z =  0},
  {x = -1, y =  1, z =  0},
  {x = -1, y = -1, z =  0},
  {x =  0, y =  1, z =  1},
  {x =  0, y = -1, z =  1},
  {x =  0, y =  1, z = -1},
  {x =  0, y = -1, z = -1},
}

-- Dummy mesecons to force the device to connect to mesecon regardless of it's state
local teleporter_mesecons = {
  effector = {
    rules = default_rules,
  },
}

-- This is the mesecon entry used when the teleporter is on
local teleporter_on_mesecons = {
  effector = {
    rules = default_rules,

    action_on = function (pos, node)
      maybe_teleport_all_players_on_teleporter(pos, node)
    end,
  },
}

local function teleporter_after_place_node(pos, placer, itemstack, pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()

  SpacetimeMeta.copy_address(old_meta, new_meta)

  local address = SpacetimeMeta.patch_address(new_meta)
  local node = minetest.get_node(pos)
  Network:maybe_register_node(pos, node)

  yatm.devices.device_after_place_node(pos, placer, itemstack, pointed_thing)
end

local function teleporter_on_destruct(pos)
  Network:unregister_device(pos)
  yatm.devices.device_on_destruct(pos)
end

local function teleporter_after_destruct(pos, old_node)
  yatm.devices.device_after_destruct(pos, old_node)
end

local function teleporter_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = FakeMetaRef:new(old_meta_table)
  local new_meta = stack:get_meta()
  SpacetimeMeta.copy_address(old_meta, new_meta)
end

local function teleporter_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "S.Address: " .. SpacetimeMeta.to_infotext(meta)

  meta:set_string("infotext", infotext)
end

--
-- Teleporters transport any players standing on them to the paired telporter port block
--
local teleporter_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_spacetime:teleporter_error",
    error = "yatm_spacetime:teleporter_error",
    off = "yatm_spacetime:teleporter_off",
    on = "yatm_spacetime:teleporter_on",
    inactive = "yatm_spacetime:teleporter_inactive",
  },
  energy = {
    passive_lost = 5,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_spacetime:teleporter",

  description = "Teleporter",

  codex_entry_id = "yatm_spacetime:teleporter",

  groups = {
    cracky = 1,
    spacetime_device = 1,
    addressable_spacetime_device = 1,
  },

  drop = teleporter_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_top.off.png",
    "yatm_teleporter_bottom.png",
    "yatm_teleporter_side.off.png",
    "yatm_teleporter_side.off.png^[transformFX",
    "yatm_teleporter_side.off.png",
    "yatm_teleporter_side.off.png",
  },
  use_texture_alpha = "opaque",

  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,
  yatm_network = teleporter_yatm_network,
  yatm_spacetime = {},
  mesecons = teleporter_mesecons,

  refresh_infotext = teleporter_refresh_infotext,

  after_place_node = function (pos, placer, itemstack, pointed_thing)
    teleporter_after_place_node(pos, placer, itemstack, pointed_thing)
    local node = minetest.get_node(pos)
    minetest.after(0, mesecon.on_placenode, pos, node)
  end,

  on_destruct = teleporter_on_destruct,
  after_destruct = teleporter_after_destruct,

  preserve_metadata = teleporter_preserve_metadata,

  change_spacetime_address = function (pos, node, new_address)
    local meta = minetest.get_meta(pos)

    SpacetimeMeta.set_address(meta, new_address)

    local nodedef = minetest.registered_nodes[node.name]
    local new_node = table_copy(node)
    if is_blank(new_address) then
      new_node.name = nodedef.yatm_network.states.inactive
    else
      new_node.name = nodedef.yatm_network.states.on
    end

    if new_node.name ~= node.name then
      minetest.swap_node(pos, new_node)
      Network:maybe_update_node(pos, new_node)
    end
    yatm.queue_refresh_infotext(pos, new_node)

    return new_address
  end,
}, {
  error = {
    tiles = {
      "yatm_teleporter_top.error.png",
      "yatm_teleporter_bottom.png",
      "yatm_teleporter_side.error.png",
      "yatm_teleporter_side.error.png^[transformFX",
      "yatm_teleporter_side.error.png",
      "yatm_teleporter_side.error.png",
    },
    use_texture_alpha = "opaque",
  },

  inactive = {
    tiles = {
      "yatm_teleporter_top.inactive.png",
      "yatm_teleporter_bottom.png",
      "yatm_teleporter_side.inactive.png",
      "yatm_teleporter_side.inactive.png^[transformFX",
      "yatm_teleporter_side.inactive.png",
      "yatm_teleporter_side.inactive.png",
    },
    use_texture_alpha = "opaque",
  },

  on = {
    tiles = {
      {
        name = "yatm_teleporter_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_teleporter_bottom.png",
      "yatm_teleporter_side.on.png",
      "yatm_teleporter_side.on.png^[transformFX",
      "yatm_teleporter_side.on.png^[transformFX",
      "yatm_teleporter_side.on.png",
    },
    use_texture_alpha = "opaque",
    mesecons = teleporter_on_mesecons,
    yatm_spacetime = {
      groups = {
        player_teleporter = 1,
        player_teleporter_destination = 1,
      },
    },
  },
})

--
-- DATA Variant
--
local data_network = yatm.data_network

if not data_network then
  minetest.log("warn", "data network unavailable, not registering DATA based teleporters")
  return
end
local string_hex_unescape = assert(foundation.com.string_hex_unescape)

local teleporter_data_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_spacetime:teleporter_data_error",
    error = "yatm_spacetime:teleporter_data_error",
    off = "yatm_spacetime:teleporter_data_off",
    on = "yatm_spacetime:teleporter_data_on",
    inactive = "yatm_spacetime:teleporter_data_inactive",
  },
  energy = {
    passive_lost = 5,
  },
}

local data_interface = {
  on_load = function (self, pos, node)
    yatm_data_logic.mark_all_inputs_for_active_receive(pos)
  end,

  receive_pdu = function (self, pos, node, dir, port, value)
    local bin = string_hex_unescape(value)
    local input = string.byte(bin, 1)

    local meta = minetest.get_meta(pos)

    local data_on_threshold = meta:get_string("data_on_threshold")
    data_on_threshold = string_hex_unescape(data_on_threshold)
    local threshold = string.byte(data_on_threshold, 1) or 0

    if input >= threshold then
      maybe_teleport_all_players_on_teleporter(pos, node)
    end
  end,

  get_programmer_formspec = {
    default_tab = "ports",
    tabs = {
      {
        tab_id = "ports",
        title = "Ports",
        header = "Port Configuration",
        render = {
          {
            component = "io_ports",
            mode = "io",
          }
        },
      },
      {
        tab_id = "data",
        title = "DATA",
        header = "DATA Configuration",
        render = {
          {
            component = "field",
            label = "High Threshold (byte)",
            name = "data_on_threshold",
            type = "string",
            meta = true,
          },
        },
      }
    }
  },

  receive_programmer_fields = {
    tabbed = true, -- notify the solver that tabs are in use
    tabs = {
      {
        components = {
          {
            component = "io_ports",
            mode = "io",
          }
        }
      },
      {
        components = {
          {
            component = "field",
            name = "data_on_threshold",
            type = "string",
            meta = true,
          }
        }
      }
    }
  },
}

local on_construct = function (pos)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)

  data_network:add_node(pos, node)
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_spacetime:teleporter_data",

  description = "Teleporter [DATA]",

  codex_entry_id = "yatm_spacetime:teleporter_data",

  groups = {
    cracky = 1,
    spacetime_device = 1,
    addressable_spacetime_device = 1,
    yatm_data_device = 1,
    data_programmable = 1,
  },

  drop = teleporter_data_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_top.data.off.png",
    "yatm_teleporter_bottom.png",
    "yatm_teleporter_side.off.png",
    "yatm_teleporter_side.off.png^[transformFX",
    "yatm_teleporter_side.off.png",
    "yatm_teleporter_side.off.png",
  },
  use_texture_alpha = "opaque",

  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,
  yatm_network = teleporter_data_yatm_network,
  yatm_spacetime = {},

  refresh_infotext = teleporter_refresh_infotext,

  on_construct = on_construct,
  after_place_node = teleporter_after_place_node,
  on_destruct = teleporter_on_destruct,
  after_destruct = function (pos, old_node)
    data_network:remove_node(pos, old_node)
    teleporter_after_destruct(pos, old_node)
  end,

  data_network_device = {
    type = "device",
  },
  data_interface = data_interface,

  preserve_metadata = teleporter_preserve_metadata,

  change_spacetime_address = function (pos, node, new_address)
    local meta = minetest.get_meta(pos)

    SpacetimeMeta.set_address(meta, new_address)

    local nodedef = minetest.registered_nodes[node.name]
    local new_node = table_copy(node)
    if is_blank(new_address) then
      new_node.name = nodedef.yatm_network.states.inactive
    else
      new_node.name = nodedef.yatm_network.states.on
    end

    if new_node.name ~= node.name then
      minetest.swap_node(pos, new_node)
      data_network:upsert_member(pos, new_node)
      Network:maybe_update_node(pos, new_node)
    end

    yatm.queue_refresh_infotext(pos, new_node)
    return new_address
  end,
}, {
  error = {
    tiles = {
      "yatm_teleporter_top.data.error.png",
      "yatm_teleporter_bottom.png",
      "yatm_teleporter_side.error.png",
      "yatm_teleporter_side.error.png^[transformFX",
      "yatm_teleporter_side.error.png",
      "yatm_teleporter_side.error.png",
    },
    use_texture_alpha = "opaque",
  },

  inactive = {
    tiles = {
      "yatm_teleporter_top.data.inactive.png",
      "yatm_teleporter_bottom.png",
      "yatm_teleporter_side.inactive.png",
      "yatm_teleporter_side.inactive.png^[transformFX",
      "yatm_teleporter_side.inactive.png",
      "yatm_teleporter_side.inactive.png",
    },
    use_texture_alpha = "opaque",
  },

  on = {
    tiles = {
      {
        name = "yatm_teleporter_top.data.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_teleporter_bottom.png",
      "yatm_teleporter_side.on.png",
      "yatm_teleporter_side.on.png^[transformFX",
      "yatm_teleporter_side.on.png^[transformFX",
      "yatm_teleporter_side.on.png",
    },
    use_texture_alpha = "opaque",
    mesecons = teleporter_on_mesecons,
    yatm_spacetime = {
      groups = {
        player_teleporter = 1,
        player_teleporter_destination = 1,
      },
    },
  },
})
