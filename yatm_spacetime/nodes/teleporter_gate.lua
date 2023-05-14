---
---
---
local mod = assert(yatm_spacetime)

local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local cluster_gate = assert(yatm.cluster.gate)
local Cuboid = assert(foundation.com.Cuboid)
local is_blank = assert(foundation.com.is_blank)
local Directions = assert(foundation.com.Directions)
local Energy = assert(yatm.energy)
local Groups = assert(foundation.com.Groups)
local SpacetimeMeta = assert(yatm.spacetime.SpacetimeMeta)
local table_merge = assert(foundation.com.table_merge)
local RingBuffer = assert(foundation.com.RingBuffer)
local Vector3 = assert(foundation.com.Vector3)
local hash_node_position = assert(minetest.hash_node_position)
local number_round = assert(foundation.com.number_round)
local spacetime_network = assert(yatm.spacetime.network)

local nb = assert(Cuboid.new_fast_node_box)

local groups = {
  cracky = nokore.dig_class("copper"),
  teleporter_gate = 1,
  yatm_cluster_gate = 1,
  yatm_cluster_device = 1,
  yatm_cluster_energy = 1,
}

--- @spec refresh_infotext(Vector3, NodeRef): void
local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n"
    .. cluster_energy:get_node_infotext(pos) .. "\n"
    .. cluster_gate:get_node_infotext(pos) .. "\n"
    .. "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n"
    -- .. "S.Address: " .. SpacetimeMeta.to_infotext(meta)

  meta:set_string("infotext", infotext)
end

--- @spec find_teleporter_gate_sections(origin_pos: Vector3)
local function find_teleporter_gate_sections(origin_pos)
  --- At absolute worst there should only be 36 positions to visit (6 * 6)
  local to_visit = RingBuffer:new(36)

  local visited = {}

  to_visit:push(origin_pos)

  local pos
  local pos2
  local hash
  local node
  local nodedef
  local dir
  local teleporter_gate

  local result = {}
  local entry

  while to_visit:has_items() do
    pos = to_visit:pop()
    hash = hash_node_position(pos)
    if not visited[hash] then
      visited[hash] = true

      node = minetest.get_node_or_nil(pos)
      if node then
        nodedef = minetest.registered_nodes[node.name]
        if nodedef then
          if Groups.has_group(nodedef, "teleporter_gate") then
            teleporter_gate = nodedef.teleporter_gate
            if teleporter_gate then
              entry = {
                pos = pos,
                hash = hash,
                node = node,
                nodedef = nodedef,
                local_faces = Directions.facedir_to_faces(node.param2),
                dirs = {},
                checked_dirs = {},
                has_error = false,
              }

              result[hash] = entry

              if teleporter_gate.section == "corner" then
                -- Corners only go UP and EAST
                dir = entry.local_faces[Directions.D_UP]
                pos2 = Vector3.add({}, pos, Directions.DIR6_TO_VEC3[dir])
                entry.dirs[Directions.D_UP] = pos2
                to_visit:push(pos2)

                dir = entry.local_faces[Directions.D_EAST]
                pos2 = Vector3.add({}, pos, Directions.DIR6_TO_VEC3[dir])
                entry.dirs[Directions.D_EAST] = pos2
                to_visit:push(pos2)

              elseif teleporter_gate.section == "body" then
                -- Bodies only run horizontal for their frame segments, but must have a core above
                -- it
                dir = entry.local_faces[Directions.D_UP]
                pos2 = Vector3.add({}, pos, Directions.DIR6_TO_VEC3[dir])
                entry.dirs[Directions.D_UP] = pos2
                to_visit:push(pos2)

                dir = entry.local_faces[Directions.D_WEST]
                pos2 = Vector3.add({}, pos, Directions.DIR6_TO_VEC3[dir])
                entry.dirs[Directions.D_WEST] = pos2
                to_visit:push(pos2)

                dir = entry.local_faces[Directions.D_EAST]
                pos2 = Vector3.add({}, pos, Directions.DIR6_TO_VEC3[dir])
                entry.dirs[Directions.D_EAST] = pos2
                to_visit:push(pos2)

              elseif teleporter_gate.section == "core" then
                -- Cores go UP, DOWN, WEST and EAST
                dir = entry.local_faces[Directions.D_WEST]
                pos2 = Vector3.add({}, pos, Directions.DIR6_TO_VEC3[dir])
                entry.dirs[Directions.D_WEST] = pos2
                to_visit:push(pos2)

                dir = entry.local_faces[Directions.D_EAST]
                pos2 = Vector3.add({}, pos, Directions.DIR6_TO_VEC3[dir])
                entry.dirs[Directions.D_EAST] = pos2
                to_visit:push(pos2)

                dir = entry.local_faces[Directions.D_DOWN]
                pos2 = Vector3.add({}, pos, Directions.DIR6_TO_VEC3[dir])
                entry.dirs[Directions.D_DOWN] = pos2
                to_visit:push(pos2)

                dir = entry.local_faces[Directions.D_UP]
                pos2 = Vector3.add({}, pos, Directions.DIR6_TO_VEC3[dir])
                entry.dirs[Directions.D_UP] = pos2
                to_visit:push(pos2)
              else
                error("unexpected section=" .. teleporter_gate.section)
              end
            end
          end
        end
      end
    end
  end

  return result
