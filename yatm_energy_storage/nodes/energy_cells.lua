local mod = yatm_energy_storage
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local EnergyDevices = assert(yatm.energy.EnergyDevices)

-- network frames * seconds * minutes
local hours = 20 * 60 * 60
local cell_types = {
  basic = {
    bandwidth = 60,
    capacity = hours * 1, -- fully charged, it will last an hour
  },
  normal = {
    bandwidth = 360,
    capacity = hours * 24, -- fully charged, it will last a day
  },
  dense = {
    bandwidth = 2160,
    capacity = hours * 24 * 7, -- fully charged, it will last a week
  },
}

local function energy_cell_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  local usable = EnergyDevices.get_usable_stored_energy(pos, node)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, "internal", nodedef.yatm_network.energy.capacity) .. "\n" ..
    "Usable Energy: " .. tostring(usable)

  meta:set_string("infotext", infotext)
end

local function num_round(value)
  local d = value - math.floor(value)
  if d > 0.5 then
    return math.ceil(value)
  else
    return math.floor(value)
  end
end

for cell_type, cell_config in pairs(cell_types) do
  local energy_cell_yatm_network = {
    basename = "yatm_energy_storage:energy_cell_" .. cell_type,
    kind = "energy_storage",
    cell_config = cell_config,
    groups = {
      device_controller = 2,
      -- it's an energy cell
      energy_cell = 1,
      -- the cell type + it's an energy cell
      [cell_type .. "_energy_cell"] = 1,
      -- it qualifies as an energy storage device
      energy_storage = 1,
      -- it qualifies as an energy receiver device
      energy_receiver = 1,
    },

    energy = {
      capacity = cell_config.capacity,
    },
  }

  local function on_energy_changed(pos, node)
    local meta = minetest.get_meta(pos)
    local current_energy = Energy.get_meta_energy(meta, "internal")
    local stage = math.min(num_round(7 * current_energy / cell_config.capacity), 7);

    local new_name = energy_cell_yatm_network.basename .. "_" .. stage
    if node.name ~= new_name then
      node.name = new_name
      minetest.swap_node(pos, node)
    end
    yatm.queue_refresh_infotext(pos, node)
  end

  function energy_cell_yatm_network.energy.receive_energy(pos, node, amount)
    local meta = minetest.get_meta(pos)
    local used_amount = Energy.receive_meta_energy(meta, "internal", amount, cell_config.bandwidth, cell_config.capacity, true)
    if used_amount > 0 then
      on_energy_changed(pos, node)
    end
    return used_amount
  end

  function energy_cell_yatm_network.energy.get_usable_stored_energy(pos, node)
    local meta = minetest.get_meta(pos)
    return Energy.get_meta_energy_throughput(meta, "internal", cell_config.bandwidth)
  end

  function energy_cell_yatm_network.energy.use_stored_energy(pos, node, amount)
    local meta = minetest.get_meta(pos)
    local consumed_amount = Energy.consume_meta_energy(meta, "internal", amount, cell_config.bandwidth, cell_config.capacity, true)
    if consumed_amount > 0 then
      on_energy_changed(pos, node)
    end
    return consumed_amount
  end

  for stage = 0,7 do
    groups = {
      cracky = nokore.dig_class("copper"),
      oddly_breakable_by_hand = nokore.dig_class("hand"),
      yatm_energy_device = 1,
    }

    if stage > 0 then
      groups.not_in_creative_inventory = 1
    end

    yatm.devices.register_network_device(energy_cell_yatm_network.basename .. "_" .. stage, {
      codex_entry_id = energy_cell_yatm_network.basename,

      basename = energy_cell_yatm_network.basename,

      description = mod.S("Energy Cell ("..cell_type..")"),
      drop = energy_cell_yatm_network.basename .. "_0",
      groups = groups,
      is_ground_content = false,
      tiles = {
        {
          name = "yatm_energy_cell_"..cell_type.."_stage"..stage..".png",
          animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1.0
          },
        },
      },
      paramtype = "none",
      paramtype2 = "facedir",

      yatm_network = energy_cell_yatm_network,

      sounds = yatm.node_sounds:build("glass"),

      refresh_infotext = energy_cell_refresh_infotext,
    })
  end

  local creative_energy_cell_yatm_network = {
    basename = "yatm_energy_storage:energy_cell_" .. cell_type .. "_creative",
    kind = "energy_storage",
    cell_config = cell_config,
    groups = {
      device_controller = 2,
      -- it's an energy cell
      energy_cell = 1,
      -- it's a creative energy cell
      creative_energy_cell = 1,
      -- the cell type + it's an energy cell
      [cell_type .. "_energy_cell"] = 1,
      -- it qualifies as an energy storage device
      energy_storage = 1,
      -- it qualifies as an energy receiver device
      energy_receiver = 1,
    },
    energy = {}
  }

  function creative_energy_cell_yatm_network.energy.receive_energy(pos, node, amount)
    return 0
  end

  function creative_energy_cell_yatm_network.energy.get_usable_stored_energy(pos, node)
    return cell_config.bandwidth
  end

  function creative_energy_cell_yatm_network.energy.use_stored_energy(pos, node, amount)
    --yatm.queue_refresh_infotext(pos, node) -- too excessive
    return amount
  end

  yatm.devices.register_network_device(creative_energy_cell_yatm_network.basename, {
    codex_entry_id = creative_energy_cell_yatm_network.basename,

    description = mod.S("Energy Cell ("..cell_type..") [Creative]"),

    groups = {
      cracky = nokore.dig_class("copper"),
      oddly_breakable_by_hand = nokore.dig_class("hand"),
      yatm_energy_device = 1,
    },
    is_ground_content = false,
    tiles = {
      {
        name = "yatm_energy_cell_"..cell_type.."_creative.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
    },
    paramtype = "none",
    paramtype2 = "facedir",

    yatm_network = creative_energy_cell_yatm_network,

    refresh_infotext = energy_cell_refresh_infotext,

    sounds = yatm.node_sounds:build("glass"),
  })
end
