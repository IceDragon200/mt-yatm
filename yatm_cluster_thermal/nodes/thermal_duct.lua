local cluster_thermal = assert(yatm.cluster.thermal)
local table_length = assert(yatm_core.table_length)

-- A very thick duct
local size = 12 / 16 / 2

yatm.register_stateful_node("yatm_cluster_thermal:thermal_duct", {
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

  thermal_interface = {
    groups = {
      duct = 1,
      thermal_producer = 1, -- not actually, but it works like one
    },

    get_heat = function (self, pos, node)
      local meta = minetest.get_meta(pos)
      return meta:get_float("heat")
    end,

    update_heat = function (self, pos, node, heat, dtime)
      local meta = minetest.get_meta(pos)
      local available_heat = meta:get_float("heat")
      meta:set_float("heat", yatm_core.number_lerp(available_heat, heat, dtime))
      yatm.queue_refresh_infotext(pos, node)
    end,
  },

  refresh_infotext = function (pos, node)
    local meta = minetest.get_meta(pos)
    local available_heat = meta:get_float("heat")

    local new_name
    if new_heat > 0 then
      new_name = "yatm_cluster_thermal:thermal_duct_heating"
    elseif new_heat < 0 then
      new_name = "yatm_cluster_thermal:thermal_duct_cooling"
    else
      new_name = "yatm_cluster_thermal:thermal_duct_off"
    end

    if node.name ~= new_name then
      minetest.swap_node(pos, node)
    end
  end,
}, {
  off = {
    tiles = {
      "yatm_thermal_duct_side.off.png"
    },
  },

  heating = {
    tiles = {
      "yatm_thermal_duct_side.heating.png"
    },
  },

  cooling = {
    tiles = {
      "yatm_thermal_duct_side.cooling.png"
    },
  },
})