end

local function same_planar_faces(entry, entry2, face1, face2)
  return entry2.local_faces[face2] == entry.local_faces[face2] or
    entry2.local_faces[face2] == entry.local_faces[face1] or
    entry2.local_faces[face1] == entry.local_faces[face2] or
    entry2.local_faces[face1] == entry.local_faces[face1]
end

local function validate_teleporter_section(entry, sections)
  local dir2
  local pos2
  local hash2
  local entry2

  if entry.nodedef.teleporter_gate.section == "corner" then
    -- The rule is the UP and EAST positions MUST be occupied by either another
    -- corner or a body piece.
    -- Anything else is an error.
    dir2 = Directions.D_UP
    pos2 = entry.dirs[dir2]
    hash2 = hash_node_position(pos2)
    entry.checked_dirs[dir2] = true
    entry2 = sections[hash2]
    if entry2 then
      -- verify that segment is indeed a body or corner
      if entry2.nodedef.teleporter_gate.section == "body" then
        if not (entry2.local_faces[Directions.D_UP] == entry.local_faces[Directions.D_EAST] or
                entry2.local_faces[Directions.D_UP] == entry.local_faces[Directions.D_UP]) then
          -- their inner fins MUST match
          return false
        end

        if not (entry2.local_faces[Directions.D_NORTH] == entry.local_faces[Directions.D_NORTH] or
                entry2.local_faces[Directions.D_SOUTH] == entry.local_faces[Directions.D_NORTH]) then
          -- either the north or south faces of the other section must match this one
          return false
        end
      elseif entry2.nodedef.teleporter_gate.section == "corner" then
        if not (entry2.local_faces[Directions.D_UP] == entry.local_faces[Directions.D_EAST] or
                entry2.local_faces[Directions.D_EAST] == entry.local_faces[Directions.D_UP] or
                entry2.local_faces[Directions.D_EAST] == entry.local_faces[Directions.D_EAST] or
                entry2.local_faces[Directions.D_UP] == entry.local_faces[Directions.D_UP]) then
          -- their inner fins MUST match
          return false
        end

        if not same_planar_faces(entry, entry2, Directions.D_NORTH, Directions.D_SOUTH) then
          -- either the north or south faces of the other section must match this one
          return false
        end
      else
        return false
      end
    else
      -- neighbour section is missing
      return false
    end

    dir2 = Directions.D_EAST
    pos2 = entry.dirs[dir2]
    hash2 = hash_node_position(pos2)
    entry.checked_dirs[dir2] = true
    entry2 = sections[hash2]
    if entry2 then
      -- verify that segment is indeed a body or corner
      if entry2.nodedef.teleporter_gate.section == "body" then
        if not (entry2.local_faces[Directions.D_UP] == entry.local_faces[Directions.D_EAST] or
                entry2.local_faces[Directions.D_UP] == entry.local_faces[Directions.D_UP]) then
          -- their inner fins MUST match
          return false
        end

        if not (entry2.local_faces[Directions.D_NORTH] == entry.local_faces[Directions.D_NORTH] or
                entry2.local_faces[Directions.D_SOUTH] == entry.local_faces[Directions.D_NORTH]) then
          -- either the north or south faces of the other section must match this one
          return false
        end
      elseif entry2.nodedef.teleporter_gate.section == "corner" then
        if not same_planar_faces(entry, entry2, Directions.D_UP, Directions.D_EAST) then
          -- their inner fins MUST match
          return false
        end

        if not same_planar_faces(entry, entry2, Directions.D_NORTH, Directions.D_SOUTH) then
          -- either the north or south faces of the other section must match this one
          return false
        end
      else
        return false
      end
    else
      -- neighbour section is missing
      return false
    end

  elseif entry.nodedef.teleporter_gate.section == "body" then
    --
    dir2 = Directions.D_UP
    pos2 = entry.dirs[dir2]
    hash2 = hash_node_position(pos2)
    entry.checked_dirs[dir2] = true
    entry2 = sections[hash2]
    if entry2 then
      if entry2.nodedef.teleporter_gate.section == "core" then
        if not same_planar_faces(entry, entry2, Directions.D_NORTH, Directions.D_SOUTH) then
          -- either the north or south faces of the other section must match this one
          return false
        end
      elseif entry2.nodedef.teleporter_gate.section == "body" then
        -- So they must be running in the same direction
        if not same_planar_faces(entry, entry2, Directions.D_WEST, Directions.D_EAST) then
          -- their inner fins MUST match
          return false
        end

        if not (entry2.local_faces[Directions.D_DOWN] == entry.local_faces[Directions.D_UP]) then
          -- The UP faces of each section must be opposing each other
          return false
        end

        if not same_planar_faces(entry, entry2, Directions.D_NORTH, Directions.D_SOUTH) then
          -- either the north or south faces of the other section must match this one
          return false
        end
      else
        return false
      end
    else
      return false
    end

    --
    for _, dir3 in ipairs({Directions.D_EAST, Directions.D_WEST}) do
      dir2 = dir3
      pos2 = entry.dirs[dir2]
      hash2 = hash_node_position(pos2)
      entry.checked_dirs[dir2] = true
      entry2 = sections[hash2]
      if entry2 then
        if entry2.nodedef.teleporter_gate.section == "corner" then
          if not same_planar_faces(entry, entry2, Directions.D_NORTH, Directions.D_SOUTH) then
            -- either the north or south faces of the other section must match this one
            return false
          end
        elseif entry2.nodedef.teleporter_gate.section == "body" then
          -- So they must be running in the same direction
          if not same_planar_faces(entry, entry2, Directions.D_WEST, Directions.D_EAST) then
            -- their inner fins MUST match
            return false
          end

          if not (entry2.local_faces[Directions.D_UP] == entry.local_faces[Directions.D_UP]) then
            -- The UP faces of each section must be opposing each other
            return false
          end

          if not same_planar_faces(entry, entry2, Directions.D_NORTH, Directions.D_SOUTH) then
            -- either the north or south faces of the other section must match this one
            return false
          end
        else
          return false
        end
      else
        return false
      end
    end
  elseif entry.nodedef.teleporter_gate.section == "core" then
    --
    for _, dir3 in ipairs({Directions.D_EAST, Directions.D_WEST, Directions.D_UP, Directions.D_DOWN}) do
      dir2 = dir3
      pos2 = entry.dirs[dir2]
      hash2 = hash_node_position(pos2)
      entry.checked_dirs[dir2] = true
      entry2 = sections[hash2]
      if entry2 then
        if entry2.nodedef.teleporter_gate.section == "core" then
          if not same_planar_faces(entry, entry2, Directions.D_NORTH, Directions.D_SOUTH) then
            -- either the north or south faces of the other section must match this one
            return false
          end
        elseif entry2.nodedef.teleporter_gate.section == "body" then
          if not same_planar_faces(entry, entry2, Directions.D_NORTH, Directions.D_SOUTH) then
            -- either the north or south faces of the other section must match this one
            return false
          end
        else
          return false
        end
      else
        return false
      end
    end
  end

  return true
