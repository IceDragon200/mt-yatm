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

-- In case one needs the 4 cardinal directions for whatever reason
yatm_core.DIR4 = {
  yatm_core.D_NORTH,
  yatm_core.D_EAST,
  yatm_core.D_SOUTH,
  yatm_core.D_WEST,
}

yatm_core.DIR6 = {
  yatm_core.D_NORTH,
  yatm_core.D_EAST,
  yatm_core.D_SOUTH,
  yatm_core.D_WEST,
  yatm_core.D_DOWN,
  yatm_core.D_UP,
}

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

yatm_core.DIR4_TO_VEC3 = {
  [yatm_core.D_NORTH] = yatm_core.V3_NORTH,
  [yatm_core.D_EAST] = yatm_core.V3_EAST,
  [yatm_core.D_SOUTH] = yatm_core.V3_SOUTH,
  [yatm_core.D_WEST] = yatm_core.V3_WEST,
}

-- Clockwise and Anti-Clockwise tables
yatm_core.DIR4_CW_ROTATION = {
  [yatm_core.D_NORTH] = yatm_core.D_EAST,
  [yatm_core.D_EAST] = yatm_core.D_SOUTH,
  [yatm_core.D_SOUTH] = yatm_core.D_WEST,
  [yatm_core.D_WEST] = yatm_core.D_NORTH,
}

yatm_core.DIR4_ACW_ROTATION = {
  [yatm_core.D_NORTH] = yatm_core.D_WEST,
  [yatm_core.D_EAST] = yatm_core.D_NORTH,
  [yatm_core.D_SOUTH] = yatm_core.D_EAST,
  [yatm_core.D_WEST] = yatm_core.D_SOUTH,
}

-- Axis Index to Axis facedir offsets
yatm_core.FD_AXIS = {
  [0] = yatm_core.FD_AXIS_Yp,
  [1] = yatm_core.FD_AXIS_Zp,
  [2] = yatm_core.FD_AXIS_Zm,
  [3] = yatm_core.FD_AXIS_Xp,
  [4] = yatm_core.FD_AXIS_Xm,
  [5] = yatm_core.FD_AXIS_Ym,
}

-- Axis index to D_* constant
yatm_core.AXIS = {
  [0] = yatm_core.D_UP,
  [1] = yatm_core.D_NORTH,
  [2] = yatm_core.D_SOUTH,
  [3] = yatm_core.D_EAST,
  [4] = yatm_core.D_WEST,
  [5] = yatm_core.D_DOWN,
}

-- A helper table for converting the D_* constants to strings
yatm_core.DIR_TO_STRING = {
  [yatm_core.D_NONE] = "NONE",
  [yatm_core.D_NORTH] = "NORTH",
  [yatm_core.D_EAST] = "EAST",
  [yatm_core.D_SOUTH] = "SOUTH",
  [yatm_core.D_WEST] = "WEST",
  [yatm_core.D_DOWN] = "DOWN",
  [yatm_core.D_UP] = "UP",
}

-- And the inversions
yatm_core.INVERTED_DIR6 = {
  [yatm_core.D_NONE] = yatm_core.D_NONE,
  [yatm_core.D_SOUTH] = yatm_core.D_NORTH,
  [yatm_core.D_WEST] = yatm_core.D_EAST,
  [yatm_core.D_NORTH] = yatm_core.D_SOUTH,
  [yatm_core.D_EAST] = yatm_core.D_WEST,
  [yatm_core.D_UP] = yatm_core.D_DOWN,
  [yatm_core.D_DOWN] = yatm_core.D_UP,
}
yatm_core.INVERTED_DIR6_TO_VEC3 = {
  [yatm_core.D_SOUTH] = yatm_core.V3_NORTH,
  [yatm_core.D_WEST] = yatm_core.V3_EAST,
  [yatm_core.D_NORTH] = yatm_core.V3_SOUTH,
  [yatm_core.D_EAST] = yatm_core.V3_WEST,
  [yatm_core.D_UP] = yatm_core.V3_DOWN,
  [yatm_core.D_DOWN] = yatm_core.V3_UP,
}

-- Facedir Axis
yatm_core.FD_AXIS_Yp = 0
yatm_core.FD_AXIS_Ym = 20

yatm_core.FD_AXIS_Xp = 12
yatm_core.FD_AXIS_Xm = 16

yatm_core.FD_AXIS_Zp = 4
yatm_core.FD_AXIS_Zm = 8

local fm = function(u, n, s, e, w, d)
  return {
    [yatm_core.D_UP] = u,
    [yatm_core.D_NORTH] = n,
    [yatm_core.D_SOUTH] = s,
    [yatm_core.D_EAST] = e,
    [yatm_core.D_WEST] = w,
    [yatm_core.D_DOWN] = d,
  }
end

local U = yatm_core.D_UP    -- Y+
local N = yatm_core.D_NORTH -- Z+
local S = yatm_core.D_SOUTH -- Z-
local E = yatm_core.D_EAST  -- X+
local W = yatm_core.D_WEST  -- X-
local D = yatm_core.D_DOWN  -- Y-

