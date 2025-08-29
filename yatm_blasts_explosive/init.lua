--
-- YATM Blasts - Explosive
--
local mod = foundation.new_module("yatm_blasts_explosive", "0.0.0")

local number_truncate = assert(foundation.com.number_truncate)
local table_copy = assert(foundation.com.table_copy)
local raycast = assert(core.raycast)
local get_name_from_content_id = assert(core.get_name_from_content_id)
local get_node_drops = assert(core.get_node_drops)
local hash_node_position = assert(core.hash_node_position)
local CONTENT_UNKNOWN = assert(core.CONTENT_UNKNOWN)
local CONTENT_AIR = assert(core.CONTENT_AIR)
local CONTENT_IGNORE = assert(core.CONTENT_IGNORE)

local ZERO = vector.new(0, 0, 0)

--- @private.spec calculate_surface_points_of_voxel_sphere(radius: Number, tolerance: Number): (count: Integer, Vector3[])
local function calculate_surface_points_of_voxel_sphere(radius, tolerance)
  if radius <= 0 then
    return {}
  end
  local min = -radius
  local max = radius
  local rmin = radius - 0.5
  rmin = rmin * rmin
  local rmax = radius + 0.5
  rmax = rmax * rmax
  local d

  local result = {}
  local i = 0

  for z = min,max do
    for y = min,max do
      for x = min,max do
        d = y * y + x * x + z * z

        if d >= rmin and d <= rmax then
          i = i + 1
          result[i] = vector.new(x, y, z)
        end
      end
    end
  end

  return i, result
end

--- @private.spec init(ExplosionDef, assigns: Table, BlastsSystem, ExplosionInstance, params: Table): void
local function init(self, assigns, system, explosion, params)
  -- whether or not the explosion checks flammable properties
  assigns.can_ignite = params.can_ignite
  if assigns.can_ignite == nil then
    assigns.can_ignite = true
  end
  -- Either 'player', 'entity:NAME' to mean any entity by name, or 'system:NAME' to denote a specific
  -- subsystem which generated the explosion
  assigns.originator_type = params.originator
  -- The name of the player who caused the explosion
  assigns.originator = params.originator
  -- Should on_blast callbacks be ignored?
  -- This will cause nodes that otherwise would not have been destroyed to be destroyed via the
  -- VoxelManip process
  assigns.ignore_on_blast = params.ignore_on_blast or false
  -- Should node protection be ignored?
  assigns.ignore_protection = params.ignore_protection or false
  -- Do we start from the minimum range and move outwards (+1), or do we start from the maximum
  -- and work inwards (-1)
  assigns.delta = params.delta or 1
  -- Normally you shouldn't need a minimum range, but hey, you do you!
  assigns.min_range = params.min_range or 0
  -- I.e. the maximum radius of the explosion
  assigns.max_range = params.max_range or 3
  if assigns.delta > 0 then
    -- We start at the minimum range and move outwards to the max
    assigns.init_range = assigns.min_range
  elseif assigns.delta < 0 then
    -- We are starting from the maximum range and will work inwards
    assigns.init_range = assigns.max_range
  else
    error("what are you even doing.")
  end
  assigns.range = assigns.init_range
  -- Intensity affects the strength of the explosion, how powerful it is against a node's hardness
  assigns.intensity = params.intensity or 1
  -- TNT travels at around 6900m/s, basically explosions are "instant" in most usecases in game
  -- but you could slow it down if you'd like
  assigns.speed = params.speed or 6900
  --
  assert(assigns.speed > 0, "we cant have a fixture of an explosion, what kind of boring spectacle is that!?")

  assigns.elapsed = 0
end

