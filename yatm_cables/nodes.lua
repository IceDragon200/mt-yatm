local SIXTEENTH = 1 / 16.0

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
