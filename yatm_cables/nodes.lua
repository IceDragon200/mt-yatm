--
-- YATM Cables
--
local bit = yatm_cables.bit

-- This generates joints from the original 64 indices style
local function generate_cable_joint_node_box64(thickness, i)
  -- DU WSEN
  thickness = thickness / 2
  local to_fill = 0.5 - thickness

  local n = bit.band(i, yatm_core.D_NORTH) == yatm_core.D_NORTH
  local e = bit.band(i, yatm_core.D_EAST) == yatm_core.D_EAST
  local s = bit.band(i, yatm_core.D_SOUTH) == yatm_core.D_SOUTH
  local w = bit.band(i, yatm_core.D_WEST) == yatm_core.D_WEST
  local u = bit.band(i, yatm_core.D_DOWN) == yatm_core.D_DOWN
  local d = bit.band(i, yatm_core.D_UP) == yatm_core.D_UP

  local list = {}

  -- Core
  table.insert(list, {-thickness, -thickness, -thickness, thickness, thickness, thickness})

  if n then
    table.insert(list, {-thickness, -thickness, 0.5 - to_fill, thickness, thickness, 0.5})
  end

  if e then
    table.insert(list, {0.5 - to_fill, -thickness, -thickness, 0.5, thickness, thickness})
  end

  if s then
    table.insert(list, {-thickness, -thickness, -0.5, thickness, thickness, -0.5 + to_fill})
  end

  if w then
    table.insert(list, {-0.5, -thickness, -thickness, -0.5 + to_fill, thickness, thickness})
  end

  if u then
    table.insert(list, {-thickness, 0.5 - to_fill, -thickness, thickness, 0.5, thickness})
  end

  if d then
    table.insert(list, {-thickness, -0.5, -thickness, thickness, -0.5 + to_fill, thickness})
  end

  return list
end

local function cable_texture_index64(face, i)
  -- source flags
  local sn = bit.band(i, yatm_core.D_NORTH) == yatm_core.D_NORTH
  local se = bit.band(i, yatm_core.D_EAST) == yatm_core.D_EAST
  local ss = bit.band(i, yatm_core.D_SOUTH) == yatm_core.D_SOUTH
  local sw = bit.band(i, yatm_core.D_WEST) == yatm_core.D_WEST
  local su = bit.band(i, yatm_core.D_DOWN) == yatm_core.D_DOWN
  local sd = bit.band(i, yatm_core.D_UP) == yatm_core.D_UP

  -- cache
  local n, e, s, w

  if face == yatm_core.D_NORTH then
    n = su
    e = sw
    s = sd
    w = se
  end
  if face == yatm_core.D_EAST then
    n = su
    e = sn
    s = sd
    w = ss
  end
  if face == yatm_core.D_SOUTH then
    n = su
    e = se
    s = sd
    w = sw
  end
  if face == yatm_core.D_WEST then
    n = su
    e = ss
    s = sd
    w = sn
  end
  if face == yatm_core.D_DOWN then
    n = ss
    e = se
    s = sn
    w = sw
  end
  if face == yatm_core.D_UP then
    n = sn
    e = se
    s = ss
    w = sw
  end

  local final_index = 0
  if n then
    final_index = bit.bor(final_index, yatm_core.D_NORTH)
  end
  if e then
    final_index = bit.bor(final_index, yatm_core.D_EAST)
  end
  if s then
    final_index = bit.bor(final_index, yatm_core.D_SOUTH)
  end
  if w then
    final_index = bit.bor(final_index, yatm_core.D_WEST)
  end

  return final_index
end

