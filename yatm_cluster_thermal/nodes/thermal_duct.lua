local cluster_thermal = assert(yatm.cluster.thermal)
local table_length = assert(yatm_core.table_length)

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

  transfer_heat = function (pos, node)
    local meta = minetest.get_meta(pos)
    local available_heat = meta:get_float("heat")
    -- Capture all the ducts
    local ducts = {}
    -- Other devices
    local other_devices = {}

    if available_heat <= 0 then
      for d6_code, d6_vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
        local npos = vector.add(pos, d6_vec3)
        local nnode = minetest.get_node(npos)

        if minetest.get_item_group(nnode, "thermal_duct") > 0 then
          -- attempt to equalize the heat between ducts
          local nmeta = minetest.get_meta(npos)
          local nheat = nmeta:get_float("heat")

          if nheat < available_heat then
            -- Only use ducts that have less heat than the one asking.
            ducts[d6_code] = {
              pos = npos,
              node = nnode,
              meta = nmeta
            }
          end
        elseif minetest.get_item_group(nnode, "heatable_device") > 0 then
          -- perform normal heat transfer
          other_devices[d6_code] = {
            pos = npos,
            node = nnode,
          }
        end
      end

      local duct_count = table_length(ducts)
      local other_device_count = table_length(other_devices)


    end
  end
})
