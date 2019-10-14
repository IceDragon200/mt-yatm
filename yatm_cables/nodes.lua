local function cable_on_yatm_device_changed(pos, node, _origin, _origin_node)
end

local function cable_after_place_node(pos, placer, itemstack, pointed_thing)
  local node = minetest.get_node(pos)
  -- let the system know it needs to refresh the network topography
  yatm_core.Network.schedule_refresh_network_topography(pos, { kind = "cable_added" })
end

local function cable_after_destruct(pos, old_node)
  -- let the system know it needs to refresh the network topography
  yatm_core.Network.schedule_refresh_network_topography(pos, { kind = "cable_removed" })
end

function yatm_cables.register_cable_state(params, size)
  local texture_basename = assert(params.texture_basename, "expected a texture_basename")
  local texture_name = nil
  local name = params.name

  local states = {}

  if params.state then
    texture_name = texture_basename .. assert(params.state_postfix) .. assert(params.postfix) .. ".png"

    -- the cable has multiple states
    for _,sub_state in ipairs(params.states) do
      states[sub_state] = name .. "_" .. sub_state
    end
    -- conflict is aliased as error
    states["conflict"] = states["error"]
    name = states[params.state]
  else
    texture_name = texture_basename .. assert(params.postfix) .. ".png"
    -- table does not have multiple states
    states["default"] = name
    name = states["default"]
  end

  local tiles = {texture_name}

  -- configure the yatm network behaviour
  local cable_yatm_network = {
    states = states, -- it has the following substates
    kind = "cable", -- this is a cable
    groups = {
      energy_cable = 1, -- this cable can transport energy
      network_cable = 1, -- this cable can be used for networking
      dense_cable = 1, -- this cable is dense
    },
    on_network_state_changed = yatm_core.Network.default_on_network_state_changed,
  }

  local connects_to = {}
  if params.connects_to then
    connects_to = params.connects_to
  else
    table.insert(connects_to, name)
  end

  local groups = {cracky = 1}
  if params.groups then
    groups = params.groups
  end
  --
  if params.states and params.default_state then
    if params.state ~= params.default_state then
      groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1})
    end
  end
  minetest.register_node(name, {
    description = params.description,

    groups = groups,

    is_ground_content = false,

    drop = params.drop,

    paramtype = "light",
    paramtype2 = "facedir",

    tiles = tiles,
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

    connects_to = connects_to,

    after_place_node = cable_after_place_node,
    after_destruct = cable_after_destruct,
    yatm_network = cable_yatm_network,
    on_yatm_device_changed = cable_on_yatm_device_changed,
    on_yatm_network_changed = yatm_core.Network.default_handle_network_changed,

    sounds = params.sounds,
  })
end

function yatm_cables.register_cable(params, size)
  size = size / 2
  if type(params.states) == "table" then
    for _,state in ipairs(params.states) do
      local state_postfix = "." .. state
      yatm_cables.register_cable_state(yatm_core.table_merge(params, {
        state_postfix = state_postfix,
        state = state,
      }), size)
    end
  else
    yatm_cables.register_cable_state(yatm_core.table_merge(params, {
      state_postfix = false,
      state = false,
      states = {},
    }), size)
  end
end

-- General cables carry both data and power
yatm_cables.register_cable({
  name = "yatm_cables:dense_cable",
  description = "Dense Cable",
  texture_basename = "yatm_dense_cable",

  default_state = "off",
  states =  {"on", "off", "error"},

  groups = { cracky = 1, any_cable = 1, energy_cable = 1, network_cable = 1, dense_cable = 1 },
  connects_to = {
    "group:any_cable",
    "group:yatm_network_device",
    "group:yatm_energy_device",
  },

  postfix = "_15",
}, 8 * yatm_core.PX16)

yatm_cables.register_cable({
  name = "yatm_cables:medium_cable",
  description = "Medium Cable",
  texture_basename = "yatm_medium_cable",
  default_state = "off",
  states =  {"on", "off", "error"},

  groups = { cracky = 1, any_cable = 1, energy_cable = 1, network_cable = 1, medium_cable = 1 },
  connects_to = {
    "group:any_cable",
    "group:yatm_network_device",
    "group:yatm_energy_device",
  },

  postfix = "_15",
}, 6 * yatm_core.PX16)
yatm_cables.register_cable({
  name = "yatm_cables:small_cable",
  description = "Small Cable",
  --texture_basename = "yatm_small_cable_",
  texture_basename = "yatm_medium_cable",

  default_state = "off",
  states =  {"on", "off", "error"},

  groups = { cracky = 1, any_cable = 1, energy_cable = 1, network_cable = 1, small_cable = 1 },
  connects_to = {
    "group:any_cable",
    "group:yatm_network_device",
    "group:yatm_energy_device",
  },

  postfix = "_15",
}, 4 * yatm_core.PX16)

