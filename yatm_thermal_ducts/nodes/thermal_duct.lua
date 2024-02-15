local mod = yatm_thermal_ducts
local cluster_thermal = assert(yatm.cluster.thermal)
local table_length = assert(foundation.com.table_length)
local table_merge = assert(foundation.com.table_merge)

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local available_heat = meta:get_float("heat")

  local infotext =
    cluster_thermal:get_node_infotext(pos) .. "\n" ..
    "Heat: " .. math.floor(available_heat)

  meta:set_string("infotext", infotext)

  local new_name
  if math.floor(available_heat) > 0 then
    new_name = "yatm_thermal_ducts:thermal_duct_heating"
  elseif math.floor(available_heat) < 0 then
    new_name = "yatm_thermal_ducts:thermal_duct_cooling"
  else
    new_name = "yatm_thermal_ducts:thermal_duct_off"
  end

  if node.name ~= new_name then
    node.name = new_name
    minetest.swap_node(pos, node)
  end
end

local function on_construct(pos)
  local node = minetest.get_node(pos)

  cluster_thermal:schedule_add_node(pos, node)
end

local function after_destruct(pos, node)
  cluster_thermal:schedule_remove_node(pos, node)
end

-- A very thick duct
local size = 8 / 16 / 2

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  yatm_cluster_thermal = 1,
  heatable_device = 1,
  heater_device = 1,
  thermal_duct = 1,
}

local thermal_interface = {
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
    if yatm.thermal.update_heat(meta, "heat", heat, 10, dtime) then
      yatm.queue_refresh_infotext(pos, node)
    end
  end,
}

yatm.register_stateful_node("yatm_thermal_ducts:thermal_duct", {
  codex_entry_id = "yatm_thermal_ducts:thermal_duct",

  description = mod.S("Thermal Duct"),

  groups = groups,

  drop = "yatm_thermal_ducts:thermal_duct_off",

  connects_to = {
    "group:thermal_duct",
    "group:heater_device",
    "group:heatable_device",
  },

  paramtype = "light",

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

  on_construct = on_construct,

  after_destruct = after_destruct,

  thermal_interface = thermal_interface,

  refresh_infotext = refresh_infotext,
}, {
  off = {
    tiles = {
      "yatm_thermal_duct_side.off.png"
    },
    use_texture_alpha = "opaque",
  },

  heating = {
    groups = table_merge(groups, { not_in_creative_inventory = 1 }),

    tiles = {
      "yatm_thermal_duct_side.heating.png"
    },
    use_texture_alpha = "opaque",
  },

  cooling = {
    groups = table_merge(groups, { not_in_creative_inventory = 1 }),

    tiles = {
      "yatm_thermal_duct_side.cooling.png"
    },
    use_texture_alpha = "opaque",
  },
})
