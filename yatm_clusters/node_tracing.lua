--
-- Cluster Discovery
--
local is_empty = yatm_core.is_table_empty
local vector4 = yatm_core.vector4
local DIR6_TO_VEC3 = yatm_core.DIR6_TO_VEC3
local invert_dir = yatm_core.invert_dir

function yatm_clusters.explore_nodes(origin, acc, reducer)
  local seen = {}
  local to_visit = {origin}

  while not is_empty(to_visit) do
    local new_to_visit = {}
    local n = 0
    for _,pos4 in ipairs(to_visit) do
      local hash = hash_pos(pos4)
      if not seen[hash] then
        seen[hash] = true
        local node = minetest.get_node(pos4)

        local accessible_dirs = {}
        local explore_neighbours
        for dir,_ in pairs(DIR6_TO_VEC3) do
          accessible_dirs[dir] = true
        end

        explore_neighbours, acc = reducer(pos, node, acc, accessible_dirs)

        if explore_neighbours then
          for dir,flag in pairs(accessible_dirs) do
            if flag and pos4.w ~= dir then
              local dirv3 = DIR6_TO_VEC3[dir]
              n = n + 1
              local npos4 = vector4.add({}, pos4, vec3)
              npos4.w = invert_dir(dir)
              new_to_visit[n] = npos4
            end
          end
        end
      end
    end
    to_visit = new_to_visit
  end
  return acc
end
