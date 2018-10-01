--[[
Utility module for generating and managing cable models
]]
local cables = {}

local bit = yatm_core.bit

-- This generates joints from the original 64 indices style
function cables.generate_cable_joint_node_box64(thickness, i)
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

function cables.cable_texture_index64(face, i)
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

function cables.index18_to_index64(i)
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

cables.index64_to_index18_and_facedir_table = {
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

function cables.generate_cable_joint_node_box(thickness, i)
  local joint_index = cables.index18_to_index64(i)
  return cables.generate_cable_joint_node_box64(thickness, joint_index)
end

function cables.cable_texture_index(dir, i)
  return cables.cable_texture_index64(dir, cables.index18_to_index64(i))
end

yatm_core.cables = cables
