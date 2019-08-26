--[[

  The painting brush item is used to change a painting canvas group,
  it will trigger a refresh of the nodes to change the painting.

]]
local Paintings = assert(yatm_papercraft.Paintings)
local Groups = assert(yatm_core.groups)

local function find_canvases(root_pos)
  local result = {}
  local to_search = { root_pos }
  while not yatm_core.is_table_empty(to_search) do
    local old_to_search = to_search
    to_search = {}
    for _,pos in ipairs(old_to_search) do
      local hash = minetest.hash_node_position(pos)
      if not result[hash] then
        local node = minetest.get_node(pos)
        local nodedef = minetest.registered_nodes[node.name]
        if nodedef then
          if Groups.get_item(nodedef, "painting_canvas") then
            result[hash] = {
              pos = pos,
              face = yatm_core.facedir_to_face(node.param2, yatm_core.D_UP),
              node = node,
            }

            -- Canvases explore their 4 cardinals from their top face
            -- That is, if it's placed against the ground it will only explore the x and z axis
            -- On the wall it will explore the x or z and the y axis, depending on what side it's placed.
            for _,code in pairs(yatm_core.DIR4) do
              local new_code = yatm_core.facedir_to_face(node.param2, code)
              local vec3 = yatm_core.DIR6_TO_VEC3[new_code]

              table.insert(to_search, vector.add(pos, vec3))
            end
          end
        end
      end
    end
  end
  return result
end

