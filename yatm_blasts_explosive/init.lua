--
-- YATM Blasts - Explosive
--
local mod = foundation.new_module("yatm_blasts_explosive", "0.0.0")

local number_truncate_by_sign = assert(foundation.com.number_truncate_by_sign)
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
    assigns.range = assigns.min_range
  elseif assigns.delta < 0 then
    -- We are starting from the maximum range and will work inwards
    assigns.range = assigns.max_range
  else
    error("what are you even doing.")
  end
  -- Intensity affects the strength of the explosion, how powerful it is against a node's hardness
  assigns.intensity = params.intensity or 1
  -- TNT travels at around 6900m/s, basically explosions are "instant" in most usecases in game
  -- but you could slow it down if you'd like
  assigns.speed = params.speed or 6900
  --
  assert(assigns.speed > 0, "we cant have a fixture of an explosion, what kind of boring spectacle is that!?")
  -- We need to figure out ALL the surface points we need to end on,
  -- yes the position of the explosion... could change so we can't cache that calculation
  assigns.points_count, assigns.max_points = calculate_surface_points_of_voxel_sphere(assigns.max_range)
  assigns.min_points = {}
  assigns.rays = {}
  assigns.dirs = {}
  assigns.velocity = {}
  assigns.trunc_rays = {}
  local ray
  local vel
  for i, point in ipairs(assigns.max_points) do
    if assigns.delta > 0 then
      -- we're moving from min to max, ALWAYS start from zero
      assigns.dirs[i] = vector.direction(ZERO, point)
    elseif assigns.delta < 0 then
      -- we're moving from max to min, always start from the outer point
      assigns.dirs[i] = vector.direction(point, ZERO)
    end
    -- where and how fast do we need to go to get to our next point, obviously this
    -- will cause the ray to exceeed it's maximum range if we went all willy nilly with it
    -- but since we have the maximum range, we can cap it before it goes too far
    vel = assigns.dirs[i] * assigns.speed
    assigns.velocity[i] = vel
    -- so we don't have to figure out where our minimum range is
    assigns.min_points[i] = vector.direction(ZERO, point) * assigns.min_range
    -- finally we initialize our main rays, these will have the velocity added to them
    if assigns.delta > 0 then
      assigns.rays[i] = vector.copy(assigns.min_points[i])
    elseif assigns.delta < 0 then
      assigns.rays[i] = vector.copy(assigns.max_points[i])
    end
    ray = assigns.rays[i]
    assigns.trunc_rays[i] = vector.new(
      number_truncate_by_sign(ray.x, vel.x),
      number_truncate_by_sign(ray.y, vel.y),
      number_truncate_by_sign(ray.z, vel.z)
    )
    assigns.elapsed = 0
  end
end

local function calculate_voxel_manip_bounds_from_targets(targets, assigns)
  local x0
  local y0
  local z0
  local x1
  local y1
  local z1

  for i, tpos1 in pairs(targets) do
    tpos0 = assigns.trunc_rays[i]

    if x0 then
      if x0 > tpos0.x then
        x0 = tpos0.x
      end
    else
      x0 = tpos0.x
    end
    if y0 then
      if y0 > tpos0.y then
        y0 = tpos0.y
      end
    else
      y0 = tpos0.y
    end
    if z0 then
      if z0 > tpos0.z then
        z0 = tpos0.z
      end
    else
      z0 = tpos0.z
    end
    if x1 then
      if x1 < tpos0.x then
        x1 = tpos0.x
      end
    else
      x1 = tpos0.x
    end
    if y1 then
      if y1 < tpos0.y then
        y1 = tpos0.y
      end
    else
      y1 = tpos0.y
    end
    if z1 then
      if z1 < tpos0.z then
        z1 = tpos0.z
      end
    else
      z1 = tpos0.z
    end

    --
    if x0 then
      if x0 > tpos1.x then
        x0 = tpos1.x
      end
    else
      x0 = tpos1.x
    end
    if y0 then
      if y0 > tpos1.y then
        y0 = tpos1.y
      end
    else
      y0 = tpos1.y
    end
    if z0 then
      if z0 > tpos1.z then
        z0 = tpos1.z
      end
    else
      z0 = tpos1.z
    end
    if x1 then
      if x1 < tpos1.x then
        x1 = tpos1.x
      end
    else
      x1 = tpos1.x
    end
    if y1 then
      if y1 < tpos1.y then
        y1 = tpos1.y
      end
    else
      y1 = tpos1.y
    end
    if z1 then
      if z1 < tpos1.z then
        z1 = tpos1.z
      end
    else
      z1 = tpos1.z
    end
  end

  return x0, y0, z0, x1, y1, z1
end