-- Never again, f*** this seriously.
-- Updated 2019-10-30, changed it a bit
yatm_core.FACEDIR_TO_NEW_FACEDIR = {
  -- Yp
  [0]  = fm(U, N, S, E, W, D),
  [1]  = fm(U, W, E, N, S, D),
  [2]  = fm(U, S, N, W, E, D),
  [3]  = fm(U, E, W, S, N, D),
  -- Zp
  [4]  = fm(S, U, D, E, W, N),
  [5]  = fm(E, U, D, N, S, W),
  [6]  = fm(N, U, D, W, E, S),
  [7]  = fm(W, U, D, S, N, E),
  -- Zm
  [8]  = fm(N, D, U, E, W, S),
  [9]  = fm(W, D, U, N, S, E),
  [10] = fm(S, D, U, W, E, N),
  [11] = fm(E, D, U, S, N, W),
  -- Xp
  [12] = fm(W, N, S, U, D, E),
  [13] = fm(S, E, W, U, D, N),
  [14] = fm(E, S, N, U, D, W),
  [15] = fm(N, W, E, U, D, S),
  -- Xm
  [16] = fm(E, N, S, D, U, W),
  [17] = fm(N, W, E, D, U, S),
  [18] = fm(W, S, N, D, U, E),
  [19] = fm(S, E, W, D, U, N),
  -- Ym
  [20] = fm(D, N, S, W, E, U),
  [21] = fm(D, W, E, S, N, U),
  [22] = fm(D, S, N, E, W, U),
  [23] = fm(D, E, W, N, S, U),
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

-- TODO
--function yatm_core.facedir_to_axis_and_rotation(facedir)
--  local axis_index = math.floor((facedir % 32) / 4)
--  local axis = assert(yatm_core.FD_AXIS[axis_index])
--  return axis, facedir % 4
--end

function yatm_core.facedir_to_fd_axis_and_fd_rotation(facedir)
  local fd_axis = math.floor((facedir % 32) / 4)
  local fd_rotation = (facedir % 4)
  return fd_axis * 4, fd_rotation
end

function yatm_core.rotate_facedir_face_clockwise(facedir)
  local fd_axis, fd_rotation = yatm_core.facedir_to_fd_axis_and_fd_rotation(facedir)
  return fd_axis + ((fd_rotation + 1) % 4)
end

function yatm_core.rotate_facedir_face_anticlockwise(facedir)
  local fd_axis, fd_rotation = yatm_core.facedir_to_fd_axis_and_fd_rotation(facedir)
  return fd_axis + ((fd_rotation - 1) % 4)
end

function yatm_core.rotate_facedir_face_180(facedir)
  local fd_axis, fd_rotation = yatm_core.facedir_to_fd_axis_and_fd_rotation(facedir)
  return fd_axis + ((fd_rotation + 2) % 4)
end

function yatm_core.invert_dir_to_vec3(dir)
  assert(type(dir) == "number", "expected a number")
  return yatm_core.INVERTED_DIR6_TO_VEC3[dir]
end

function yatm_core.invert_dir(dir)
  assert(type(dir) == "number", "expected a number")
  return yatm_core.INVERTED_DIR6[dir]
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

-- done with it, let the gc reclaim it
fm = nil
N = nil
E = nil
S = nil
W = nil
D = nil
U = nil

function yatm_core.vdir_to_wallmounted_facedir(dir)
  if dir.x > 0 then
    return yatm_core.FD_AXIS_Xp
  elseif dir.x < 0 then
    return yatm_core.FD_AXIS_Xm
  end
  if dir.y > 0 then
    return yatm_core.FD_AXIS_Yp
  elseif dir.y < 0 then
    return yatm_core.FD_AXIS_Ym
  end
  if dir.z > 0 then
    return yatm_core.FD_AXIS_Zp
  elseif dir.z < 0 then
    return yatm_core.FD_AXIS_Zm
  end
  return nil
end

function yatm_core.facedir_wallmount_after_place_node(pos, _placer, _itemstack, pointed_thing)
  assert(pointed_thing, "expected a pointed thing")
  local above = pointed_thing.above
  local under = pointed_thing.under
  local dir = {
    x = above.x - under.x,
    y = above.y - under.y,
    z = above.z - under.z
  }
  local node = minetest.get_node(pos)
  node.param2 = yatm_core.vdir_to_wallmounted_facedir(dir)
  minetest.swap_node(pos, node)
end

function yatm_core.rotate_position_by_facedir(p, from_facedir, to_facedir)
  if from_facedir == to_facedir then
    return p
  end

  local n = yatm_core.facedir_to_face(from_facedir, yatm_core.D_NORTH)
  local e = yatm_core.facedir_to_face(from_facedir, yatm_core.D_EAST)
  local u = yatm_core.facedir_to_face(from_facedir, yatm_core.D_UP)

  local to_n = yatm_core.facedir_to_face(to_facedir, n)
  local to_e = yatm_core.facedir_to_face(to_facedir, e)
  local to_u = yatm_core.facedir_to_face(to_facedir, u)

  local vz = yatm_core.DIR6_TO_VEC3[to_n]
  local vx = yatm_core.DIR6_TO_VEC3[to_e]
  local vy = yatm_core.DIR6_TO_VEC3[to_u]

  return {
    x = vx.x * p.x + vy.x * p.y + vz.x * p.z,
    y = vx.y * p.x + vy.y * p.y + vz.y * p.z,
    z = vx.z * p.x + vy.z * p.y + vz.z * p.z,
  }
end

--[[
Determines what direction the `looker` is from the `target`
]]
function yatm_core.cardinal_direction_from(axis, target, looker)
  local normal = {
    x = looker.x - target.x,
    y = looker.y - target.y,
    z = looker.z - target.z,
  }

  if axis == yatm_core.D_UP then
    -- Coordinates are pretty plain and boring
    -- y-axis should be ignored
    local ax = math.abs(normal.x)
    local az = math.abs(normal.z)
    if ax > az then
      if normal.x > 0 then
        return yatm_core.D_EAST
      else
        return yatm_core.D_WEST
      end
    else
      if normal.z > 0 then
        return yatm_core.D_NORTH
      else
        return yatm_core.D_SOUTH
      end
    end
  elseif axis == yatm_core.D_DOWN then
    -- Coordinates are inverted
    -- y-axis should be ignored
    local ax = math.abs(normal.x)
    local az = math.abs(normal.z)
    if ax > az then
      if normal.x > 0 then
        return yatm_core.D_WEST
      else
        return yatm_core.D_EAST
      end
    else
      if normal.z > 0 then
        return yatm_core.D_NORTH
      else
        return yatm_core.D_SOUTH
      end
    end
  elseif axis == yatm_core.D_NORTH then
    -- Coordinates are normal
    -- z-axis should be ignored
    local ax = math.abs(normal.x)
    local ay = math.abs(normal.y)
    if ax > ay then
      if normal.x > 0 then
        return yatm_core.D_EAST
      else
        return yatm_core.D_WEST
      end
    else
      if normal.y > 0 then
        return yatm_core.D_NORTH
      else
        return yatm_core.D_SOUTH
      end
    end
  elseif axis == yatm_core.D_EAST then
    -- Coordinates are normal
    -- x-axis should be ignored
    local ay = math.abs(normal.y)
    local az = math.abs(normal.z)
    if az > ay then
      if normal.z > 0 then
        return yatm_core.D_EAST
      else
        return yatm_core.D_WEST
      end
    else
      if normal.y > 0 then
        return yatm_core.D_NORTH
      else
        return yatm_core.D_SOUTH
      end
    end
  elseif axis == yatm_core.D_SOUTH then
    -- Coordinates are inverted
    -- z-axis should be ignored
    local ax = math.abs(normal.x)
    local ay = math.abs(normal.y)
    if ax > ay then
      if normal.x > 0 then
        return yatm_core.D_WEST
      else
        return yatm_core.D_EAST
      end
    else
      if normal.y > 0 then
        return yatm_core.D_NORTH
      else
        return yatm_core.D_SOUTH
      end
    end
  elseif axis == yatm_core.D_WEST then
    -- Coordinates are inverted
    -- x-axis should be ignored
    local ay = math.abs(normal.y)
    local az = math.abs(normal.z)
    if az > ay then
      if normal.z > 0 then
        return yatm_core.D_WEST
      else
        return yatm_core.D_EAST
      end
    else
      if normal.y > 0 then
        return yatm_core.D_NORTH
      else
        return yatm_core.D_SOUTH
      end
    end
  end
  return yatm_core.D_NONE
end

function yatm_core.axis_to_facedir(axis)
  if axis == yatm_core.D_UP then
    return yatm_core.FD_AXIS_Yp
  elseif axis == yatm_core.D_DOWN then
    return yatm_core.FD_AXIS_Ym
  elseif axis == yatm_core.D_EAST then
    return yatm_core.FD_AXIS_Xp
  elseif axis == yatm_core.D_WEST then
    return yatm_core.FD_AXIS_Xm
  elseif axis == yatm_core.D_SOUTH then
    return yatm_core.FD_AXIS_Zm
  elseif axis == yatm_core.D_NORTH then
    return yatm_core.FD_AXIS_Zp
  end
  return 0
end

function yatm_core.axis_to_facedir_rotation(axis)
  if axis == yatm_core.D_NORTH then
    return 0
  elseif axis == yatm_core.D_EAST then
    return 1
  elseif axis == yatm_core.D_SOUTH then
    return 2
  elseif axis == yatm_core.D_WEST then
    return 3
  end
  return 0
end

--[[
yatm_core.facedir_from_axis_and_rotation(axis :: DIR6, rotation :: DIR4)
]]
function yatm_core.facedir_from_axis_and_rotation(axis, rotation)
  local base = yatm_core.axis_to_facedir(axis)
  return base + yatm_core.axis_to_facedir_rotation(rotation)
end

function yatm_core.inspect_axis(axis)
  return yatm_core.DIR_TO_STRING[axis]
end

function yatm_core.inspect_axis_and_rotation(axis, rotation)
  return yatm_core.DIR_TO_STRING[axis] .. " rotated to " .. yatm_core.DIR_TO_STRING[rotation]
end
