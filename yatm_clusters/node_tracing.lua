--
-- Cluster Discovery
--
local is_empty = assert(foundation.com.is_table_empty)
local Vector3 = assert(foundation.com.Vector3)
local DIR6_TO_VEC3 = assert(foundation.com.Directions.DIR6_TO_VEC3)
local invert_dir = assert(foundation.com.Directions.invert_dir)
local hash_node_position = assert(core.hash_node_position)
local get_node = assert(tetra.get_node)

--- @namepsace yatm_clusters

--- @spec explore_nodes(
---   origin: Vector3,
---   acc: Any,
---   reducer: (pos4, node: Noderef, acc: Any, accessible_dirs: Table) =>
---     (explore_neighbours: Boolean, acc: Any)
--- ): (acc: Any)
function yatm_clusters.explore_nodes(origin, acc, reducer)
  local seen = {}

  local to_visit = {}
  local accessible_dirs = {}
  local explore_neighbours
  local old_to_visit
  local hash
  local node
  local dirv3
  local npos4

  to_visit[hash_node_position(origin)] = origin

  while not is_empty(to_visit) do
    old_to_visit = to_visit
    to_visit = {}

    for _, pos4 in pairs(old_to_visit) do
      hash = hash_node_position(pos4)
      if not seen[hash] then
        seen[hash] = true
        node = get_node(pos4)

        for dir,_ in pairs(DIR6_TO_VEC3) do
          accessible_dirs[dir] = true
        end

        explore_neighbours, acc = reducer(pos4, node, acc, accessible_dirs)

        if explore_neighbours then
          for dir,flag in pairs(accessible_dirs) do
            if flag and pos4.w ~= dir then
              dirv3 = DIR6_TO_VEC3[dir]
              npos4 = Vector3.add({}, pos4, dirv3)
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