local function painting_brush_on_use(itemstack, user, pointed_thing)
  if pointed_thing.type == "node" then
    local pos = pointed_thing.under
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]

    if not Groups.get_item(nodedef, "painting_canvas") then
      print("Target is not a painting_canvas")
      return
    end
    -- Floor mounted paintings are all correct now, but not so much for wall ones
    -- TODO: fix wall mounted paintings
    local facing_axis = yatm_core.facedir_to_face(node.param2, yatm_core.D_UP)
    local facing_rotation = yatm_core.cardinal_direction_from(facing_axis, pointed_thing.under, user:get_pos())
    local new_rotation = yatm_core.invert_dir(facing_rotation)
    local new_facedir = yatm_core.facedir_from_axis_and_rotation(facing_axis, new_rotation)

    print("Axis & Rotation", yatm_core.inspect_axis_and_rotation(facing_axis, facing_rotation),
                             yatm_core.facedir_from_axis_and_rotation(facing_axis, facing_rotation))
    print("Axis & New Rotation", yatm_core.inspect_axis_and_rotation(facing_axis, new_rotation), new_facedir)

    local canvases = find_canvases(pos)

    -- Now to arrange the canvases into a 2d table of some sorts
    local canvas_world_map = {}
    for _hash,entry in pairs(canvases) do
      local y
      local x
      if facing_axis == yatm_core.D_UP or facing_axis == yatm_core.D_DOWN then
        y = entry.pos.z
        x = entry.pos.x
      elseif facing_axis == yatm_core.D_NORTH or facing_axis == yatm_core.D_SOUTH then
        y = entry.pos.y
        x = entry.pos.x
      elseif facing_axis == yatm_core.D_EAST or facing_axis == yatm_core.D_WEST then
        y = entry.pos.y
        x = entry.pos.z
      end

      canvas_world_map[y] = canvas_world_map[y] or {}
      canvas_world_map[y][x] = entry
    end

    -- Then we figure out the extents
    local y1 = nil
    local y2 = nil
    local x1 = nil
    local x2 = nil
    for y,row in pairs(canvas_world_map) do
      if not y1 then
        y1 = y
      elseif y < y1 then
        y1 = y
      end

      if not y2 then
        y2 = y
      elseif y > y2 then
        y2 = y
      end

      for x,entry in pairs(row) do
        if not x1 then
          x1 = x
        elseif x < x1 then
          x1 = x
        end

        if not x2 then
          x2 = x
        elseif x > x2 then
          x2 = x
        end
      end
    end

    assert(x1, "expected x1-coords to be set")
    assert(x2, "expected x2-coords to be set")
    assert(y1, "expected y1-coords to be set")
    assert(y2, "expected y2-coords to be set")

    -- Then we normalize the map2 by subtracting the x1 and y1 from the coords
    local canvas_local_map = {}
    for y,row in pairs(canvas_world_map) do
      local new_row = {}
      for x,entry in pairs(row) do
        new_row[x - x1] = entry
      end
      canvas_local_map[y - y1] = new_row
    end

    -- native width and height
    local nw = x2 - x1 + 1
    local nh = y2 - y1 + 1

    -- Now ensure that we have a quad of some kind for real.
    local valid = true
    for y = 0,nh-1 do
      if not valid then
        break
      end
      for x = 0,nw-1 do
        if not canvas_local_map[y][x] then
          print("Missing entry for", x, y)
          valid = false
          break
        end
      end
    end

    if valid then
      local w
      local h
      local r90 = false
      if facing_rotation == yatm_core.D_NORTH or facing_rotation == yatm_core.D_SOUTH then
        w = nw
        h = nh
      elseif facing_rotation == yatm_core.D_WEST or facing_rotation == yatm_core.D_EAST then
        -- w, h remain the same
        r90 = true
        w = nh
        h = nw
      end

      print("canvas is valid", w, h)

      -- It's valid!
      -- Now we finally lookup a painting that matches the resolution
      local painting_names = Paintings:reduce_while({}, function (name, entry, res)
        if entry.size.w == w and entry.size.h == h then
          table.insert(res, name)
          return true, res
        else
          return true, res
        end
      end)

      if painting_names then
        local new_name = yatm_core.list_get_next(painting_names, nodedef.painting_name)

        if new_name then
          print("painting will be replaced", dump(nodedef.painting_name), new_name)

          -- FIXME: don't directly access members
          local painting_entry = Paintings.members[new_name]

          -- Set all the canvas cells to the painting cells
          for cell_name,cell in pairs(painting_entry.cells) do
            local cx
            local cy
            if r90 then
              cx = cell.pos.y
              cy = cell.pos.x
            else
              cx = cell.pos.x
              cy = cell.pos.y
            end

            local cell_facedir = new_facedir
            if facing_axis == yatm_core.D_UP then
              if facing_rotation == yatm_core.D_NORTH then
                -- north needs it's x coord flipped
                cx = w - 1 - cx
              elseif facing_rotation == yatm_core.D_SOUTH then
                -- south has it's y coord flipped
                cy = h - 1 - cy
              elseif facing_rotation == yatm_core.D_WEST then
                -- needs to have both it's coords flipped
                cx = h - 1 - cx
                cy = w - 1 - cy
              elseif facing_rotation == yatm_core.D_EAST then
                -- east is only normal face
              end
            elseif facing_axis == yatm_core.D_DOWN then
              if facing_rotation == yatm_core.D_NORTH then
                -- is upside down
                cy = h - 1 - cy
                cx = w - 1 - cx
                cell_facedir = yatm_core.facedir_from_axis_and_rotation(facing_axis, facing_rotation)
              elseif facing_rotation == yatm_core.D_SOUTH then
                -- just need to rotate the faces back
                cell_facedir = yatm_core.facedir_from_axis_and_rotation(facing_axis, facing_rotation)
              elseif facing_rotation == yatm_core.D_WEST then
                -- needs to have both it's coords flipped
                --cy = w - 1 - cy
                cx = h - 1 - cx
                cell_facedir = yatm_core.facedir_from_axis_and_rotation(facing_axis, facing_rotation)
              elseif facing_rotation == yatm_core.D_EAST then
                -- east is only normal face
                cy = w - 1 - cy
                cell_facedir = yatm_core.facedir_from_axis_and_rotation(facing_axis, facing_rotation)
              end
            elseif facing_axis == yatm_core.D_NORTH then
              if facing_rotation == yatm_core.D_SOUTH then
                -- is upside down, so it needs to flip it's rotation around
                -- and invert it's y coord
                cx = w - 1 - cx
                cy = h - 1 - cy
                cell_facedir = yatm_core.facedir_from_axis_and_rotation(facing_axis, facing_rotation)
              end
            elseif facing_axis == yatm_core.D_SOUTH then
              if facing_rotation == yatm_core.D_SOUTH then
                -- needs to flip it's y coord
                cy = h - 1 - cy
              end
            elseif facing_axis == yatm_core.D_WEST then
              if facing_rotation == yatm_core.D_SOUTH then
                cx = w - 1 - cx
                cy = h - 1 - cy
                -- rotate clockwise
                cell_facedir = yatm_core.rotate_facedir_face_clockwise(cell_facedir)
              end
            elseif facing_axis == yatm_core.D_EAST then
              if facing_rotation == yatm_core.D_SOUTH then
                -- needs to flip it's y coord
                cy = h - 1 - cy
                -- rotate annti-clockwise
                cell_facedir = yatm_core.rotate_facedir_face_anticlockwise(cell_facedir)
              end
            end

            local canvas_cell_entry = assert(canvas_local_map[cy][cx])

            local new_node = {
              name = cell_name,
              param2 = cell_facedir,
            }
            minetest.swap_node(canvas_cell_entry.pos, new_node)
          end
        end
      end
    else
      print("canvas is not valid!", w, h)
    end
  else
    print("Target is not a node, got", pointed_thing.type)
  end
  return itemstack
end

minetest.register_tool("yatm_papercraft:painting_brush", {
  description = "Painting Brush",

  inventory_image = "yatm_painting_brush_plain.png",

  stack_max = 1,

  on_place = nil,
  on_use = painting_brush_on_use,
})
