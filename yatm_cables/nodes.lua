--
-- YATM Cables
--
local bit = yatm_cables.bit

local PX = 1 / 16.0

local D_NORTH = 1 -- +Z
local D_EAST = 2 -- +X
local D_SOUTH = 4 -- -Z
local D_WEST = 8 -- -X
local D_DOWN = 16 -- -Y
local D_UP = 32 -- +Y

local V3_NORTH = vector.new(0, 0, 1)
local V3_EAST = vector.new(1, 0, 0)
local V3_SOUTH = vector.new(0, 0, -1)
local V3_WEST = vector.new(-1, 0, 0)
local V3_DOWN = vector.new(0, -1, 0)
local V3_UP = vector.new(0, 1, 0)

local DIR6 = {
  [D_NORTH] = V3_NORTH,
  [D_EAST] = V3_EAST,
  [D_SOUTH] = V3_SOUTH,
  [D_WEST] = V3_WEST,
  [D_DOWN] = V3_DOWN,
  [D_UP] = V3_UP,
}

-- This generates joints from the original 64 indices style
local function generate_cable_joint_node_box64(thickness, i)
  -- DU WSEN
  thickness = thickness / 2
  local to_fill = 0.5 - thickness

  local n = bit.band(i, D_NORTH) == D_NORTH
  local e = bit.band(i, D_EAST) == D_EAST
  local s = bit.band(i, D_SOUTH) == D_SOUTH
  local w = bit.band(i, D_WEST) == D_WEST
  local u = bit.band(i, D_DOWN) == D_DOWN
  local d = bit.band(i, D_UP) == D_UP

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
  local sn = bit.band(i, D_NORTH) == D_NORTH
  local se = bit.band(i, D_EAST) == D_EAST
  local ss = bit.band(i, D_SOUTH) == D_SOUTH
  local sw = bit.band(i, D_WEST) == D_WEST
  local su = bit.band(i, D_DOWN) == D_DOWN
  local sd = bit.band(i, D_UP) == D_UP

  -- cache
  local n, e, s, w

  if face == D_NORTH then
    n = su
    e = sw
    s = sd
    w = se
  end
  if face == D_EAST then
    n = su
    e = sn
    s = sd
    w = ss
  end
  if face == D_SOUTH then
    n = su
    e = se
    s = sd
    w = sw
  end
  if face == D_WEST then
    n = su
    e = ss
    s = sd
    w = sn
  end
  if face == D_DOWN then
    n = ss
    e = se
    s = sn
    w = sw
  end
  if face == D_UP then
    n = sn
    e = se
    s = ss
    w = sw
  end

  local final_index = 0
  if n then
    final_index = bit.bor(final_index, D_NORTH)
  end
  if e then
    final_index = bit.bor(final_index, D_EAST)
  end
  if s then
    final_index = bit.bor(final_index, D_SOUTH)
  end
  if w then
    final_index = bit.bor(final_index, D_WEST)
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
    joint_index = D_NORTH
  elseif d2 == 2 then -- 90
    joint_index = bit.bor(D_NORTH, D_EAST)
  elseif d2 == 3 then -- 180
    joint_index = bit.bor(D_NORTH, D_SOUTH)
  elseif d2 == 4 then -- 270
    joint_index = bit.bor(bit.bor(D_NORTH, D_EAST), D_WEST)
  elseif d2 == 5 then -- 360
    joint_index = bit.bor(bit.bor(bit.bor(D_NORTH, D_EAST), D_SOUTH), D_WEST)
  end
  if i > 5 then
    joint_index = bit.bor(joint_index, D_UP)
  end
  if i > 11 then
    joint_index = bit.bor(joint_index, D_DOWN)
  end
  return joint_index
end

local AXIS_Yp = 0
local AXIS_Ym = 20

local AXIS_Xp = 12
local AXIS_Xm = 16

local AXIS_Zp = 4
local AXIS_Zm = 8

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

  for dir_code, vec in pairs(DIR6) do
    local node_entry = minetest.get_node(vector.add(origin, vec))

    local node = minetest.registered_nodes[node_entry.name]
    -- check if the node works with the yatm network
    if node.yatm_network then
      -- if it does, we can connect to it
      -- in the future this should check the subtypes and what cable type it's trying to connect
      index64 = bit.bor(index64, dir_code)
    end
  end

  local entry = index64_to_index18_and_facedir_table[index64 + 1]
  return entry[1], entry[2]
