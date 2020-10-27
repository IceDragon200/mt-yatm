local table_merge = assert(foundation.com.table_merge)

local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)

local SIXTEENTH = 1 / 16.0

local function cable_after_place_node(pos, placer, itemstack, pointed_thing)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.groups['yatm_cluster_device'] then
    cluster_devices:schedule_add_node(pos, node)
  end
  if nodedef.groups['yatm_cluster_energy'] then
    cluster_energy:schedule_add_node(pos, node)
  end
end

local function cable_after_destruct(pos, old_node)
  -- let the system know it needs to refresh the network topography
  local nodedef = minetest.registered_nodes[old_node.name]
  if nodedef.groups['yatm_cluster_device'] then
    cluster_devices:schedule_remove_node(pos, old_node)
  end
  if nodedef.groups['yatm_cluster_energy'] then
    cluster_energy:schedule_remove_node(pos, old_node)
  end
end

local function cable_transition_device_state(pos, node, state)
  print("yatm_cables", "cable_transition_device_state", minetest.pos_to_string(pos), "node=" .. node.name, "state=" .. state)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.yatm_network.states then
    local new_node_name
    if state == "down" then
      new_node_name = nodedef.yatm_network.states['off']
    elseif  state == "up" then
      new_node_name = nodedef.yatm_network.states['on']
    elseif state == "conflict" then
      new_node_name = nodedef.yatm_network.states['conflict']
    else
      error("unhandled state=" .. state)
    end
    if new_node_name then
      node = minetest.get_node(pos)
      node.name = new_node_name
      minetest.swap_node(pos, node)
    end
  end
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
    default_state = params.default_state,
    states = states, -- it has the following substates
    kind = "cable", -- this is a cable
    color = params.cable_color or 'default',
    groups = {
      energy_cable = 1, -- this cable can transport energy
      network_cable = 1, -- this cable can be used for networking
      dense_cable = 1, -- this cable is dense
    },
  }

  if params.drop == nil then
    params.drop = cable_yatm_network.states[cable_yatm_network.default_state]
  end

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
      groups = table_merge(groups, {not_in_creative_inventory = 1})
    end
  end

  minetest.register_node(name, {
    basename = params.basename,
    base_description = params.base_description or params.description,

    codex_entry_id = params.codex_entry_id,

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

    transition_device_state = cable_transition_device_state,

    yatm_network = cable_yatm_network,

    sounds = params.sounds,
  })
end

function yatm_cables.register_cable(params, size)
  size = size / 2
  if type(params.states) == "table" then
    for _,state in ipairs(params.states) do
      local state_postfix = "." .. state

      yatm_cables.register_cable_state(table_merge(params, {
        state_postfix = state_postfix,
        state = state,
      }), size)
    end
  else
    yatm_cables.register_cable_state(table_merge(params, {
      state_postfix = false,
      state = false,
      states = {},
    }), size)
  end
end

-- General cables carry both data and power
yatm_cables.register_cable({
  basename = "yatm_cables:dense_cable",

  name = "yatm_cables:dense_cable",
  description = "Dense Cable",

  codex_entry_id = "yatm_cables:multi_cable",

  texture_basename = "yatm_dense_cable",

  default_state = "off",
  states =  {"on", "off", "error"},

  groups = {
    cracky = 1,
    any_cable = 1,
    energy_cable = 1,
    network_cable = 1,
    dense_cable = 1,
    yatm_cluster_device = 1,
    yatm_cluster_energy = 1,
  },

  connects_to = {
    "group:any_cable",
    "group:yatm_network_device",
    "group:yatm_energy_device",
  },

  postfix = "_15",
}, 8 * SIXTEENTH)

yatm_cables.register_cable({
  basename = "yatm_cables:medium_cable",

  name = "yatm_cables:medium_cable",
  description = "Medium Cable",

  codex_entry_id = "yatm_cables:multi_cable",

  texture_basename = "yatm_medium_cable",
  default_state = "off",
  states =  {"on", "off", "error"},

  groups = {
    cracky = 1,
    any_cable = 1,
    energy_cable = 1,
    network_cable = 1,
    medium_cable = 1,
    yatm_cluster_device = 1,
    yatm_cluster_energy = 1,
  },

  connects_to = {
    "group:any_cable",
    "group:yatm_network_device",
    "group:yatm_energy_device",
  },

  postfix = "_15",
}, 6 * SIXTEENTH)

yatm_cables.register_cable({
  basename = "yatm_cables:small_cable",

  name = "yatm_cables:small_cable",
  description = "Small Cable",

  codex_entry_id = "yatm_cables:multi_cable",

  --texture_basename = "yatm_small_cable_",
  texture_basename = "yatm_medium_cable",

  default_state = "off",
  states =  {"on", "off", "error"},

  groups = {
    cracky = 1,
    any_cable = 1,
    energy_cable = 1,
    network_cable = 1,
    small_cable = 1,
    yatm_cluster_device = 1,
    yatm_cluster_energy = 1,
  },

  connects_to = {
    "group:any_cable",
    "group:yatm_network_device",
    "group:yatm_energy_device",
  },

  postfix = "_15",
}, 4 * SIXTEENTH)

-- Glass cables are device cables, they do not carry power
local glass_sounds = yatm.node_sounds:build("glass")

