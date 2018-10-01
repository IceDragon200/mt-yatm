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
    -- check if the node works with the yatm network
    if nodedef.yatm_network then
      print("FOUND DEVICE", pos.x, pos.y, pos.z, "DIR", dir_code, "DIRV3", vec3.x, vec3.y, vec3.z)
      -- if it does, we can connect to it
      -- in the future this should check the subtypes and what cable type it's trying to connect
      index64 = bit.bor(index64, dir_code)
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
function yatm_cables.register_cable(params, thickness)
  local texture_basename = params.texture_basename

  local cable_states = {"on", "off", "error"}

  for _,state in ipairs(cable_states) do
    local state_postfix = "." .. state .. "_"
    for i = 0,17 do
      local node_box = cables.generate_cable_joint_node_box(thickness, i)
      local groups = {cracky = 1}
      if i > 0 or state ~= "off" then
        groups.not_in_creative_inventory = 1
      end
      local states = {}

      for _,sub_state in ipairs(cable_states) do
        states[sub_state] = "yatm_cables:" .. params.name .. "_" .. sub_state .. "_" .. i
      end
      states["conflict"] = states["error"]

      minetest.register_node(states[state], {
        description = params.description,
        groups = groups,
        is_ground_content = false,
        drop = "yatm_cables:" .. params.name .. "_off_0",
        tiles = {
          texture_basename .. state_postfix .. cables.cable_texture_index(yatm_core.D_UP, i) .. ".png",
          texture_basename .. state_postfix .. cables.cable_texture_index(yatm_core.D_DOWN, i) .. ".png",
          texture_basename .. state_postfix .. cables.cable_texture_index(yatm_core.D_EAST, i) .. ".png",
          texture_basename .. state_postfix .. cables.cable_texture_index(yatm_core.D_WEST, i) .. ".png",
          texture_basename .. state_postfix .. cables.cable_texture_index(yatm_core.D_NORTH, i) .. ".png",
          texture_basename .. state_postfix .. cables.cable_texture_index(yatm_core.D_SOUTH, i) .. ".png",
        },
        paramtype = "light",
        paramtype2 = "facedir",
        drawtype = "nodebox",
        node_box = {
          type = "fixed",
          fixed = node_box
        },
        after_place_node = handle_after_place_node,
        after_destruct = handle_after_destruct,
        yatm_network = {
          cable_basename = "yatm_cables:" .. params.name .. "_" .. state,
          cable_index = i,
          states = states,
          kind = CABLE,
          groups = {
            energy_cable = 1,
            data_cable = 1,
            network_cable = 1,
            dense_cable = 1,
          },
        },
        on_yatm_device_changed = handle_on_yatm_device_changed,
        on_yatm_network_changed = yatm_core.Network.default_handle_network_changed,
      })
    end
  end
end

--yatm_cables.register_cable(10 * PX)
yatm_cables.register_cable({
  name = "dense_cable",
  description = "Dense Cable",
  texture_basename = "yatm_dense_cable",
}, 8 * yatm_core.PX16)
yatm_cables.register_cable({
  name = "medium_cable",
  description = "Medium Cable",
  texture_basename = "yatm_medium_cable",
}, 6 * yatm_core.PX16)
yatm_cables.register_cable({
  name = "small_cable_on",
  description = "Small Cable",
  --texture_basename = "yatm_small_cable_",
  texture_basename = "yatm_medium_cable",
}, 4 * yatm_core.PX16)
