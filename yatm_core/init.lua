--
-- YATM Core
--
yatm_core = rawget(_G, "yatm_core") or {}
yatm_core.modpath = minetest.get_modpath(minetest.get_current_modname())

local env = minetest.request_insecure_environment()
yatm_core.bit = env.require("bit")

yatm_core.PX16 = 1 / 16.0

-- This uses a bit flag map, for quick use with binary-styled representations
-- It does make face values a pain though
-- UD WSEN
yatm_core.D_NONE = 0 -- no direction
yatm_core.D_NORTH = 1 -- +Z
yatm_core.D_EAST = 2 -- +X
yatm_core.D_SOUTH = 4 -- -Z
yatm_core.D_WEST = 8 -- -X
yatm_core.D_DOWN = 16 -- -Y
yatm_core.D_UP = 32 -- +Y

-- Vectors, repsenting the directions
yatm_core.V3_NORTH = vector.new(0, 0, 1)
yatm_core.V3_EAST = vector.new(1, 0, 0)
yatm_core.V3_SOUTH = vector.new(0, 0, -1)
yatm_core.V3_WEST = vector.new(-1, 0, 0)
yatm_core.V3_DOWN = vector.new(0, -1, 0)
yatm_core.V3_UP = vector.new(0, 1, 0)

-- A helper table for converting the D_* constants to their vectors
yatm_core.DIR6_TO_VEC3 = {
  [yatm_core.D_NORTH] = yatm_core.V3_NORTH,
  [yatm_core.D_EAST] = yatm_core.V3_EAST,
  [yatm_core.D_SOUTH] = yatm_core.V3_SOUTH,
  [yatm_core.D_WEST] = yatm_core.V3_WEST,
  [yatm_core.D_DOWN] = yatm_core.V3_DOWN,
  [yatm_core.D_UP] = yatm_core.V3_UP,
}

yatm_core.INVERT_DIR6_TO_VEC3 = {
  [yatm_core.D_SOUTH] = yatm_core.V3_NORTH,
  [yatm_core.D_WEST] = yatm_core.V3_EAST,
  [yatm_core.D_NORTH] = yatm_core.V3_SOUTH,
  [yatm_core.D_EAST] = yatm_core.V3_WEST,
  [yatm_core.D_UP] = yatm_core.V3_DOWN,
  [yatm_core.D_DOWN] = yatm_core.V3_UP,
}

yatm_core.AXIS_Yp = 0
yatm_core.AXIS_Ym = 20

yatm_core.AXIS_Xp = 12
yatm_core.AXIS_Xm = 16

yatm_core.AXIS_Zp = 4
yatm_core.AXIS_Zm = 8

local fm = function(n, e, s, w, d, u)
  return {
    [yatm_core.D_NORTH] = n,
    [yatm_core.D_EAST] = e,
    [yatm_core.D_SOUTH] = s,
    [yatm_core.D_WEST] = w,
    [yatm_core.D_DOWN] = d,
    [yatm_core.D_UP] = u,
  }
end

local N = yatm_core.D_NORTH
local E = yatm_core.D_EAST
local S = yatm_core.D_SOUTH
local W = yatm_core.D_WEST
local D = yatm_core.D_DOWN
local U = yatm_core.D_UP

yatm_core.FACEDIR_TO_NEW_FACEDIR = {
  -- Yp
  [0] = fm(N, E, S, W, D, U),
  [1] = fm(W, N, E, S, D, U),
  [2] = fm(S, W, N, E, D, U),
  [3] = fm(E, S, W, N, D, U),
  -- Zp
  [4] = fm(U, E, D, W, N, S),
  [5] = fm(U, N, D, S, W, E),
  [6] = fm(U, W, D, E, S, N),
  [7] = fm(U, S, D, N, E, W),
  -- Zm
  [8]= fm(D, E, U, W, S, N),
  [9]= fm(D, N, U, S, E, W),
  [10] = fm(D, W, U, E, N, S),
  [11] = fm(D, S, U, N, W, E),
  -- Xp
  [12] = fm(N, U, S, D, E, W),
  [13] = fm(W, U, E, D, N, S),
  [14] = fm(S, U, N, D, W, E),
  [15] = fm(E, U, W, D, S, N),
  -- Xm
  [16] = fm(N, D, S, U, W, E),
  [17] = fm(W, D, E, U, S, N),
  [18] = fm(S, D, N, U, E, W),
  [19] = fm(E, D, W, U, N, S),
  -- Ym
  [20] = fm(N, W, S, E, U, D),
  [21] = fm(W, S, E, N, U, D),
  [22] = fm(S, E, N, W, U, D),
  [23] = fm(E, N, W, S, U, D),
}