yatm_cables.register_cable({
  basename = "yatm_cables:pipe_glass",

  name = "yatm_cables:pipe_glass", -- TODO: rename to glass_cable
  description = "Glass Cable",

  codex_entry_id = "yatm_cables:glass_cable",

  texture_basename = "yatm_pipe.glass",
  states = false,
  sounds = glass_sounds,

  groups = {
    cracky = 1,
    any_cable = 1,
    glass_cable = 1,
    yatm_cluster_cable = 1,
    yatm_cluster_device = 1,
  },

  connects_to = {
    "group:yatm_cluster_cable",
    "group:yatm_network_device",
  },

  postfix = "_15",
}, 4 * SIXTEENTH)

yatm_cables.register_cable({
  basename = "yatm_cables:pipe_glass_rb",

  name = "yatm_cables:pipe_glass_rb",
  description = "Glass Cable (Red/Black)",

  codex_entry_id = "yatm_cables:glass_cable",

  texture_basename = "yatm_pipe.glass.red.black.couplings",
  states = false,
  sounds = glass_sounds,

  groups = {
    cracky = 1,
    any_cable = 1,
    glass_cable = 1,
    yatm_cluster_cable = 1,
    yatm_cluster_device = 1,
  },

  connects_to = {
    "group:yatm_cluster_cable",
    "group:yatm_network_device",
  },

  postfix = "_15",
}, 4 * SIXTEENTH)

yatm_cables.register_cable({
  basename = "yatm_cables:pipe_glass_yb",

  name = "yatm_cables:pipe_glass_yb",
  description = "Glass Cable (Yellow/Black)",

  codex_entry_id = "yatm_cables:glass_cable",

  texture_basename = "yatm_pipe.glass.yellow.black.couplings",
  states = false,
  sounds = glass_sounds,

  groups = {
    cracky = 1,
    any_cable = 1,
    glass_cable = 1,
    yatm_cluster_cable = 1,
    yatm_cluster_device = 1,
  },

  connects_to = {
    "group:yatm_cluster_cable",
    "group:yatm_network_device",
  },

  postfix = "_15",
}, 4 * SIXTEENTH)

-- Standard pipe cables only carry energy
yatm_cables.register_cable({
  basename = "yatm_cables:pipe_rb",

  name = "yatm_cables:pipe_rb",
  description = "Pipe (Red/Black)",

  codex_entry_id = "yatm_cables:energy_cable",

  texture_basename = "yatm_pipe.red.black.couplings",
  states = false,

  groups = {
    cracky = 1,
    any_cable = 1,
    energy_cable = 1,
    yatm_cluster_energy = 1,
  },

  connects_to = {
    "group:energy_cable",
    "group:yatm_energy_device",
  },

  postfix = "_15",
}, 4 * SIXTEENTH)

yatm_cables.register_cable({
  basename = "yatm_cables:pipe_yb",

  name = "yatm_cables:pipe_yb",
  description = "Pipe (Yellow/Black)",

  codex_entry_id = "yatm_cables:energy_cable",

  texture_basename = "yatm_pipe.yellow.black.couplings",
  states = false,

  groups = {
    cracky = 1,
    any_cable = 1,
    energy_cable = 1,
    yatm_cluster_energy = 1,
  },

  connects_to = {
    "group:energy_cable",
    "group:yatm_energy_device",
  },

  postfix = "_15",
}, 4 * SIXTEENTH)

--
-- Copper Cables only carry energy
--
yatm_cables.register_cable({
  basename = "yatm_cables:copper_cable_uninsulated",

  name = "yatm_cables:copper_cable_uninsulated",
  description = "Copper Cable (Uninsulated)",

  codex_entry_id = "yatm_cables:copper_cable",

  texture_basename = "yatm_copper_cable_side.uninsulated",
  states = false,

  groups = {
    cracky = 1,
    copper_cable = 1,
    copper_cable_uninsulated = 1,
    energy_cable = 1,
    yatm_cluster_energy = 1,
  },

  connects_to = {
    "group:energy_cable",
    "group:copper_cable",
    "group:yatm_energy_device",
  },

  postfix = "",
}, 4 * SIXTEENTH)

do
  for _,row in ipairs(yatm.colors_with_default) do
    local color_basename = row.name
    local color_name = row.description

    local colored_group_name = "copper_cable_" .. color_basename
    local groups = {
      cracky = 1,
      copper_cable = 1,
      [colored_group_name] = 1,
      energy_cable = 1,
      yatm_cluster_energy = 1,
    }

    local node_name = "yatm_cables:copper_cable_" .. color_basename

    yatm_cables.register_cable({
      basename = "yatm_cables:copper_cable",
      base_description = "Copper Cable",

      name = node_name,
      description = "Copper Cable (" .. color_name .. ")",

      codex_entry_id = "yatm_cables:copper_cable",

      texture_basename = "yatm_copper_cable_" .. color_basename .. ".on",
      states = false,

      cable_color = color_basename,

      groups = groups,
      connects_to = {
        "group:copper_cable_uninsulated",
        "group:" .. colored_group_name,
        "group:yatm_energy_device",
      },

      postfix = "",
    }, 6 * SIXTEENTH)
  end
end