local function update(self, assigns, system, explosion, dtime)
  if dtime <= 0 then
    return
  end

  local user = ""
  if assigns.originator_type == "player" then
    user = assigns.originator
  end
  -- we only apply the update on non-zero deltas, you know, if time ACTUALLY changed
  -- just to keep track of how much time has actually elapsed
  assigns.elapsed = assigns.elapsed + dtime
  -- whatever the previous range was
  assigns.last_range = assigns.range
  -- adjust the current range based on the delta
  assigns.range = math.min(
    assigns.max_range,
    math.max(assigns.range + assigns.speed * assigns.delta * dtime, assigns.min_range)
  )

  local cpos = explosion.pos
  local cx = cpos.x
  local cy = cpos.y
  local cz = cpos.z

  local r0 = number_truncate(assigns.last_range)
  local r1 = number_truncate(assigns.range)
  -- we've been working in local coordinates since the beginning, now, we actually
  -- expand into world coordinates when grabbing the vm
  local vmin = vector.new(cx - r1, cy - r1, cz - r1)
  local vmax = vector.new(cx + r1, cy + r1, cz + r1)
  local vm = VoxelManip()
  local minp, maxp = vm:read_from_map(vmin, vmax)
  local va = VoxelArea:new{ MinEdge = minp, MaxEdge = maxp }
  local vmi

  local data = vm:get_data()
  local light = vm:get_light_data()
  local param2 = vm:get_param2_data()

  local node = {
    name = "",
    param1 = 0,
    param2 = 0,
  }
  local nodedef
  local ci = 0
  local new_ci = 0
  local new_param2 = 0
  local oeqi = 0
  local on_explosion_queue = {}
  local ocqi = 0
  local on_construct_queue = {}
  local groups
  local pending_drops = {}
  local is_protected = false

  local pos = vector.new(0, 0, 0)
  local minr = assigns.last_range
  local maxr = assigns.range
  local dist
  local seen = {}

  for z = -r1,r1 do
    pos.z = cz + z
    for y = -r1,r1 do
      pos.y = cy + y
      for x = -r1,r1 do
        pos.x = cx + x
        dist = vector.distance(cpos, pos)
        if dist >= minr and dist <= maxr then
          vmi = va:indexp(pos)
          if not seen[vmi] then
            seen[vmi] = true
            ci = data[vmi]
            is_protected = false
            if not assigns.ignore_protection then
              is_protected = core.is_protected(pos, user)
            end

            if is_protected then
              --
            elseif ci then
              print("VMI", vmi)
              new_ci = ci
              new_param2 = param2[vmi]
              node.name = get_name_from_content_id(ci)
              node.param2 = new_param2
              if node.name ~= "ignore" then
                node.param1 = light[vmi]
                nodedef = core.registered_nodes[node.name]
                if nodedef then
                  groups = nodedef.groups

                  if not assigns.ignore_on_blast and (nodedef.on_explosion or nodedef.on_blast) then
                    -- on_explosion is our preferred callback
                    -- on_blast is compatibility for tnt
                    oeqi = oeqi + 1
                    on_explosion_queue[oeqi] = {
                      vmi = vmi,
                      node = table_copy(node),
                      pos = vector.copy(pos),
                      nodedef = nodedef
                    }
                  elseif assigns.can_ignite and (groups["flammable"] or 0) > 0 then
                    -- node is flammable
                    ocqi = ocqi + 1
                    on_construct_queue[ocqi] = {
                      vmi = vmi,
                      org_node = table_copy(node),
                      pos = vector.copy(pos),
                      org_nodedef = nodedef
                    }
                  else
                    -- with drop logic
                    pending_drops[hash_node_position(pos)] = {
                      pos = vector.copy(pos),
                      drops = get_node_drops(
                        node,
                        explosion.kind,
                        nil, -- tool
                        nil, -- digger
                        pos
                      )
                    }
                    new_ci = CONTENT_AIR
                    new_param2 = 0
                  end
                else
                  -- we can't determine the node, so just nuke it
                  new_ci = CONTENT_AIR
                  new_param2 = 0
                end
              end

              -- air everything touched, to check something
              if ci ~= new_ci then
                data[vmi] = new_ci
                param2[vmi] = new_param2
                -- nuke metadata
                core.get_meta(pos):from_table(nil)
              end
            end
          end
        end
      end
    end
  end

  vm:set_data(data)
  vm:set_light_data(light)
  vm:set_param2_data(param2)
  vm:write_to_map()
  vm:update_liquids()
  vm:close()
  -- we're done fiddling with the voxel manipulator, now unto processing the queues

  -- first let's resolve all the pending constructors to rebuild the world state to something stable
  for _, entry in pairs(on_construct_queue) do
    --- @TODO
  end

  -- the let's handle all pending on_explosion or on_blast callbacks
  local dist
  local intensity
  local node_drops
  for _, entry in pairs(on_explosion_queue) do
    nodedef = entry.nodedef

    dist = math.max(1, vector.dist(entry.pos, explosion.pos))
    intensity = assigns.intensity * ((assigns.max_range * assigns.max_range) / (dist * dist))
    if nodedef.on_explosion then
      node_drops = nodedef.on_explosion(entry.pos, entry.node, explosion, intensity)
    elseif nodedef.on_blast then
      node_drops = nodedef.on_blast(entry.pos, intensity)
    else
      node_drops = nil
    end
    if node_drops then
      pending_drops[hash_node_position(entry.pos)] = {
        drops = node_drops,
      }
    end
  end

  do
    local falling_checks = {}
    local vap
    local npos
    local hash
    for vmi, _ in pairs(seen) do
      vap = va:position(vmi)
      for z = -1,1 do
        for y = -1,1 do
          for x = -1,1 do
            npos = vector.new(vap.x + x, vap.y + y, vap.z + z)
            hash = hash_node_position(npos)
            if not falling_checks[hash] then
              falling_checks[hash] = true
              core.check_single_for_falling(npos)
            end
          end
        end
      end
    end
  end

  do
    local drop_pos
    for _, entry in pairs(pending_drops) do
      for _, item_stack in pairs(entry.drops) do
        drop_pos = vector.add(
          entry.pos,
          vector.new(math.random(-8, 8) / 8.0, 0, math.random(-8, 8) / 8.0)
        )
        core.add_item(drop_pos, item_stack)
      end
    end
  end

  if assigns.delta > 0 then
    if assigns.range >= assigns.max_range then
      -- we've reached the end
      explosion.expired = true
    end
  elseif assigns.delta < 0 then
    if assigns.range <= assigns.min_range then
      -- we've reached the end
      explosion.expired = true
    end
  end
end

local function on_expired(self, assigns, system, explosion)
  --
end

yatm.blasts.system:register_explosion_type("yatm:explosive", {
  description = "YATM Explosion",

  init = init,
  update = update,
  on_expired = on_expired,
})