end

--- @spec solve_teleporter_gate(origin_pos: Vector3): Boolean
local function solve_teleporter_gate(origin_pos)
  local sections = find_teleporter_gate_sections(origin_pos)

  if not next(sections) then
    print("No sections found")
    return false
  end

  local is_okay = true
  local pos

  local pos2
  local entry2
  local hash2

  for hash, entry in pairs(sections) do
    pos = entry.pos

    if validate_teleporter_section(entry, sections) then
      -- all good
    else
      -- not good
      is_okay = false
      entry.has_error = true
    end
  end

  local state_name
  if is_okay then
    state_name = "on"
  else
    state_name = "error"
  end

  local node_name
  local new_node
  for _hash, entry in pairs(sections) do
    node_name = entry.nodedef.yatm_network.states[state_name]
    if not node_name then
      error("missing state="..state_name .. " for="..dump(entry.nodedef.yatm_network))
    end
    new_node = {
      name = node_name,
      param1 = entry.node.param1,
      param2 = entry.node.param2,
    }
    minetest.swap_node(entry.pos, new_node)
  end

  return true
end

--- @spec transition_device_state(pos: Vector3, node: NodeRef, state: String): Boolean
local function transition_device_state(pos, node, state)
  yatm.clusters:on_next_tick(function (_clusters, _dtime)
    solve_teleporter_gate(pos)
  end)
  return false
