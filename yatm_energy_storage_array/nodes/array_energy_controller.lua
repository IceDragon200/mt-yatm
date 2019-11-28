local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)

yatm.devices.register_stateful_network_device({
  description = "Array Energy Cell Controller",

  groups = {
    cracky = 1,
    array_energy_cell_controller = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
  },

  tiles = {
    "yatm_array_energy_controller_side.off.png",
  },

  yatm_network = {
    kind = "array_energy_controller",

    groups = {
      device_controller = 2,
      energy_storage = 1,
      energy_receiver = 1,
    },

    default_state = "off",
    states = {
      error = "yatm_energy_storage_array:array_energy_controller_error",
      conflict = "yatm_energy_storage_array:array_energy_controller_error",
      off = "yatm_energy_storage_array:array_energy_controller_off",
      on = "yatm_energy_storage_array:array_energy_controller_on",
    },

    energy = {
      capacity = function (pos, node)
        return 0
      end,

      receive_energy = function (pos, node, energy_left, dtime, ot)
        return 0
      end,

      get_usable_stored_energy = function (pos, node)
        return 0
      end,

      use_stored_energy = function (pos, node, energy_to_use)
        return 0
      end,
    },
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]

    --local usable = EnergyDevices.get_usable_stored_energy(pos, node)

    local infotext =
      cluster_devices:get_node_infotext(pos) .. "\n" ..
      cluster_energy:get_node_infotext(pos) .. "\n"

    -- TODO display energy

    meta:set_string("infotext", infotext)
  end,
}, {
  error = {
    tiles = {
      "yatm_array_energy_controller_side.error.png",
    },
  },

  on = {
    tiles = {
      "yatm_array_energy_controller_side.on.png",
    },
  },
})
