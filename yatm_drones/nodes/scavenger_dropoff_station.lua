local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local Directions = assert(foundation.com.Directions)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

-- For dropping off items
local ItemInterface = assert(yatm.items.ItemInterface)
local ItemDevice = assert(yatm.items.ItemDevice)

local dropoff_station_item_interface = ItemInterface.new()

local function dropoff_station_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "[" .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "]"

  meta:set_string("infotext", infotext)
end

function dropoff_station_item_interface:get_item(pos, dir)
  return nil, "no retrieval"
end

function dropoff_station_item_interface:insert_item(pos, dir, item_stack, commit)
  local remaining = item_stack
  local leftover
  local npos
  local err

  if dir == Directions.D_NONE then
    for dir6, vec3 in pairs(Directions.DIR6_TO_VEC3) do
      npos = vector.add(pos, vec3)
      leftover, err = ItemDevice.insert_item(npos, Directions.invert_dir(dir6), remaining, commit)

      if leftover then
        remaining = leftover

        if remaining:is_empty() then
          break
        end
      end
    end
    return remaining
  end

  return nil, "can only insert from NONE direction"
end

function dropoff_station_item_interface:extract_item(self, pos, dir, item_stack_or_count, commit)
  -- NO.
  return nil, "no extraction"
end

local dropoff_station_yatm_network = {
  kind = "machine",

  groups = {
    energy_consumer = 1,
  },

  default_state = "off",
  states = {
    conflict = "yatm_drones:scavenger_dropoff_station_error",
    error = "yatm_drones:scavenger_dropoff_station_error",
    off = "yatm_drones:scavenger_dropoff_station_off",
    on = "yatm_drones:scavenger_dropoff_station_on",
  },

  energy = {
    capacity = 16000,
    network_charge_bandwidth = 500,
    passive_lost = 10,
    startup_threshold = 1000,
  },
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_drones:scavenger_dropoff_station",

  basename = "yatm_drones:scavenger_dropoff_station",

  description = "Scavenger Dropoff Station",

  drop = dropoff_station_yatm_network.states.off,

  groups = {
    cracky = 1,
    -- So scavengers know what to look for when docking
    scavenger_dropoff_station = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
    item_interface_in = 1,
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 1, 16),
      ng(0, 1,14, 16, 7,  2),
    },
  },
  tiles = {
    "yatm_scavenger_docking_station_top.dropoff.off.png",
    "yatm_scavenger_docking_station_bottom.off.png",
    "yatm_scavenger_docking_station_side.png",
    "yatm_scavenger_docking_station_side.png^[transformFX",
    "yatm_scavenger_docking_station_back.png",
    "yatm_scavenger_docking_station_front.off.png",
  },
  use_texture_alpha = "opaque",

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = dropoff_station_yatm_network,
  refresh_infotext = dropoff_station_refresh_infotext,
  item_interface = dropoff_station_item_interface,
}, {
  error = {
    tiles = {
      "yatm_scavenger_docking_station_top.dropoff.error.png",
      "yatm_scavenger_docking_station_bottom.error.png",
      "yatm_scavenger_docking_station_side.png",
      "yatm_scavenger_docking_station_side.png^[transformFX",
      "yatm_scavenger_docking_station_back.png",
      "yatm_scavenger_docking_station_front.error.png",
    },
    use_texture_alpha = "opaque",
  },

  on = {
    tiles = {
      "yatm_scavenger_docking_station_top.dropoff.on.png",
      "yatm_scavenger_docking_station_bottom.on.png",
      "yatm_scavenger_docking_station_side.png",
      "yatm_scavenger_docking_station_side.png^[transformFX",
      "yatm_scavenger_docking_station_back.png",
      "yatm_scavenger_docking_station_front.on.png",
    },
    use_texture_alpha = "opaque",
  },
})