local function calculate_targets(assigns, dtime)
  local ray
  local vel
  local max
  local min
  local x
  local y
  local z
  local tpos0
  local tpos1
  local targets = {}
  -- first, let's determine every ray that has changes
  for i = 1,assigns.points_count do
    ray = assigns.rays[i]
    vel = assigns.velocity[i]
    max = assigns.max_points[i]
    min = assigns.min_points[i]
    x = math.min(math.max(ray.x + vel.x * dtime, min.x), max.x)
    y = math.min(math.max(ray.y + vel.y * dtime, min.y), max.y)
    z = math.min(math.max(ray.z + vel.z * dtime, min.z), max.z)
    assigns.rays[i] = vector.new(x, y, z)
    tpos0 = assigns.trunc_rays[i]
    tpos1 = vector.new(
      number_truncate_by_sign(x, vel.x),
      number_truncate_by_sign(y, vel.y),
      number_truncate_by_sign(z, vel.z)
    )

    if not vector.equals(tpos0, tpos1) then
      -- hey we actually changed positions in the world, time to attempt destruction
      -- first, set the new truncated ray to the new position
      targets[i] = tpos1
    end
  end

  return targets
end

local function update(self, assigns, system, explosion, dtime)
  if dtime > 0 then
    local user = ""
    if assigns.originator_type == "player" then
      user = assigns.originator
    end
    -- we only apply the update on non-zero deltas, you know, if time ACTUALLY changed
    -- just to keep track of how much time has actually elapsed
    assigns.elapsed = assigns.elapsed + dtime
    -- adjust the current range based on the delta
    assigns.range = math.min(
      assigns.max_range,
      math.max(assigns.range + assigns.speed * assigns.delta * dtime, assigns.min_range)
    )
    -- now we calculate ALL of the rays and their new positions
    local targets = calculate_targets(assigns, dtime)

    if next(targets) then
      local seen = {}
      -- first pass to determine the voxel bounds
      local x0, y0, z0, x1, y1, z1 = calculate_voxel_manip_bounds_from_targets(targets, assigns)

      local cpos = explosion.pos
      local cx = cpos.x
      local cy = cpos.y
      local cz = cpos.z

      -- we've been working in local coordinates since the beginning, now, we actually
      -- expand into world coordinates when grabbing the vm
      local vmin = vector.new(x0 + cx, y0 + cy, z0 + cz)
      local vmax = vector.new(x1 + cx, y1 + cy, z1 + cz)
      local vm = core.get_voxel_manip(
        vmin,
        vmax
      )
      local va = VoxelArea(vmin, vmax)
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
      local tpos0
      local tpos1
      local wpos0
      local wpos1
      local ptpos
      -- we have rays that have effectively changed
      for i, tpos1 in pairs(targets) do
        tpos0 = assigns.trunc_rays[i]
        assigns.trunc_rays[i] = tpos1

        -- so yeah, originally I wanted to reimplement the raycast, to kind optimize it for
        -- this very specific usecase, but... my lazy ass is already scared of this whole function
        -- so we'll use core.raycast to find nodes and objects and work from there.

        local wpos0 = vector.add(cpos, tpos0)
        local wpos1 = vector.add(cpos, tpos1)
        -- we only raycast from the previous position to the new position, the cast is rather small
        for pt in raycast(wpos0, wpos1, true, true) do
          if pt.type == "object" then
            --
          elseif pt.type == "node" then
            ptpos = pt.under
            vmi = va:indexp(ptpos)
            if not seen[vmi] then
              seen[vmi] = true

              ci = data[vmi]
              is_protected = false
              if not assigns.ignore_protection then
                is_protected = core.is_protected(ptpos, user)
              end
              if is_protected then
                --
              elseif ci then
                new_ci = ci
                new_param2 = param2[vmi]
                node.name = get_name_from_content_id(ci)
                node.param2 = param2[vmi]
                if node.name then
                  node.param1 = light[vmi]
                  nodedef = core.registered_nodes[node.name]
                  if nodedef then
                    groups = nodedef.groups
                    if not assigns.ignore_on_blast and (nodedef.on_explosion or nodedef.on_blast) then
                      -- on_explosion is our preferred callbacl
                      -- on_blast is compatibility for tnt
                      oeqi = oeqi + 1
                      on_explosion_queue[oeqi] = {
                        vmi = vmi,
                        node = table_copy(node),
                        pos = vector.copy(ptpos),
                        nodedef = nodedef
                      }
                    elseif assigns.can_ignite and (groups["flammable"] or 0) > 0 then
                      -- node is flammable
                      ocqi = ocqi + 1
                      on_construct_queue[ocqi] = {
                        vmi = vmi,
                        org_node = table_copy(node),
                        pos = vector.copy(ptpos),
                        org_nodedef = nodedef
                      }
                    else
                      -- with drop logic
                      pending_drops[hash_node_position(ptpos)] = {
                        pos = vector.copy(pt.under),
                        drops = get_node_drops(
                          node,
                          explosion.kind,
                          nil, -- tool
                          nil, -- digger
                          pt.under
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
                  core.get_meta(pt.under):from_table(nil)
                end
              end
            end
          end
        end
      end

      vm:set_data(data)
      -- vm:set_light_data(light)
      -- vm:set_param2_data(param2)
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