end

local function on_construct(pos)
  local node = minetest.get_node(pos)
  yatm.cluster.gate:schedule_add_node(pos, node)
  yatm.devices.device_on_construct(pos)
end

local function on_destruct(pos)
  local node = minetest.get_node(pos)
  yatm.cluster.gate:schedule_remove_node(pos, node)
  yatm.devices.device_on_destruct(pos)
end

--- @spec on_player_standing_in(pos: Vector3, node: NodeRef, player: PlayerRef, elapsed: Float): void
local function on_player_standing_in(pos, node, player, elapsed)
  if elapsed > 1 then
    local controller_entry = cluster_gate:get_controller_at(pos)
    if controller_entry then
      local meta = minetest.get_meta(controller_entry.pos)
      local address = SpacetimeMeta.get_address(meta)
      if not is_blank(address) then
        local hash = minetest.hash_node_position(controller_entry.pos)
        local other_controllers = {}

        spacetime_network:each_member_in_group_by_address(
          "gate_controller",
          address,
          function (member_hash, member)
            if member_hash ~= hash then
              other_controllers[member_hash] = member
            end
            return true
          end
        )

        local key = next(other_controllers)

        if key and other_controllers[key] then
          local other = other_controllers[key]

          local dest_cluster = cluster_gate:get_node_cluster(other.pos)

          local x1
          local y1
          local z1
          local x2
          local y2
          local z2

          local other_pos
          dest_cluster:reduce_nodes_of_group("gate_section", nil, function (section_entry, acc)
            if Groups.has_group(section_entry, "gate_active") then
              other_pos = section_entry.pos
              if not x1 then
                x1 = other_pos.x
                y1 = other_pos.y
                z1 = other_pos.z
                x2 = other_pos.x
                y2 = other_pos.y
                z2 = other_pos.z
              end

              x1 = math.min(other_pos.x, x1)
              y1 = math.min(other_pos.y, y1)
              z1 = math.min(other_pos.z, z1)

              x2 = math.max(other_pos.x, x2)
              y2 = math.max(other_pos.y, y2)
              z2 = math.max(other_pos.z, z2)
            end

            return true, acc
          end)

          if x1 then
            local x = number_round(x1 + (x2 - x1) / 2)
            local y = number_round(y1 + (y2 - y1) / 2)
            local z = number_round(z1 + (z2 - z1) / 2)

            local dest_pos = vector.new(x, y, z)
            local node = minetest.get_node_or_nil(controller_entry.pos)
            local new_dir = Directions.facedir_to_face(node.param2, Directions.D_NORTH)
            local offset = Directions.DIR6_TO_VEC3[new_dir]
            new_dir = Directions.facedir_to_face(node.param2, Directions.D_SOUTH)
            local yaw = minetest.dir_to_yaw(Directions.DIR6_TO_VEC3[new_dir])

            if player:is_player() then
              local meta = player:get_meta()
              meta:set_float("teleportation_sickness", 3)
              player:set_pos(vector.add(dest_pos, offset))
              player:set_yaw(yaw)
            end
          end
        end
      end
    end
  end
end

local use_texture_alpha = "opaque"

--
-- Corner
--
local corner_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter_gate = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = mod:make_name("teleporter_gate_corner_error"),
    error = mod:make_name("teleporter_gate_corner_error"),
    off = mod:make_name("teleporter_gate_corner"),
    on = mod:make_name("teleporter_gate_corner_on"),
  },

  energy = {
    capacity = 10000,
    passive_lost = 5,
    network_charge_bandwidth = 10,
    startup_threshold = 20,
  },
}