end

local function trigger_on_cable_connect(origin)
  local origin_node_entry = minetest.get_node(origin)
  local origin_node = minetest.registered_nodes[origin_node_entry.name]
  for dir_code, vec in pairs(DIR6) do
    local pos = vector.add(origin, vec)
    local node_entry = minetest.get_node(pos)
    local node = minetest.registered_nodes[node_entry.name]
    -- check if the node works with the yatm network
    if node.yatm_on_cable_connect then
      node.yatm_on_cable_connect(pos, node_entry, origin, origin_node_entry)
    end
  end
end

local function refresh_cable(pos, node_entry)
  local node = minetest.registered_nodes[node_entry.name]
  local joint_index, face_dir = calculate_cable_index_and_facedir(pos)
  local new_cable_node_name = "yatm_cables:" .. node.yatm_network.cable_name .. "_" .. joint_index
  node_entry.name = new_cable_node_name
  node_entry.param2 = face_dir
  minetest.swap_node(pos, node_entry)
end

local function cable_refresh_on_cable_connect(pos, node_entry, origin, origin_node_entry)
  local origin_node = minetest.registered_nodes[origin_node_entry.name]
  local node = minetest.registered_nodes[node_entry.name]
  if node.yatm_network and origin_node.yatm_network then
    if node.yatm_network.cable_name == origin_node.yatm_network.cable_name then
      refresh_cable(pos, node_entry)
    end
  end
end

function yatm_cables.register_cable(params, thickness)
  local texture_basename = params.texture_basename

  local cable_def = {
    cable_name = params.name,
    groups = {cable = 1, dense = 1, power = 1, data = 1}
  }

  minetest.register_node("yatm_cables:" .. params.name .. "_0", {
    description = "Dense Cable",
    groups = {cracky = 1},
    is_ground_content = false,
    tiles = {
      texture_basename .. cable_texture_index(D_UP, 0) .. ".png",
      texture_basename .. cable_texture_index(D_DOWN, 0) .. ".png",
      texture_basename .. cable_texture_index(D_EAST, 0) .. ".png",
      texture_basename .. cable_texture_index(D_WEST, 0) .. ".png",
      texture_basename .. cable_texture_index(D_NORTH, 0) .. ".png",
      texture_basename .. cable_texture_index(D_SOUTH, 0) .. ".png",
    },
    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = generate_cable_joint_node_box(thickness, 0)
    },
    after_place_node = function (pos)
      local node_entry = minetest.get_node(pos)
      refresh_cable(pos, node_entry)
      trigger_on_cable_connect(pos)
    end,
    yatm_network = cable_def,
    yatm_on_cable_connect = cable_refresh_on_cable_connect
  })

  for i = 1,17 do
    local node_box = generate_cable_joint_node_box(thickness, i)
    minetest.register_node("yatm_cables:" .. params.name .. "_" .. i, {
      description = "Dense Cable "..i,
      groups = {cracky = 1, not_in_creative_inventory = 1},
      is_ground_content = false,
      drop = "yatm_cables:" .. params.name .. "_0",
      tiles = {
        texture_basename .. cable_texture_index(D_UP, i) .. ".png",
        texture_basename .. cable_texture_index(D_DOWN, i) .. ".png",
        texture_basename .. cable_texture_index(D_EAST, i) .. ".png",
        texture_basename .. cable_texture_index(D_WEST, i) .. ".png",
        texture_basename .. cable_texture_index(D_NORTH, i) .. ".png",
        texture_basename .. cable_texture_index(D_SOUTH, i) .. ".png",
      },
      paramtype = "light",
      paramtype2 = "facedir",
      drawtype = "nodebox",
      node_box = {
        type = "fixed",
        fixed = node_box
      },
      yatm_network = cable_def,
      yatm_on_cable_connect = cable_refresh_on_cable_connect
    })
  end
end

--yatm_cables.register_cable(10 * PX)
yatm_cables.register_cable({
  name = "dense_cable",
  texture_basename = "yatm_dense_cable.on_"
}, 8 * PX)
yatm_cables.register_cable({
  name = "medium_cable",
  texture_basename = "yatm_medium_cable.on_"
}, 6 * PX)
yatm_cables.register_cable({
  name = "small_cable",
  texture_basename = "yatm_small_cable_"
}, 4 * PX)