local function index18_to_index64(i)
-- 0 - 0000 - o
-- 1 - 0001 - i
-- 2 - 0010 - |
-- 3 - 0011 - L
-- 4 - 0100 - _|_
-- 5 - 0101 - +
  local joint_index = 0
  local d2 = i % 6
  if d2 == 1 then -- 0
    joint_index = yatm_core.D_NORTH
  elseif d2 == 2 then -- 90
    joint_index = bit.bor(yatm_core.D_NORTH, yatm_core.D_EAST)
  elseif d2 == 3 then -- 180
    joint_index = bit.bor(yatm_core.D_NORTH, yatm_core.D_SOUTH)
  elseif d2 == 4 then -- 270
    joint_index = bit.bor(bit.bor(yatm_core.D_NORTH, yatm_core.D_EAST), yatm_core.D_WEST)
  elseif d2 == 5 then -- 360
    joint_index = bit.bor(bit.bor(bit.bor(yatm_core.D_NORTH, yatm_core.D_EAST), yatm_core.D_SOUTH), yatm_core.D_WEST)
  end
  if i > 5 then
    joint_index = bit.bor(joint_index, yatm_core.D_UP)
  end
  if i > 11 then
    joint_index = bit.bor(joint_index, yatm_core.D_DOWN)
  end
  return joint_index
end

local AXIS_Yp = yatm_core.AXIS_Yp
local AXIS_Ym = yatm_core.AXIS_Ym

local AXIS_Xp = yatm_core.AXIS_Xp
local AXIS_Xm = yatm_core.AXIS_Xm

local AXIS_Zp = yatm_core.AXIS_Zp
local AXIS_Zm = yatm_core.AXIS_Zm

local index64_to_index18_and_facedir_table = {
-- {i18, facedir} -- UD WSEN
  {0, 0}, -- 00 0000
  {1, 0}, -- 00 0001
  {1, AXIS_Yp + 1}, -- 00 0010
  {2, 0}, -- 00 0011
  {1, AXIS_Yp + 2}, -- 00 0100
  {3, 0}, -- 00 0101
  {2, AXIS_Yp + 1}, -- 00 0110
  {4, AXIS_Yp + 1}, -- 00 0111
  {1, AXIS_Yp + 3}, -- 00 1000
  {2, AXIS_Yp + 3}, -- 00 1001
  {3, AXIS_Yp + 1}, -- 00 1010
  {4, 0}, -- 00 1011
  {2, AXIS_Yp + 2}, -- 00 1100
  {4, AXIS_Yp + 3}, -- 00 1101
  {4, AXIS_Yp + 2}, -- 00 1110
  {5, 0}, -- 00 1111

  {6 + 0, 0}, -- 01 0000
  {6 + 1, 0}, -- 01 0001
  {6 + 1, AXIS_Yp + 1}, -- 01 0010
  {6 + 2, 0}, -- 01 0011
  {6 + 1, AXIS_Yp + 2}, -- 01 0100
  {6 + 3, 0}, -- 01 0101
  {6 + 2, AXIS_Yp + 1}, -- 01 0110
  {6 + 4, AXIS_Yp + 1}, -- 01 0111
  {6 + 1, AXIS_Yp + 3}, -- 01 1000
  {6 + 2, AXIS_Yp + 3}, -- 01 1001
  {6 + 3, AXIS_Yp + 1}, -- 01 1010
  {6 + 4, 0}, -- 01 1011
  {6 + 2, AXIS_Yp + 2}, -- 01 1100
  {6 + 4, AXIS_Yp + 3}, -- 01 1101
  {6 + 4, AXIS_Yp + 2}, -- 01 1110
  {6 + 5, 0}, -- 01 1111

  {6 + 0, AXIS_Ym}, -- 10 0000
  {6 + 1, AXIS_Ym}, -- 10 0001
  {6 + 1, AXIS_Ym + 3}, -- 10 0010
  {6 + 2, AXIS_Ym + 3}, -- 10 0011
  {6 + 1, AXIS_Ym + 2}, -- 10 0100
  {6 + 3, AXIS_Ym}, -- 10 0101
  {6 + 2, AXIS_Ym + 2}, -- 10 0110
  {6 + 4, AXIS_Ym + 3}, -- 10 0111
  {6 + 1, AXIS_Ym + 1}, -- 10 1000
  {6 + 2, AXIS_Ym + 0}, -- 10 1001
  {6 + 3, AXIS_Ym + 1}, -- 10 1010
  {6 + 4, AXIS_Ym}, -- 10 1011
  {6 + 2, AXIS_Ym + 1}, -- 10 1100
  {6 + 4, AXIS_Ym + 1}, -- 10 1101
  {6 + 4, AXIS_Ym + 2}, -- 10 1110
  {6 + 5, AXIS_Ym}, -- 10 1111

  {12 + 0, 0}, -- 11 0000
  {12 + 1, 0}, -- 11 0001
  {12 + 1, AXIS_Yp + 1}, -- 11 0010
  {12 + 2, 0}, -- 11 0011
  {12 + 1, AXIS_Yp + 2}, -- 11 0100
  {12 + 3, 0}, -- 11 0101
  {12 + 2, AXIS_Yp + 1}, -- 11 0110
  {12 + 4, AXIS_Yp + 1}, -- 11 0111
  {12 + 1, AXIS_Yp + 3}, -- 11 1000
  {12 + 2, AXIS_Yp + 3}, -- 11 1001
  {12 + 3, AXIS_Yp + 1}, -- 11 1010
  {12 + 4, 0}, -- 11 1011
  {12 + 2, AXIS_Yp + 2}, -- 11 1100
  {12 + 4, AXIS_Yp + 3}, -- 11 1101
  {12 + 4, AXIS_Yp + 2}, -- 11 1110
  {12 + 5, 0}, -- 11 1111
}