yatm_core.FACEDIR_TO_FACES = {}

for facedir, map in pairs(yatm_core.FACEDIR_TO_NEW_FACEDIR) do
  yatm_core.FACEDIR_TO_FACES[facedir] = {}
  for dir, dir2 in pairs(map) do
    -- invert mapping
    yatm_core.FACEDIR_TO_FACES[facedir][dir2] = dir
  end
end

--[[
Args:
* `facedir` :: integer - the facedir

Returns:
* `table` :: a table containing each new face mapped using yatm_core.D_*
]]
function yatm_core.facedir_to_faces(facedir)
  return yatm_core.FACEDIR_TO_FACES[facedir % 32]
end

function yatm_core.facedir_to_face(facedir, base_face)
  assert(base_face, "expected a face")
  assert(facedir, "expected a facedir")
  local faces = yatm_core.facedir_to_faces(facedir)
  if faces then
    return faces[base_face]
  else
    return nil
  end
end

function yatm_core.invert_dir(dir)
  assert(dir)
  return yatm_core.INVERT_DIR6_TO_VEC3[dir]
end

function yatm_core.new_accessible_dirs()
  return {
    [yatm_core.D_NORTH] = true,
    [yatm_core.D_EAST] = true,
    [yatm_core.D_SOUTH] = true,
    [yatm_core.D_WEST] = true,
    [yatm_core.D_DOWN] = true,
    [yatm_core.D_UP] = true,
  }
end

function yatm_core.table_merge(...)
  local result = {}
  for _,t in ipairs({...}) do
    for key,value in pairs(t) do
      result[key] = value
    end
  end
  return result
end

function yatm_core.table_keys(t)
  local keys = {}
  for key,_ in pairs(t) do
    table.insert(keys, key)
  end
  return keys
end

function yatm_core.table_values(t)
  local values = {}
  for _,value in pairs(t) do
    table.insert(values, value)
  end
  return values
end

-- done with it, let the gc reclaim it
fm = nil
N = nil
E = nil
S = nil
W = nil
D = nil
U = nil

function yatm_core.dir_to_wallmounted_facedir(dir)
  if dir.x > 0 then
    return yatm_core.AXIS_Xp
  elseif dir.x < 0 then
    return yatm_core.AXIS_Xm
  end
  if dir.y > 0 then
    return yatm_core.AXIS_Yp
  elseif dir.y < 0 then
    return yatm_core.AXIS_Ym
  end
  if dir.z > 0 then
    return yatm_core.AXIS_Zp
  elseif dir.z < 0 then
    return yatm_core.AXIS_Zm
  end
  return nil
end

function yatm_core.facedir_wallmount_after_place_node(pos, placer, _itemstack, pointed_thing)
  local above = pointed_thing.above
  local under = pointed_thing.under
  local dir = {
    x = above.x - under.x,
    y = above.y - under.y,
    z = above.z - under.z
  }
  local node = minetest.get_node(pos)
  node.param2 = yatm_core.dir_to_wallmounted_facedir(dir)
  minetest.swap_node(pos, node)
end

-- Instrumentation
dofile(yatm_core.modpath .. "/instrumentation.lua")
-- Utility
dofile(yatm_core.modpath .. "/meta_schema.lua")
dofile(yatm_core.modpath .. "/changeset.lua")
dofile(yatm_core.modpath .. "/ui.lua")
dofile(yatm_core.modpath .. "/cables.lua")
dofile(yatm_core.modpath .. "/groups.lua")
-- Network
dofile(yatm_core.modpath .. "/yatm_network.lua")
dofile(yatm_core.modpath .. "/energy.lua")
dofile(yatm_core.modpath .. "/measurable.lua") -- similar to energy, but has a name field too
-- Nodes and Items
dofile(yatm_core.modpath .. "/fluids.lua")
dofile(yatm_core.modpath .. "/nodes.lua")
dofile(yatm_core.modpath .. "/items.lua")

