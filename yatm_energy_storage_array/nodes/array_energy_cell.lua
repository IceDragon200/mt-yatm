local cluster_devices = assert(yatm.cluster.devices)

--
-- Array Energy Cells are denser that regular energy cells
-- However they need a controller in order to charge or discharge.
-- Out of the box, they do not support any of the energy interfaces.
-- Instead their energy interfaces are private and only the controller can use them.
--

local CAPACITY = 20 * 60 * 60 * 24 * 7 * 4
local BANDWIDTH = 4096
local ENERGY_KEY = "primary"

local function num_round(value)
  local d = value - math.floor(value)
  if d > 0.5 then
    return math.ceil(value)
  else
    return math.floor(value)
  end
end

local node_name = "yatm_energy_storage_array:array_energy_cell_creative"

minetest.register_node(node_name, yatm.devices.patch_device_nodedef(node_name, {
  description = "Array Energy Cell [Creative]",

  groups = {
    cracky = 1,
    yatm_cluster_device = 1,
  },

  tiles = {"yatm_array_energy_cell_creative.png"},

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = {
    kind = "array_energy_cell",

    groups = {
      array_energy_cell = 1,
    },

    array_energy = {
      capacity = function (pos, node)
        return CAPACITY
      end,

      get_stored_energy = function (pos, node)
        local meta = minetest.get_meta(pos)

        return CAPACITY
      end,

      receive_energy = function (pos, node, energy_left, dtime, ot)
        return 0
      end,

      get_usable_stored_energy = function (pos, node)
        return BANDWIDTH
      end,

      use_stored_energy = function (pos, node, energy_to_use)
        return math.min(energy_to_use, BANDWIDTH)
      end,
    }
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    cluster_devices:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    cluster_devices:schedule_remove_node(pos, node)
  end,

  transition_device_state = function (pos, node, state)
    yatm.queue_refresh_infotext(pos, node)
  end,

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      "Creative Array Energy Cell\n" ..
      cluster_devices:get_node_infotext(pos) .. " [" .. CAPACITY .. "]/" .. BANDWIDTH

    meta:set_string("infotext", infotext)
  end,
}))

local node_name = "yatm_energy_storage_array:array_energy_cell"
yatm.register_stateful_node(node_name, yatm.devices.patch_device_nodedef(node_name, {
  base_description = "Array Energy Cell",

  description = "Array Energy Cell",

  drop = node_name .. "_stage0",

  groups = {
    cracky = 1,
    yatm_cluster_device = 1,
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = {
    kind = "array_energy_cell",

    groups = {
      array_energy_cell = 1,
    },

    array_energy = {
      capacity = function (pos, node)
        return CAPACITY
      end,

      get_stored_energy = function (pos, node)
        local meta = minetest.get_meta(pos)

        return yatm.energy.get_energy(meta, ENERGY_KEY)
      end,

      receive_energy = function (pos, node, energy_left, dtime, ot)
        local meta = minetest.get_meta(pos)
        local received_energy = yatm.energy.receive_energy(meta, ENERGY_KEY, energy_left, BANDWIDTH, CAPACITY, true)
        if received_energy > 0 then
          yatm.queue_refresh_infotext(pos, node)
        end
        return received_energy
      end,

      get_usable_stored_energy = function (pos, node)
        local meta = minetest.get_meta(pos)
        return math.min(BANDWIDTH, yatm.energy.get_energy(meta, ENERGY_KEY))
      end,

      use_stored_energy = function (pos, node, energy_to_use)
        local meta = minetest.get_meta(pos)
        local consumed_energy = yatm.energy.consume_energy(meta, ENERGY_KEY, energy_to_use, BANDWIDTH, CAPACITY, true)
        if consumed_energy > 0 then
          yatm.queue_refresh_infotext(pos, node)
        end
        return consumed_energy
      end,
    }
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    yatm.energy.get_energy(meta, ENERGY_KEY, 0)

    local node = minetest.get_node(pos)
    cluster_devices:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    cluster_devices:schedule_remove_node(pos, node)
  end,

  transition_device_state = function (pos, node, state)
    yatm.queue_refresh_infotext(pos, node)
  end,

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)

    local en = yatm.energy.get_energy(meta, ENERGY_KEY)

    local infotext =
      "Array Energy Cell\n" ..
      cluster_devices:get_node_infotext(pos) .. "\n" ..
      "Energy: [" .. en .. "/" .. CAPACITY  .. "]/" .. BANDWIDTH

    local stage = num_round(7 * en / CAPACITY)

    local new_name = "yatm_energy_storage_array:array_energy_cell_stage" .. stage
    if node.name ~= new_name then
      node.name = new_name
      minetest.swap_node(pos, node)
    end
    meta:set_string("infotext", infotext)
  end,
}), {
  stage0 = {
    description = "Array Energy Cell [Stage 0]",

    tiles = {"yatm_array_energy_cell_side.0.png"}
  },
  stage1 = {
    description = "Array Energy Cell [Stage 1]",

    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.1.png"}
  },
  stage2 = {
    description = "Array Energy Cell [Stage 2]",

    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.2.png"}
  },
  stage3 = {
    description = "Array Energy Cell [Stage 3]",

    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.3.png"}
  },
  stage4 = {
    description = "Array Energy Cell [Stage 4]",

    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.4.png"}
  },
  stage5 = {
    description = "Array Energy Cell [Stage 5]",

    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.5.png"}
  },
  stage6 = {
    description = "Array Energy Cell [Stage 6]",

    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.6.png"}
  },
  stage7 = {
    description = "Array Energy Cell [Stage 7]",

    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.7.png"}
  },
})