local function generate_cable_joint_node_box(thickness, i)
  local joint_index = index18_to_index64(i)
  return generate_cable_joint_node_box64(thickness, joint_index)
end

local function cable_texture_index(dir, i)
  return cable_texture_index64(dir, index18_to_index64(i))
end

local function calculate_cable_index_and_facedir(origin)
  local index64 = 0
  for dir_code, vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
    local pos = vector.add(origin, vec3)
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    -- check if the node works with the yatm network
    if nodedef.yatm_network then
      print("FOUND NODE", pos.x, pos.y, pos.z, "DIR", vec3.x, vec3.y, vec3.z)
      -- if it does, we can connect to it
      -- in the future this should check the subtypes and what cable type it's trying to connect
      index64 = bit.bor(index64, dir_code)
    end
  end
  local entry = index64_to_index18_and_facedir_table[index64 + 1]
  return entry[1], entry[2]
end

function yatm_cables.default_yatm_notify_neighbours_changed(origin)
  local origin_node = minetest.get_node(origin)
  for dir_code, vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
    local pos = vector.add(origin, vec3)
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    -- check if the node works with the yatm network
    if nodedef.on_yatm_device_changed then
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
  yatm_cables.default_yatm_notify_neighbours_changed(pos)
  -- let the system know it needs to refresh the network topography
  yatm_core.Network.schedule_refresh_network_topography(pos, {kind = "cable_added"})
end

local function handle_after_destruct(pos, _old_node)
  print("cable destroyed, alerting neighbours")
  local node = minetest.get_node(pos)
  yatm_cables.default_yatm_notify_neighbours_changed(pos)
  -- let the system know it needs to refresh the network topography
  yatm_core.Network.schedule_refresh_network_topography(pos, {kind = "cable_removed"})
end

local CABLE = "cable"
function yatm_cables.register_cable(params, thickness)
  local texture_basename = params.texture_basename

  local cable_states = {"on", "off", "error"}

  for _,state in ipairs(cable_states) do
    local state_postfix = "." .. state .. "_"
    for i = 0,17 do
      local node_box = generate_cable_joint_node_box(thickness, i)
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
          texture_basename .. state_postfix .. cable_texture_index(yatm_core.D_UP, i) .. ".png",
          texture_basename .. state_postfix .. cable_texture_index(yatm_core.D_DOWN, i) .. ".png",
          texture_basename .. state_postfix .. cable_texture_index(yatm_core.D_EAST, i) .. ".png",
          texture_basename .. state_postfix .. cable_texture_index(yatm_core.D_WEST, i) .. ".png",
          texture_basename .. state_postfix .. cable_texture_index(yatm_core.D_NORTH, i) .. ".png",
          texture_basename .. state_postfix .. cable_texture_index(yatm_core.D_SOUTH, i) .. ".png",
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
          groups = {cable = 1, dense = 1, power = 1, data = 1}
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
