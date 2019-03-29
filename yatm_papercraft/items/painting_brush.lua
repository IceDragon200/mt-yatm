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
      return
    end
    local facing_axis = yatm_core.facedir_to_face(node.param2, yatm_core.D_UP)
    local new_rotation = yatm_core.cardinal_direction_from(facing_axis, pointed_thing.under, user:get_pos())
    local new_facedir = yatm_core.facedir_from_axis_and_rotation(facing_axis, new_rotation)

    print(yatm_core.inspect_axis_and_rotation(facing_axis, new_rotation), new_facedir)

    local canvases = find_canvases(pos)

    -- Now to arrange the canvases into a 2d table of some sorts
    local canvas_world_map = {}
    for _hash,entry in pairs(canvases) do
      if facing_axis == yatm_core.D_UP then
        canvas_world_map[entry.pos.z] = canvas_world_map[entry.pos.z] or {}
        canvas_world_map[entry.pos.z][entry.pos.x] = entry
      elseif facing_axis == yatm_core.D_DOWN then
        canvas_world_map[entry.pos.z] = canvas_world_map[entry.pos.z] or {}
        canvas_world_map[entry.pos.z][entry.pos.x] = entry
      elseif facing_axis == yatm_core.D_NORTH then
        canvas_world_map[entry.pos.y] = canvas_world_map[entry.pos.y] or {}
        canvas_world_map[entry.pos.y][entry.pos.x] = entry
      elseif facing_axis == yatm_core.D_EAST then
        canvas_world_map[entry.pos.y] = canvas_world_map[entry.pos.y] or {}
        canvas_world_map[entry.pos.y][entry.pos.z] = entry
      elseif facing_axis == yatm_core.D_SOUTH then
        canvas_world_map[entry.pos.y] = canvas_world_map[entry.pos.y] or {}
        canvas_world_map[entry.pos.y][entry.pos.x] = entry
      elseif facing_axis == yatm_core.D_WEST then
        canvas_world_map[entry.pos.y] = canvas_world_map[entry.pos.y] or {}
        canvas_world_map[entry.pos.y][entry.pos.z] = entry
      end
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

    local w = x2 - x1 + 1
    local h = y2 - y1 + 1

    local new_canvas_local_map = {}
    if new_rotation == yatm_core.D_NORTH then
      -- nothing to do
      new_canvas_local_map = canvas_local_map
    elseif new_rotation == yatm_core.D_SOUTH then
      for y,row in pairs(canvas_local_map) do
        -- flip the rows around
        new_canvas_local_map[h - 1 - y] = row
      end
    elseif new_rotation == yatm_core.D_EAST then
      w, h = h, w
      for y,row in pairs(canvas_local_map) do
        for x,entry in pairs(row) do
          new_canvas_local_map[x] = new_canvas_local_map[x] or {}
          new_canvas_local_map[x][y] = entry
        end
      end
    elseif new_rotation == yatm_core.D_WEST then
      w, h = h, w
      for y,row in pairs(canvas_local_map) do
        for x,entry in pairs(row) do
          new_canvas_local_map[x] = new_canvas_local_map[x] or {}
          new_canvas_local_map[x][y] = entry
        end
      end
    else
      print("WARN: no valid rotation")
      new_canvas_local_map = canvas_local_map
    end

    print(dump(new_canvas_local_map))

    -- Now ensure that we have a quad of some kind for real.
    local valid = true
    for y = 0,h-1 do
      if not valid then
        break
      end
      for x = 0,w-1 do
        if not new_canvas_local_map[y][x] then
          print("Missing entry for", x, y)
          valid = false
          break
        end
      end
    end
    print("expecting a painting of", w, h)

    if valid then
      print("canvas is valid")

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

          for cell_name,cell in pairs(painting_entry.cells) do
            local canvas_cell_entry = new_canvas_local_map[cell.pos.y][cell.pos.x]

            local new_node = {
              name = cell_name,
              param2 = new_facedir,
            }
            minetest.swap_node(canvas_cell_entry.pos, new_node)
          end
        end
      end
    else
      print("canvas is not valid!")
    end
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
