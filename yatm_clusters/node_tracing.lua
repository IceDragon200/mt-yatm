--
-- Cluster Discovery
--
local is_empty = yatm_core.is_table_empty
local vector3 = yatm_core.vector3
local DIR6_TO_VEC3 = yatm_core.DIR6_TO_VEC3
local invert_dir = yatm_core.invert_dir

function yatm_clusters.explore_nodes(origin, acc, reducer)
  local seen = {}
  local hash_node_position = minetest.hash_node_position

  local to_visit = {}
  to_visit[hash_node_position(origin)] = origin

  while not is_empty(to_visit) do
    local old_to_visit = to_visit
    to_visit = {}

    for _, pos4 in pairs(old_to_visit) do
      local hash = hash_node_position(pos4)
      if not seen[hash] then
        seen[hash] = true
        local node = minetest.get_node(pos4)

        local accessible_dirs = {}
        local explore_neighbours
        for dir,_ in pairs(DIR6_TO_VEC3) do
          accessible_dirs[dir] = true
        end

        explore_neighbours, acc = reducer(pos4, node, acc, accessible_dirs)

        if explore_neighbours then
          for dir,flag in pairs(accessible_dirs) do
            if flag and pos4.w ~= dir then
              local dirv3 = DIR6_TO_VEC3[dir]
              local npos4 = vector3.add({}, pos4, dirv3)
              npos4.w = invert_dir(dir)
              to_visit[hash_node_position(npos4)] = npos4
            end
          end
        end
      end
    end
  end
  return acc
end