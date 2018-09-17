---
--- YATM Cables Nodes
---

-- Old version of the cable code, this creates 64 nodes for each possible configuration
-- That's 64 nodes PER cable type

local bit = yatm_cables.bit

local PX = 1 / 16.0

local D_NORTH = 1 -- +Z
local D_EAST = 2 -- +X
local D_SOUTH = 4 -- -Z
local D_WEST = 8 -- -X
local D_DOWN = 16
local D_UP = 32

local function generate_cable_nodeboxes(thickness)
  -- DU WSEN
  thickness = thickness / 2
  local result = {}
  local to_fill = 0.5 - thickness

  for i=0,63 do
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

    result[i] = list
  end

  return result
end

local function cable_texture_index(face, i)
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

local dense_node_boxes = generate_cable_nodeboxes(10 * PX)
local medium_node_boxes = generate_cable_nodeboxes(6 * PX)
local small_node_boxes = generate_cable_nodeboxes(4 * PX)

local texture_basename = 'yatm_dense_cable.on_'
for i,node_boxes in pairs(dense_node_boxes) do
  minetest.register_node("yatm_cables:dense_cable_" .. i, {
    description = "Dense Cable "..i,
    groups = {cracky = 1},
    tiles = {
      texture_basename .. cable_texture_index(D_UP, i) .. ".png",
      texture_basename .. cable_texture_index(D_DOWN, i) .. ".png",
      texture_basename .. cable_texture_index(D_EAST, i) .. ".png",
      texture_basename .. cable_texture_index(D_WEST, i) .. ".png",
      texture_basename .. cable_texture_index(D_NORTH, i) .. ".png",
      texture_basename .. cable_texture_index(D_SOUTH, i) .. ".png",
    },
    paramtype = "light",
    paramtype2 = "none",
    legacy_facedir_simple = true,
    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = node_boxes
    }
  })
end

local texture_basename = 'yatm_medium_cable.on_'
for i,node_boxes in pairs(medium_node_boxes) do
  minetest.register_node("yatm_cables:medium_cable_" .. i, {
    description = "Medium Cable "..i,
    groups = {cracky = 1},
    tiles = {
      texture_basename .. cable_texture_index(D_UP, i) .. ".png",
      texture_basename .. cable_texture_index(D_DOWN, i) .. ".png",
      texture_basename .. cable_texture_index(D_EAST, i) .. ".png",
      texture_basename .. cable_texture_index(D_WEST, i) .. ".png",
      texture_basename .. cable_texture_index(D_NORTH, i) .. ".png",
      texture_basename .. cable_texture_index(D_SOUTH, i) .. ".png",
    },
    paramtype = "light",
    paramtype2 = "none",
    legacy_facedir_simple = true,
    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = node_boxes
    }
  })
end

local texture_basename = 'yatm_small_cable_'
for i,node_boxes in pairs(small_node_boxes) do
  minetest.register_node("yatm_cables:small_cable_" .. i, {
    description = "Dense Cable "..i,
    groups = {cracky = 1},
    tiles = {
      texture_basename .. cable_texture_index(D_UP, i) .. ".png",
      texture_basename .. cable_texture_index(D_DOWN, i) .. ".png",
      texture_basename .. cable_texture_index(D_EAST, i) .. ".png",
      texture_basename .. cable_texture_index(D_WEST, i) .. ".png",
      texture_basename .. cable_texture_index(D_NORTH, i) .. ".png",
      texture_basename .. cable_texture_index(D_SOUTH, i) .. ".png",
    },
    paramtype = "light",
    paramtype2 = "none",
    legacy_facedir_simple = true,
    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = node_boxes
    }
  })
end
