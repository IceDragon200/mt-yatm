local cluster_thermal = assert(yatm.cluster.thermal)
local table_length = assert(foundation.com.table_length)
local table_merge = assert(foundation.com.table_merge)

local function get_thermal_node_formspec(pos, user, assigns)
  local meta = minetest.get_meta(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  local background_type
  local heat = meta:get_float("heat")

  if heat > 0 then
    background_type = "machine_heated"
  elseif heat < 0 then
    background_type = "machine_cooled"
  else
    background_type = "machine"
  end

  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), background_type) ..
    "label[0,0;Thermal Node]" ..
    "field[0.25,1;8,1;heat;Heat;" .. heat .. "]"

  return formspec
end

local function receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)
  if fields["heat"] then
    local heat = tonumber(fields["heat"]) or 0.0
    meta:set_float("heat", heat)
    yatm.queue_refresh_infotext(assigns.pos, minetest.get_node(assigns.pos))
    return true, get_thermal_node_formspec(assigns.pos, player, assigns)
  end
  return true
end

local core_size = 12 / 16 / 2
local nub_size = 10 / 16 / 2

local groups = {
  cracky = 1,
  yatm_cluster_thermal = 1,
  heater_device = 1,
}

yatm.register_stateful_node("yatm_cluster_thermal:thermal_node", {
  description = "Thermal Node",

  groups = groups,

  drop = "yatm_cluster_thermal:thermal_node_off",

  connects_to = {
    "group:thermal_duct",
    "group:heatable_device",
  },

  paramtype = "light",

  drawtype = "nodebox",
  node_box = {
    type = "connected",
    fixed          = {-core_size, -core_size, -core_size, core_size,  core_size, core_size},
    connect_top    = {-nub_size, -nub_size, -nub_size, nub_size,  0.5,  nub_size}, -- y+
    connect_bottom = {-nub_size, -0.5,  -nub_size, nub_size,  nub_size, nub_size}, -- y-
    connect_front  = {-nub_size, -nub_size, -0.5,  nub_size,  nub_size, nub_size}, -- z-
    connect_back   = {-nub_size, -nub_size,  nub_size, nub_size,  nub_size, 0.5 }, -- z+
    connect_left   = {-0.5,  -nub_size, -nub_size, nub_size,  nub_size, nub_size}, -- x-
    connect_right  = {-nub_size, -nub_size, -nub_size, 0.5,   nub_size, nub_size}, -- x+
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)

    cluster_thermal:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    cluster_thermal:schedule_remove_node(pos, node)
  end,

  on_rightclick = function (pos, node, user)
    local assigns = { pos = pos, node = node }
    local formspec = get_thermal_node_formspec(pos, user, assigns)
    local formspec_name = "yatm_cluster_thermal:thermal_node:" .. minetest.pos_to_string(pos)

    yatm_core.show_bound_formspec(user:get_player_name(), formspec_name, formspec, {
      state = assigns,
      on_receive_fields = receive_fields
    })
  end,

  thermal_interface = {
    groups = {
      thermal_producer = 1, -- not actually, but it works like one
    },

    get_heat = function (self, pos, node)
      local meta = minetest.get_meta(pos)
      return meta:get_float("heat")
    end,
  },

  refresh_infotext = function (pos, node)
    local meta = minetest.get_meta(pos)
    local available_heat = meta:get_float("heat")

    local infotext =
      cluster_thermal:get_node_infotext(pos) .. "\n" ..
      "Heat: " .. math.floor(available_heat)

    meta:set_string("infotext", infotext)

    local new_name
    if math.floor(available_heat) > 0 then
      new_name = "yatm_cluster_thermal:thermal_node_heating"
    elseif math.floor(available_heat) < 0 then
      new_name = "yatm_cluster_thermal:thermal_node_cooling"
    else
      new_name = "yatm_cluster_thermal:thermal_node_off"
    end

    if node.name ~= new_name then
      node.name = new_name
      minetest.swap_node(pos, node)
    end
  end,
}, {
  off = {
    tiles = {
      "yatm_thermal_node_side.off.png"
    },
    use_texture_alpha = "opaque",
  },

  heating = {
    groups = table_merge(groups, { not_in_creative_inventory = 1 }),

    tiles = {
      {
        name = "yatm_thermal_node_side.on.heating.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
    },
    use_texture_alpha = "opaque",
  },

  cooling = {
    groups = table_merge(groups, { not_in_creative_inventory = 1 }),

    tiles = {
      {
        name = "yatm_thermal_node_side.on.cooling.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
    },
    use_texture_alpha = "opaque",
  },

  radiating = {
    groups = table_merge(groups, { not_in_creative_inventory = 1 }),

    tiles = {
      {
        name = "yatm_thermal_node_side.on.radiating.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
    },
    use_texture_alpha = "opaque",
  },
})
