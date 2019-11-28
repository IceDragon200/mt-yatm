local cluster_devices = assert(yatm.cluster.devices)

--
-- Array Energy Cells are denser that regular energy cells
-- However they need a controller in order to charge or discharge.
-- Out of the box, they do not support any of the energy interfaces.
-- Instead their energy interfaces are private and only the controller can use them.
--
minetest.register_node("yatm_energy_storage_array:array_energy_cell_creative", {
  description = "Array Energy Cell (Creative)",

  groups = {
    cracky = 1,
    yatm_cluster_device = 1,
  },

  tiles = {"yatm_array_energy_cell_creative.png"},

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = {
    kind = "array_energy_cell",

    groups = {
      array_energy_cell = 1,
    },
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    cluster_devices:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    cluster_devices:schedule_remove_node(pos, node)
  end,

  transition_device_state = function (pos, node, state)
    -- ignore it
  end,

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext = "Creative Array Energy Cell"

    meta:set_string("infotext", infotext)
  end,
})

yatm.register_stateful_node("yatm_energy_storage_array:array_energy_cell", {
  description = "Array Energy Cell",

  groups = {
    cracky = 1,
    yatm_cluster_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = {
    type = "array_energy_cell",

    groups = {
      array_energy_cell = 1,
    },
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    cluster_devices:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    cluster_devices:schedule_remove_node(pos, node)
  end,

  transition_device_state = function (pos, node, state)
    -- ignore it
  end,

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext = "Array Energy Cell"

    meta:set_string("infotext", infotext)
  end,
}, {
  stage0 = {
    tiles = {"yatm_array_energy_cell_side.0.png"}
  },
  stage1 = {
    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.1.png"}
  },
  stage2 = {
    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.2.png"}
  },
  stage3 = {
    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.3.png"}
  },
  stage4 = {
    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.4.png"}
  },
  stage5 = {
    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.5.png"}
  },
  stage6 = {
    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.6.png"}
  },
  stage7 = {
    groups = {
      cracky = 1,
      yatm_cluster_device = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {"yatm_array_energy_cell_side.7.png"}
  },
})
