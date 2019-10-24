local cluster_thermal = assert(yatm.cluster.thermal)

-- A very thick duct
local size = 12 / 16 / 2

minetest.register_node("yatm_cluster_thermal:thermal_duct", {
  description = "Thermal Duct",

  groups = {
    cracky = 1,
    yatm_cluster_thermal = 1,
    heatable_device = 1,
    heater_device = 1,
    thermal_duct = 1,
  },

  tiles = {
    "yatm_thermal_duct_side.heating.png"
  },

  thermal_device = {
    groups = {
      duct = 1,
    },
  },

  connects_to = {
    "group:thermal_duct",
    "group:heater_device",
    "group:heatable_device",
  },

  drawtype = "nodebox",
  node_box = {
    type = "connected",
    fixed          = {-size, -size, -size, size,  size, size},
    connect_top    = {-size, -size, -size, size,  0.5,  size}, -- y+
    connect_bottom = {-size, -0.5,  -size, size,  size, size}, -- y-
    connect_front  = {-size, -size, -0.5,  size,  size, size}, -- z-
    connect_back   = {-size, -size,  size, size,  size, 0.5 }, -- z+
    connect_left   = {-0.5,  -size, -size, size,  size, size}, -- x-
    connect_right  = {-size, -size, -size, 0.5,   size, size}, -- x+
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)

    cluster_thermal:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    cluster_thermal:schedule_remove_node(pos, node)
  end,
})
