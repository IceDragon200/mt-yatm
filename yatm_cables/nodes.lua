--
-- YATM Cables
--
local bit = yatm_core.bit
local cables = yatm_core.cables

local function calculate_cable_index_and_facedir(origin)
  local index64 = 0
  for dir_code, vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
    local pos = vector.add(origin, vec3)
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      -- check if the node works with the yatm network
      if nodedef.yatm_network then
        print("FOUND DEVICE", pos.x, pos.y, pos.z, "DIR", dir_code, "DIRV3", vec3.x, vec3.y, vec3.z)
        -- if it does, we can connect to it
        -- in the future this should check the subtypes and what cable type it's trying to connect
        index64 = bit.bor(index64, dir_code)
      end
    else
      print("WARN: Missing nodedef for " .. node.name)
    end
  end
  local entry = cables.index64_to_index18_and_facedir_table[index64 + 1]
  return entry[1], entry[2]
end

function yatm_cables.default_yatm_notify_neighbours_changed(origin)
  local origin_node = minetest.get_node(origin)
  for dir_code, vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
    local pos = vector.add(origin, vec3)
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    -- check if the node works with the yatm network
    if nodedef and nodedef.on_yatm_device_changed then
      nodedef.on_yatm_device_changed(pos, node, origin, origin_node)
    end
  end
end