local corner_nodebox = {
  type = "fixed",
  fixed = {
    nb(0, 0, 0, 16,  4, 16), -- bottom panel
    nb(4, 4, 3, 12,  2, 10), -- bottom-fins
    nb(0, 4, 0,  4, 12, 16), -- left panel
    nb(4, 6, 3,  2, 10, 10), -- left-fins
  },
}

local corner_nodebox_active = {
  type = "fixed",
  fixed = {
    nb(0, 0, 0, 16,  4, 16), -- bottom panel
    nb(4, 4, 3, 12, 12, 10), -- fins
    nb(0, 4, 0,  4, 12, 16), -- left panel
  },
}

yatm.devices.register_network_device(mod:make_name("teleporter_gate_corner"), {
  basename = mod:make_name("teleporter_gate_corner"),

  description = mod.S("Teleporter Gate Corner"),

  groups = groups,

  use_texture_alpha = use_texture_alpha,
  tiles = {
    "yatm_teleporter_gate_part_corner.inner_side.png^[transformR270",
    "yatm_teleporter_gate_part_corner.outer_side.png^[transformR270",
    "yatm_teleporter_gate_part_corner.inner_side.png",
    "yatm_teleporter_gate_part_corner.outer_side.png",
    "yatm_teleporter_gate_part_corner.front.png^[transformFX",
    "yatm_teleporter_gate_part_corner.front.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = corner_nodebox,

  collision_box = corner_nodebox,

  yatm_network = corner_yatm_network,

  refresh_infotext = refresh_infotext,

  transition_device_state = transition_device_state,

  on_construct = on_construct,
  on_destruct = on_destruct,

  teleporter_gate = {
    section = "corner",
  },

  yatm_spacetime = {
    groups = {
      gate_section = 1,
      gate_corner = 1,
    },
  },
})

yatm.devices.register_network_device(mod:make_name("teleporter_gate_corner_on"), {
  basename = mod:make_name("teleporter_gate_corner"),

  description = mod.S("Teleporter Gate Corner"),

  groups = table_merge(groups, {
    not_in_creative_inventory = 1,
  }),

  drop = mod:make_name("teleporter_gate_corner"),

  use_texture_alpha = use_texture_alpha,
  tiles = {
    "yatm_teleporter_gate_part_corner.inner_side.on.png^[transformR270",
    "yatm_teleporter_gate_part_corner.outer_side.png^[transformR270",
    "yatm_teleporter_gate_part_corner.inner_side.on.png",
    "yatm_teleporter_gate_part_corner.outer_side.png",
    "yatm_teleporter_gate_part_corner.front.on.png^[transformFX",
    "yatm_teleporter_gate_part_corner.front.on.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = corner_nodebox_active,

  collision_box = corner_nodebox,

  yatm_network = corner_yatm_network,

  refresh_infotext = refresh_infotext,

  transition_device_state = transition_device_state,

  on_construct = on_construct,
  on_destruct = on_destruct,
  on_player_standing_in = on_player_standing_in,

  teleporter_gate = {
    section = "corner",
  },

  yatm_spacetime = {
    groups = {
      gate_active = 1,
      gate_section = 1,
      gate_corner = 1,
    },
  },
})

yatm.devices.register_network_device(mod:make_name("teleporter_gate_corner_error"), {
  basename = mod:make_name("teleporter_gate_corner"),

  description = mod.S("Teleporter Gate Corner"),

  groups = table_merge(groups, {
    not_in_creative_inventory = 1,
  }),

  drop = mod:make_name("teleporter_gate_corner"),

  use_texture_alpha = use_texture_alpha,
  tiles = {
    "yatm_teleporter_gate_part_corner.inner_side.error.png^[transformR270",
    "yatm_teleporter_gate_part_corner.outer_side.png^[transformR270",
    "yatm_teleporter_gate_part_corner.inner_side.error.png",
    "yatm_teleporter_gate_part_corner.outer_side.png",
    "yatm_teleporter_gate_part_corner.front.error.png^[transformFX",
    "yatm_teleporter_gate_part_corner.front.error.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = corner_nodebox_active,

  collision_box = corner_nodebox,

  yatm_network = corner_yatm_network,

  refresh_infotext = refresh_infotext,

  transition_device_state = transition_device_state,

  on_construct = on_construct,
  on_destruct = on_destruct,

  teleporter_gate = {
    section = "corner",
  },

  yatm_spacetime = {
    groups = {
      gate_section = 1,
      gate_corner = 1,
    },
  },
})

--
-- Body
--
local body_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter_gate = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = mod:make_name("teleporter_gate_body_error"),
    error = mod:make_name("teleporter_gate_body_error"),
    off = mod:make_name("teleporter_gate_body"),
    on = mod:make_name("teleporter_gate_body_on"),
  },

  energy = {
    capacity = 10000,
    passive_lost = 5,
    network_charge_bandwidth = 10,
    startup_threshold = 20,
  },
}

local body_node_box = {
  type = "fixed",
  fixed = {
    nb(0, 0, 0, 16, 4, 16), -- main body
    nb(0, 4, 3, 16, 2, 10), -- fins
  },
}

local body_node_box_active = {
  type = "fixed",
  fixed = {
    nb(0, 0, 0, 16, 4, 16), -- main body
    nb(0, 4, 3, 16, 12, 10), -- fins
  },
}

yatm.devices.register_network_device(mod:make_name("teleporter_gate_body"), {
  basename = mod:make_name("teleporter_gate_body"),

  description = mod.S("Teleporter Gate Body"),

  groups = groups,

  use_texture_alpha = use_texture_alpha,
  tiles = {
    "yatm_teleporter_gate_part_body.inner_side.png",
    "yatm_teleporter_gate_part_body.outer_side.png",
    "yatm_teleporter_gate_part_corner.inner_side.png",
    "yatm_teleporter_gate_part_corner.inner_side.png",
    "yatm_teleporter_gate_part_body.front.png",
    "yatm_teleporter_gate_part_body.front.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = body_node_box,

  collision_box = body_node_box,

  yatm_network = body_yatm_network,

  refresh_infotext = refresh_infotext,

  transition_device_state = transition_device_state,

  on_construct = on_construct,
  on_destruct = on_destruct,

  teleporter_gate = {
    section = "body",
  },

  yatm_spacetime = {
    groups = {
      gate_section = 1,
      gate_body = 1,
    },
  },
})

yatm.devices.register_network_device(mod:make_name("teleporter_gate_body_on"), {
  basename = mod:make_name("teleporter_gate_body"),

  description = mod.S("Teleporter Gate Body"),

  groups = table_merge(groups, {
    not_in_creative_inventory = 1,
  }),

  drop = mod:make_name("teleporter_gate_body"),

  use_texture_alpha = use_texture_alpha,
  tiles = {
    "yatm_teleporter_gate_part_body.inner_side.on.png",
    "yatm_teleporter_gate_part_body.outer_side.png",
    "yatm_teleporter_gate_part_corner.inner_side.on.png",
    "yatm_teleporter_gate_part_corner.inner_side.on.png",
    "yatm_teleporter_gate_part_body.front.on.png",
    "yatm_teleporter_gate_part_body.front.on.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = body_node_box_active,

  collision_box = body_node_box,

  yatm_network = body_yatm_network,

  refresh_infotext = refresh_infotext,

  transition_device_state = transition_device_state,

  on_construct = on_construct,
  on_destruct = on_destruct,
  on_player_standing_in = on_player_standing_in,

  teleporter_gate = {
    section = "body",
  },

  yatm_spacetime = {
    groups = {
      gate_active = 1,
      gate_section = 1,
      gate_body = 1,
    },
  },
})

yatm.devices.register_network_device(mod:make_name("teleporter_gate_body_error"), {
  basename = mod:make_name("teleporter_gate_body"),

  description = mod.S("Teleporter Gate Body"),

  groups = table_merge(groups, {
    not_in_creative_inventory = 1,
  }),

  drop = mod:make_name("teleporter_gate_body"),

  use_texture_alpha = use_texture_alpha,
  tiles = {
    "yatm_teleporter_gate_part_body.inner_side.error.png",
    "yatm_teleporter_gate_part_body.outer_side.png",
    "yatm_teleporter_gate_part_corner.inner_side.error.png",
    "yatm_teleporter_gate_part_corner.inner_side.error.png",
    "yatm_teleporter_gate_part_body.front.error.png",
    "yatm_teleporter_gate_part_body.front.error.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = body_node_box_active,

  collision_box = body_node_box,

  yatm_network = body_yatm_network,

  refresh_infotext = refresh_infotext,

  transition_device_state = transition_device_state,

  on_construct = on_construct,
  on_destruct = on_destruct,

  teleporter_gate = {
    section = "body",
  },

  yatm_spacetime = {
    groups = {
      gate_section = 1,
      gate_body = 1,
    },
  },
})

--
-- Core
--
local core_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter_gate = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = mod:make_name("teleporter_gate_core_error"),
    error = mod:make_name("teleporter_gate_core_error"),
    off = mod:make_name("teleporter_gate_core"),
    on = mod:make_name("teleporter_gate_core_on"),
  },

  energy = {
    capacity = 10000,
    passive_lost = 5,
    network_charge_bandwidth = 10,
    startup_threshold = 20,
  },
}

local core_groups = {
  teleporter_gate = 1,
  yatm_cluster_gate = 1,
  yatm_cluster_device = 1,
  yatm_cluster_energy = 1,
}

local core_node_box = {
  type = "fixed",
  fixed = {
    nb(0, 0, 3, 16, 16, 10), -- main body
  },
}

local core_node_box_active = {
  type = "fixed",
  fixed = {
  }
}

local tile = {
  name = "yatm_teleporter_gate_part_core.off.png",
  backface_culling = true,
}

yatm.devices.register_network_device(mod:make_name("teleporter_gate_core"), {
  basename = mod:make_name("teleporter_gate_core"),

  description = mod.S("Teleporter Gate Core"),

  groups = table_merge(core_groups, {
  }),

  drop = "",

  use_texture_alpha = use_texture_alpha,
  tiles = {
    tile,
    tile,
    tile,
    tile,
    tile,
    tile,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = core_node_box,

  walkable = false,
  collision_box = core_node_box_active,

  yatm_network = core_yatm_network,

  refresh_infotext = refresh_infotext,

  transition_device_state = transition_device_state,

  on_construct = on_construct,
  on_destruct = on_destruct,

  teleporter_gate = {
    section = "core",
  },

  yatm_spacetime = {
    groups = {
      gate_section = 1,
      gate_body = 1,
    },
  },
})

tile = {
  name = "yatm_teleporter_gate_part_core.on.png",
  backface_culling = true,
}

yatm.devices.register_network_device(mod:make_name("teleporter_gate_core_on"), {
  basename = mod:make_name("teleporter_gate_core"),

  description = mod.S("Teleporter Gate Core"),

  groups = table_merge(core_groups, {
    not_in_creative_inventory = 1,
  }),

  drop = "",

  use_texture_alpha = use_texture_alpha,
  tiles = {
    tile,
    tile,
    tile,
    tile,
    tile,
    tile,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = core_node_box,

  walkable = false,
  collision_box = core_node_box_active,

  yatm_network = core_yatm_network,

  refresh_infotext = refresh_infotext,

  transition_device_state = transition_device_state,

  on_construct = on_construct,
  on_destruct = on_destruct,
  on_player_standing_in = on_player_standing_in,

  teleporter_gate = {
    section = "core",
  },

  yatm_spacetime = {
    groups = {
      gate_active = 1,
      gate_section = 1,
      gate_core = 1,
    },
  },
})

tile = {
  name = "yatm_teleporter_gate_part_core.error.png",
  backface_culling = true,
}

yatm.devices.register_network_device(mod:make_name("teleporter_gate_core_error"), {
  basename = mod:make_name("teleporter_gate_core"),

  description = mod.S("Teleporter Gate Core"),

  groups = table_merge(core_groups, {
    not_in_creative_inventory = 1,
  }),

  drop = "",

  use_texture_alpha = use_texture_alpha,
  tiles = {
    tile,
    tile,
    tile,
    tile,
    tile,
    tile,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = core_node_box,

  walkable = false,
  collision_box = core_node_box_active,

  yatm_network = core_yatm_network,

  refresh_infotext = refresh_infotext,

  transition_device_state = transition_device_state,

  on_construct = on_construct,
  on_destruct = on_destruct,

  teleporter_gate = {
    section = "core",
  },

  yatm_spacetime = {
    groups = {
      gate_section = 1,
      gate_core = 1,
    },
  },
})