-- Glass cables are data cables, they do not carry power
local glass_sounds = default.node_sound_glass_defaults()
yatm_cables.register_cable({
  name = "yatm_cables:pipe_glass", -- TODO: rename to glass_cable
  description = "Glass Cable",
  texture_basename = "yatm_pipe.glass",
  states = false,
  sounds = glass_sounds,

  groups = { cracky = 1, any_cable = 1, glass_cable = 1, data_cable = 1  },
  connects_to = {
    "group:data_cable",
    "group:yatm_network_device",
  },

  postfix = "_15",
}, 4 * yatm_core.PX16)

yatm_cables.register_cable({
  name = "yatm_cables:pipe_glass_rb",
  description = "Glass Cable (Red/Black)",
  texture_basename = "yatm_pipe.glass.red.black.couplings",
  states = false,
  sounds = glass_sounds,

  groups = { cracky = 1, any_cable = 1, glass_cable = 1, data_cable = 1  },
  connects_to = {
    "group:data_cable",
    "group:yatm_network_device",
  },

  postfix = "_15",
}, 4 * yatm_core.PX16)

yatm_cables.register_cable({
  name = "yatm_cables:pipe_glass_yb",
  description = "Glass Cable (Yellow/Black)",
  texture_basename = "yatm_pipe.glass.yellow.black.couplings",
  states = false,
  sounds = glass_sounds,

  groups = { cracky = 1, any_cable = 1, glass_cable = 1, data_cable = 1 },
  connects_to = {
    "group:data_cable",
    "group:yatm_network_device",
  },

  postfix = "_15",
}, 4 * yatm_core.PX16)

-- Standard pipe cables only carry energy
yatm_cables.register_cable({
  name = "yatm_cables:pipe_rb",
  description = "Pipe (Red/Black)",
  texture_basename = "yatm_pipe.red.black.couplings",
  states = false,

  groups = { cracky = 1, any_cable = 1, energy_cable = 1 },
  connects_to = {
    "group:energy_cable",
    "group:yatm_energy_device",
  },

  postfix = "_15",
}, 4 * yatm_core.PX16)

yatm_cables.register_cable({
  name = "yatm_cables:pipe_yb",
  description = "Pipe (Yellow/Black)",
  texture_basename = "yatm_pipe.yellow.black.couplings",
  states = false,

  groups = { cracky = 1, any_cable = 1, energy_cable = 1 },
  connects_to = {
    "group:energy_cable",
    "group:yatm_energy_device",
  },

  postfix = "_15",
}, 4 * yatm_core.PX16)


yatm_cables.register_cable({
  name = "yatm_cables:copper_cable_uninsulated",
  description = "Copper Cable",
  texture_basename = "yatm_copper_cable_side.uninsulated",
  states = false,

  groups = { cracky = 1, copper_cable = 1, copper_cable_uninsulated = 1, energy_cable = 1 },
  connects_to = {
    "group:energy_cable",
    "group:copper_cable",
    "group:yatm_energy_device",
  },

  postfix = "",
}, 4 * yatm_core.PX16)

do
  local colors = {
    {"white", "White"}
  }

  -- If the dye module is available, use the colors from there instead.
  if dye then
    colors = dye.dyes
  end

  for _,color_pair in ipairs(colors) do
    local color_basename = color_pair[1]
    local color_name = color_pair[2]

    local colored_group_name = "copper_cable_" .. color_basename
    local groups = { cracky = 1, copper_cable = 1, [colored_group_name] = 1, energy_cable = 1 }

    local node_name = "yatm_cables:copper_cable_" .. color_basename

    yatm_cables.register_cable({
      name = node_name,
      description = "Copper Cable",
      texture_basename = "yatm_copper_cable_" .. color_basename .. ".on",
      states = false,

      groups = groups,
      connects_to = {
        "group:copper_cable_uninsulated",
        "group:" .. colored_group_name,
        "group:yatm_energy_device",
      },

      postfix = "",
    }, 6 * yatm_core.PX16)
  end
end