local function refresh_cable_joint(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    local joint_index, face_dir = calculate_cable_index_and_facedir(pos)
    local new_cable_node_name = nodedef.yatm_network.cable_basename .. "_" .. joint_index
    node.name = new_cable_node_name
    node.param2 = face_dir
    minetest.swap_node(pos, node)
  end
end

local function handle_on_yatm_device_changed(pos, node, _origin, _origin_node)
  -- updates the cable's joint
  refresh_cable_joint(pos, node)
end

local function handle_after_place_node(pos)
  local node = minetest.get_node(pos)
  refresh_cable_joint(pos, node)
  -- let the system know it needs to refresh the network topography
  yatm_core.Network.schedule_refresh_network_topography(pos, {kind = "cable_added"})
  yatm_cables.default_yatm_notify_neighbours_changed(pos)
end

local function handle_after_destruct(pos, _old_node)
  print("cable destroyed, alerting neighbours")
  local node = minetest.get_node(pos)
  -- let the system know it needs to refresh the network topography
  yatm_core.Network.schedule_refresh_network_topography(pos, {kind = "cable_removed"})
  yatm_cables.default_yatm_notify_neighbours_changed(pos)
end

local CABLE = "cable"
local function register_cable_state(params, thickness)
  local texture_basename = assert(params.texture_basename, "expected a texture_basename")
  for i = 0,17 do
    local node_box = cables.generate_cable_joint_node_box(thickness, i)
    local groups = {cracky = 1}
    local not_in_creative_inventory = i > 0;
    if params.state then
      if params.state ~= "off" then
        not_in_creative_inventory = true;
      end
    end
    if not_in_creative_inventory then
      groups.not_in_creative_inventory = 1
    end

    -- This contains all the possible alternate states for the cable in this index.
    local states = {}
    local node_name = ""
    if params.state then
      -- the cable has multiple states
      for _,sub_state in ipairs(params.states) do
        states[sub_state] = "yatm_cables:" .. params.name .. "_" .. sub_state .. "_" .. i
      end
      -- conflict is aliased as error
      states["conflict"] = states["error"]
      node_name = states[params.state]
    else
      -- table does not have multiple states
      states["default"] = "yatm_cables:" .. params.name .. "_" .. i
      node_name = states["default"]
    end

    local cable_basename = "";
    if params.state then
      cable_basename = "yatm_cables:" .. params.name .. "_" .. params.state
    else
      cable_basename = "yatm_cables:" .. params.name
    end

    -- configure the yatm network behaviour
    local yatm_network = {
      cable_basename = cable_basename,
      cable_index = i,
      states = states, -- it has the following substates
      kind = CABLE, -- this is a cable
      groups = {
        energy_cable = 1, -- this cable can transport energy
        data_cable = 1, -- this cable can transport data
        network_cable = 1, -- this cable can be used for networking
        dense_cable = 1, -- this cable is dense
      },
      on_network_state_changed = yatm_core.Network.default_on_network_state_changed,
    }

    assert(params.postfix, "expected a postfix, even an empty string")

    local tiles = {
      texture_basename .. params.postfix .. cables.cable_texture_index(yatm_core.D_UP, i) .. ".png",
      texture_basename .. params.postfix .. cables.cable_texture_index(yatm_core.D_DOWN, i) .. ".png",
      texture_basename .. params.postfix .. cables.cable_texture_index(yatm_core.D_EAST, i) .. ".png",
      texture_basename .. params.postfix .. cables.cable_texture_index(yatm_core.D_WEST, i) .. ".png",
      texture_basename .. params.postfix .. cables.cable_texture_index(yatm_core.D_NORTH, i) .. ".png",
      texture_basename .. params.postfix .. cables.cable_texture_index(yatm_core.D_SOUTH, i) .. ".png",
    }

    print("Registering cable node " .. node_name)
    minetest.register_node(node_name, {
      description = params.description,
      groups = groups,
      is_ground_content = false,
      drop = params.drop,
      tiles = tiles,
      paramtype = "light",
      paramtype2 = "facedir",
      drawtype = "nodebox",
      node_box = {
        type = "fixed",
        fixed = node_box
      },
      after_place_node = handle_after_place_node,
      after_destruct = handle_after_destruct,
      yatm_network = yatm_network,
      on_yatm_device_changed = handle_on_yatm_device_changed,
      on_yatm_network_changed = yatm_core.Network.default_handle_network_changed,
    })
  end
end

function yatm_cables.register_cable(params, thickness)
  local cable_states = params.states

  if type(cable_states) == "table" then
    for _,state in ipairs(cable_states) do
      local state_postfix = "." .. state .. "_"
      register_cable_state({
        name = params.name,
        description = params.description,
        texture_basename = params.texture_basename,
        drop = params.drop,
        postfix = state_postfix,
        state = state,
        states = cable_states,
      }, thickness)
    end
  elseif cable_states == false then
    register_cable_state({
      name = params.name,
      description = params.description,
      texture_basename = params.texture_basename,
      drop = params.drop,
      postfix = "_",
      state = false,
      states = {},
    }, thickness)
  end
end

--yatm_cables.register_cable(10 * PX)
yatm_cables.register_cable({
  name = "dense_cable",
  description = "Dense Cable",
  texture_basename = "yatm_dense_cable",
  states =  {"on", "off", "error"},
  drop = "yatm_cables:dense_cable_off_0",
}, 8 * yatm_core.PX16)
yatm_cables.register_cable({
  name = "medium_cable",
  description = "Medium Cable",
  texture_basename = "yatm_medium_cable",
  states =  {"on", "off", "error"},
  drop = "yatm_cables:medium_cable_off_0",
}, 6 * yatm_core.PX16)
yatm_cables.register_cable({
  name = "small_cable",
  description = "Small Cable",
  --texture_basename = "yatm_small_cable_",
  texture_basename = "yatm_medium_cable",
  states =  {"on", "off", "error"},
  drop = "yatm_cables:small_cable_off_0",
}, 4 * yatm_core.PX16)

yatm_cables.register_cable({
  name = "pipe_glass",
  description = "Glass Pipe",
  texture_basename = "yatm_pipe.glass",
  states = false,
  drop = "yatm_cables:glass_pipe_0",
}, 4 * yatm_core.PX16)

yatm_cables.register_cable({
  name = "pipe_glass_rb",
  description = "Glass Pipe (Red/Black)",
  texture_basename = "yatm_pipe.glass.red.black.couplings",
  states = false,
  drop = "yatm_cables:pipe_glass_rb_0",
}, 4 * yatm_core.PX16)

yatm_cables.register_cable({
  name = "pipe_glass_yb",
  description = "Glass Pipe (Yellow/Black)",
  texture_basename = "yatm_pipe.glass.yellow.black.couplings",
  states = false,
  drop = "yatm_cables:pipe_glass_yb_0",
}, 4 * yatm_core.PX16)

yatm_cables.register_cable({
  name = "pipe_rb",
  description = "Pipe (Red/Black)",
  texture_basename = "yatm_pipe.red.black.couplings",
  states = false,
  drop = "yatm_cables:pipe_rb",
}, 4 * yatm_core.PX16)

yatm_cables.register_cable({
  name = "pipe_yb",
  description = "Pipe (Yellow/Black)",
  texture_basename = "yatm_pipe.yellow.black.couplings",
  states = false,
  drop = "yatm_cables:pipe_yb",
}, 4 * yatm_core.PX16)
