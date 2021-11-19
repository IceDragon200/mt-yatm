-- @namespace yatm.wrench
local Directions = assert(foundation.com.Directions)
local table_copy = assert(foundation.com.table_copy)

yatm.wrench = {}

yatm.wrench.ROTATE_FACE = 'face'
yatm.wrench.ROTATE_AXIS = 'axis'

-- Contains a table of all the supported paramtype2 that can be rotated
yatm.wrench.type_handler = {}

yatm.wrench.type_handler.flowingliquid = false
yatm.wrench.type_handler.leveled = false
-- debatable, but only used by plantlike and mesh
yatm.wrench.type_handler.degrotate = false
yatm.wrench.type_handler.meshoptions = false
yatm.wrench.type_handler.color = false
yatm.wrench.type_handler.glasslikeliquidlevel = false
yatm.wrench.type_handler.colordegrotate = false
yatm.wrench.type_handler.none = false

local function rotate_facedir(rotate_type, facedir, reversed)
  if rotate_type == yatm.wrench.ROTATE_FACE then
    if reversed then
      facedir = Directions.rotate_facedir_face_anticlockwise(facedir)
    else
      facedir = Directions.rotate_facedir_face_clockwise(facedir)
    end
  elseif rotate_type == yatm.wrench.ROTATE_AXIS then
    if reversed then
      facedir = Directions.rotate_facedir_axis_anticlockwise(facedir)
    else
      facedir = Directions.rotate_facedir_axis_clockwise(facedir)
    end
  end

  return facedir
end

-- @mutative
-- @spec type_handler.wallmounted(RotationType, Node, reversed: Boolean): Node
function yatm.wrench.type_handler.wallmounted(rotate_type, node, reversed)
  -- TODO
  return node
end

-- @mutative
-- @spec type_handler.facedir(RotationType, Node, reversed: Boolean): Node
function yatm.wrench.type_handler.facedir(rotate_type, node, reversed)
  -- the original facedir value
  local facedir = rotate_facedir(rotate_type, node.param2, reversed)

  node.param2 = facedir

  return node
end

-- @mutative
-- @spec type_handler.colorfacedir(RotationType, Node, reversed: Boolean): Node
function yatm.wrench.type_handler.colorfacedir(rotate_type, node, reversed)
  -- the original facedir value
  local facedir = node.param2 % 32
  local rest = node.param2 - 32

  facedir = rotate_facedir(rotate_type, facedir, reversed)

  node.param2 = facedir + rest

  return node
end

-- @mutative
-- @spec type_handler.colorwallmounted(RotationType, Node, reversed: Boolean): Node
function yatm.wrench.type_handler.colorwallmounted(rotate_type, node, reversed)
  -- TODO
  return node
end

-- Triggered when a wrench or something wants to rotate the node, this function
-- should return the updated node if any rotations should apply,
-- or nil otherwise
--
-- @mutative
-- @spec calc_rotate_node(rotate_type: ROTATE_AXIS | ROTATE_FACE, pos: Vector3, node: Node, reverse: Boolean): Node | nil
function yatm.wrench.calc_rotate_node(rotate_type, pos, node, reversed)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef.calc_rotate_node == false then
    return nil
  elseif type(nodedef.calc_rotate_node) == "function" then
    return nodedef.calc_rotate_node(rotate_type, pos, node, reversed)
  else
    local handler = yatm.wrench.type_handler[nodedef.paramtype2]

    if handler then
      return handler(rotate_type, node, reversed)
    end
  end
  return nil
end

-- Called when the wrench or caller is now going to commit to rotating the node
-- the updated node is provided as new_node, while the original node is provided
-- as old_node.
--
-- Returns true if the node was successfully rotated, returns false otherwise.
--
-- @spec rotate_node(pos: Vector3, new_node: Node, old_node: Node): Boolean
function yatm.wrench.do_rotate_node(pos, new_node, old_node)
  local nodedef = minetest.registered_nodes[old_node.name]

  local do_rotate_node = nodedef.do_rotate_node

  if do_rotate_node == false then
    return false
  elseif type(do_rotate_node) == "function" then
    return do_rotate_node(pos, new_node, old_node)
  else
    minetest.swap_node(pos, new_node)
    return true
  end

  return false
end

function yatm.wrench.after_rotate_node(pos, node)
  local nodedef = minetest.registered_nodes[node.name]

  local after_rotate_node = nodedef.after_rotate_node

  if type(after_rotate_node) == "function" then
    return after_rotate_node(pos, node)
  end
end

function yatm.wrench.rotate_node(rotate_type, pos, node, reversed)
  local new_node = yatm.wrench.calc_rotate_node(rotate_type, pos, table_copy(node), reversed)

  if new_node then
    if yatm.wrench.do_rotate_node(pos, new_node, node) then
      yatm.wrench.after_rotate_node(pos, new_node)
      return true
    end
  end

  return false
end

function yatm.wrench.rotate_node_at_pos(rotate_type, pos, reversed)
  local node = minetest.get_node_or_nil(pos)
  if node then
    return yatm.wrench.rotate_node(rotate_type, pos, node, reversed)
  end
  return false
end

function yatm.wrench.user_rotate_node_at_pos(user, rotate_type, pos, reversed)
  local player_name

  if user then
    player_name = user:get_player_name()
  end

  if minetest.is_protected(pos, player_name) then
    minetest.record_protection_violation(pos, player_name)
    return false
  end

  return yatm.wrench.rotate_node_at_pos(rotate_type, pos, reversed)
end
