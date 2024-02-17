yatm.cables = yatm_cables

local copy_node = assert(foundation.com.copy_node)
local table_merge = assert(foundation.com.table_merge)

local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)

function yatm_cables.cable_on_construct(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.groups["yatm_cluster_device"] then
    cluster_devices:schedule_add_node(pos, node)
  end
  if nodedef.groups["yatm_cluster_energy"] then
    cluster_energy:schedule_add_node(pos, node)
  end
end

function yatm_cables.cable_after_destruct(pos, old_node)
  -- let the system know it needs to refresh the network topography
  local nodedef = minetest.registered_nodes[old_node.name]
  if nodedef.groups["yatm_cluster_device"] then
    cluster_devices:schedule_remove_node(pos, old_node)
  end
  if nodedef.groups["yatm_cluster_energy"] then
    cluster_energy:schedule_remove_node(pos, old_node)
  end
end

function yatm_cables.cable_transition_device_state(pos, node, state, reason)
  reason = reason or "cable_transition_device_state"
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.yatm_network.states then
    local new_node_name
    if state == "down" then
      new_node_name = nodedef.yatm_network.states["off"]
    elseif  state == "up" then
      new_node_name = nodedef.yatm_network.states["on"]
    elseif state == "conflict" then
      new_node_name = nodedef.yatm_network.states["conflict"]
    else
      error("unhandled state=" .. state)
    end

    if new_node_name then
      if node.name ~= new_node_name then
        local new_node = copy_node(node)
        new_node.name = new_node_name
        minetest.swap_node(pos, new_node)

        if nodedef.groups["yatm_cluster_device"] then
          cluster_devices:schedule_update_node(pos, new_node, reason)
        end
        if nodedef.groups["yatm_cluster_energy"] then
          cluster_energy:schedule_update_node(pos, new_node, reason)
        end
      end
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
  local yatm_network = {
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
    params.drop = yatm_network.states[yatm_network.default_state]
  end

  local connects_to = {}
  if params.connects_to then
    connects_to = params.connects_to
  else
    table.insert(connects_to, name)
  end

  local groups = {
    cracky = nokore.dig_class("copper"),
  }
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
    use_texture_alpha = "opaque",

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

    on_construct = yatm_cables.cable_on_construct,
    after_destruct = yatm_cables.cable_after_destruct,

    transition_device_state = yatm_cables.cable_transition_device_state,

    yatm_network = yatm_network,

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
