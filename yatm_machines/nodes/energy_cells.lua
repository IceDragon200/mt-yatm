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

for cell_type, cell_config in pairs(cell_types) do
  local energy_cell_yatm_network = {
    basename = "yatm_machines:energy_cell_" .. cell_type,
    kind = "energy_storage",
    cell_config = cell_config,
    groups = {
      -- it's an energy cell
      energy_cell = 1,
      -- the cell type + it's an energy cell
      [cell_type .. "_energy_cell"] = 1,
      -- it qualifies as an energy storage device
      energy_storage = 1,
      -- it qualifies as an energy receiver device
      energy_receiver = 1,
    }
  }

  local function refresh(pos, node)
    local meta = minetest.get_meta(pos)
    local current_energy = meta:get_int("energy")
    local stage = math.min(math.floor(8 * current_energy / cell_config.capacity), 7);

    local new_name = energy_cell_yatm_network.basename .. "_" .. stage
    if node.name ~= new_name then
      node.name = new_name
      minetest.swap_node(pos, node)
    end
  end

  local function change_energy(pos, node, energy)
    local meta = minetest.get_meta(pos)
    meta:set_int("energy", energy)
    print("ENERGY STORED", pos.x, pos.y, pos.z, node.name, energy, "/", cell_config.capacity)
    refresh(pos, node)
  end

  function energy_cell_yatm_network.receive_energy(pos, node, amount)
    local meta = minetest.get_meta(pos)
    return yatm_core.energy.receive_energy(meta, "internal", amount, cell_config.bandwidth, cell_config.capacity)
  end

  function energy_cell_yatm_network.get_usable_stored_energy(pos, node)
    local meta = minetest.get_meta(pos)
    return yatm_core.energy.get_energy_throughput(meta, "internal", cell_config.bandwidth)
  end

  function energy_cell_yatm_network.use_stored_energy(pos, node, amount)
    local meta = minetest.get_meta(pos)
    return yatm_core.energy.consume_energy(meta, "internal", amount, cell_config.bandwidth, cell_config.capacity)
  end

  for stage = 0,7 do
    groups = {cracky = 1}
    if stage > 0 then
      groups.not_in_creative_inventory = 1
    end
    yatm_machines.register_network_device(energy_cell_yatm_network.basename .. "_" .. stage, {
      description = "Energy Cell ("..cell_type..")",
      drop = energy_cell_yatm_network.basename .. "_0",
      groups = groups,
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
      paramtype = "light",
      paramtype2 = "facedir",
      yatm_network = energy_cell_yatm_network,
    })
  end

  yatm_machines.register_network_device("yatm_machines:energy_cell_"..cell_type.."_creative", {
    description = "Energy Cell ("..cell_type..") [Creative]",
    groups = {cracky = 1},
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
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = {
      kind = "energy_storage",
      groups = {energy_storage = 1, creative = 1},
    }
  })
end
