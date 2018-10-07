local Network = {
  dirty = true,
  networks = {},
  has_lost_nodes = false,
  lost_nodes = {},
  need_refresh = false,
  refresh_queue = {},
  counter = 0,
  timer = 0,

  STATE = "network_state",
  KEY = "network_id",
  TS = "network_updated_at",

  device_meta_schema = yatm_core.MetaSchema.new("network_device", "", {
    network_id = {
      type = "string",
    },
    network_state = {
      type = "string",
    },
    network_updated_at = {
      type = "integer",
    },
  }),
}

local function debug(scope, ...)
  if scope == "" then
  --elseif scope == "network_energy_update" then
  --  return
  elseif scope == "network_update" then
    return
  elseif scope == "network_device_update" then
    return
  end
  print(scope, ...)
end

function Network.time()
  return minetest.get_us_time()
end

function Network.encode_vec3(pos)
  return pos.x .. "." .. pos.y .. "." .. pos.z
end

function Network.generate_network_id(pos)
  local ts = Network.time()
  local network_id = Network.encode_vec3(pos) .. "." .. ts
  return network_id, ts
end

function Network.is_valid_network_id(network_id)
  if network_id then
    return network_id ~= ""
  else
    return false
  end
end

function Network.initialize_network(pos, network_id)
  Network.networks[network_id] = {
    id = network_id,
    -- origin position of the controller, can be used tp index some features
    pos = pos,
    -- {member_id = member_entry}
    members = {},
    -- {member_id = {group_id...}}
    member_groups = {},
    -- {group_id = {(member_id = true)...}}
    group_members = {},
  }
  return network_id
end

function Network.create_network(pos)
  local network_id, ts = Network.generate_network_id(pos)
  return Network.initialize_network(pos, network_id), ts
end

function Network.destroy_network(network_id)
  debug("network_registry", "DESTROY NETWORK", network_id)
  local network = Network.networks[network_id]
  if network then
    local lost_nodes = Network.lost_nodes
    local n = #lost_nodes
    for _,node in pairs(network.members) do
      debug("network", "lost child", node.pos.x, node.pos.y, node.pos.z)
      Network.has_lost_nodes = true
      n = n + 1
      lost_nodes[n] = node
    end
    Network.networks[network_id] = nil
  end
end

function Network.leave_network(network_id, pos)
  debug("network_registry", "LEAVE NETWORK", pos.x, pos.y, pos.z, network_id)
  local network = Network.networks[network_id]
  if network then
    local key = Network.encode_vec3(pos)
    local member_group = network.member_groups[key]
    if member_group then
      for _index,group in ipairs(network.member_groups[key]) do
        local member_map = network.group_members[group]
        if member_map then
          -- remove the member
          member_map[key] = nil
          debug("network_registry", "LEAVE GROUP", pos.x, pos.y, pos.z, group)
        end
      end
    end
    network.member_groups[key] = nil
    network.members[key] = nil
    return true
  end
  return false
end

function Network.join_network(network_id, pos, groups)
  debug("network_registry", "JOIN NETWORK", pos.x, pos.y, pos.z, network_id)
  local network = Network.networks[network_id]
  if network then
    local key = Network.encode_vec3(pos)
    if not network.members[key] then
      network.members[key] = {pos = pos}
      -- Indexing stuff, to use for faster lookups
      if groups then
        local member_groups = {}
        local n = 0
        for group,_rating in pairs(groups) do
          n = n + 1
          member_groups[n] = group
          local member_map = network.group_members[group] or {}
          member_map[key] = true
          network.group_members[group] = member_map
          debug("network_registry", "JOIN GROUP", pos.x, pos.y, pos.z, group)
        end
        network.member_groups[key] = member_groups
      end
    end
    return true
  end
  return false
end

function Network.has_network(network_id)
  return Network.networks[network_id] ~= nil
end

function Network.set_network_id(meta, value)
  Network.device_meta_schema:set_field(meta, "yatm", Network.KEY, value)
end

function Network.get_network_id(meta)
  return Network.device_meta_schema:get_field(meta, "yatm", Network.KEY)
end

function Network.set_network_ts(meta, value)
  assert(meta, "requires a NodeMetaRef")
  assert(value, "need a timestamp")
  Network.device_meta_schema:set_field(meta, "yatm", Network.TS, value)
end

function Network.get_network_ts(meta)
  return Network.device_meta_schema:get_field(meta, "yatm", Network.TS)
end

function Network.set_network_state(meta, value)
  Network.device_meta_schema:set_field(meta, "yatm", Network.STATE, value)
end

function Network.get_network_state(meta)
  return Network.device_meta_schema:get_field(meta, "yatm", Network.STATE)
end

local function yatm_device_type(nodedef)
  if nodedef and nodedef.yatm_network then
    return nodedef.yatm_network.kind
  end
  return nil
end

function Network.reduce_network(origin_pos, acc, func)
  local positions = {{0, origin_pos}}
  local controllers = {}
  local visited = {}
  local accessible_dirs = yatm_core.new_accessible_dirs()
  while #positions > 0 do
    local current_positions = positions
    positions = {}
    local n = 0
    for _,pair in ipairs(current_positions) do
      local from_dir = pair[1]
      local pos = pair[2]
      if not visited[pos.y] then
        visited[pos.y] = {}
      end
      if not visited[pos.y][pos.z] then
        visited[pos.y][pos.z] = {}
      end
      if not visited[pos.y][pos.z][pos.x] then
        visited[pos.y][pos.z][pos.x] = true
        local node = minetest.get_node(pos)
        local nodedef = minetest.registered_nodes[node.name]
        local device_type = yatm_device_type(nodedef)
        local explore_neighbours
        for dir,_ in pairs(yatm_core.DIR6_TO_VEC3) do
          accessible_dirs[dir] = true
        end
        explore_neighbours, acc = func(pos, node, device_type, accessible_dirs, acc)
        if explore_neighbours then
          for dir,flag in pairs(accessible_dirs) do
            if flag and dir ~= from_dir then
              local vec3 = yatm_core.DIR6_TO_VEC3[dir]
              n = n + 1
              positions[n] = {yatm_core.invert_dir(dir), vector.add(pos, vec3)}
            end
          end
        end
      end
    end
  end
  return acc
end

function Network.find_controllers(origin_pos, ts, ignore_ts)
  return Network.reduce_network(origin_pos, {}, function (pos, node, device_type, accessible_dirs, acc)
    if device_type then
      local meta = minetest.get_meta(pos)
      local cur_ts = Network.get_network_ts(meta)
      -- if the device's ts is higher or equal to the locator, it should be ignored
      if ignore_ts or cur_ts < ts then
        if device_type == "controller" then
          table.insert(acc, pos)
          return true, acc
        elseif device_type == "cable" then
          return true, acc
        else
          return true, acc
        end
      else
        debug("network_explorer", "TS", ts, "CUR_TS", cur_ts, "find_controllers")
      end
    end
    acc.first = false
    return false, acc
  end)
end

function Network.default_on_network_state_changed(pos, node, state)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.yatm_network.states then
    local new_name = nodedef.yatm_network.states[state]
    if new_name then
      if node.name ~= new_name then
        debug("node", "NETWORK CHANGED ", pos.x, pos.y, pos.z, node.name, "STATE", state)
        node.name = new_name
        minetest.swap_node(pos, node)
      end
    else
      debug("node", "WARN", node.name, "does not have a network state", state)
    end
  end
end

function Network.default_handle_network_changed(pos, node, ts, network_id, state)
  debug("node", "TS", ts, "NOTIFY NETWORK CHANGED", pos.x, pos.y, pos.z, node.name, "NID", network_id, "STATE", state)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.yatm_network then
      local meta = minetest.get_meta(pos)
      Network.set_network_ts(meta, ts)
      local old_network_id = Network.get_network_id(meta)
      if Network.is_valid_network_id(old_network_id) and old_network_id ~= network_id then
        Network.leave_network(old_network_id, pos)
      end
      if Network.is_valid_network_id(network_id) then
        Network.join_network(network_id, pos, nodedef.yatm_network.groups)
      end
      Network.set_network_id(meta, network_id)
      Network.set_network_state(meta, state)
      meta:set_string("infotext", "Network ID " .. dump(network_id) .. " " .. state)
      if nodedef.yatm_network.on_network_state_changed then
        nodedef.yatm_network.on_network_state_changed(pos, node, state)
      end
    end
  end
end

local function trigger_network_changed(pos, node, ts, network_id, state)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.on_yatm_network_changed then
      local meta = minetest.get_meta(pos)
      nodedef.on_yatm_network_changed(pos, node, ts, network_id, state)
    end
  end
end

local function mark_network(ts, ignore_ts, origin_pos, network_id, state)
  return Network.reduce_network(origin_pos, 0, function (pos, node, device_type, accessible_dirs, acc)
    if device_type then
      local meta = minetest.get_meta(pos)
      local cur_ts = Network.get_network_ts(meta)
      if ignore_ts or cur_ts < ts then
        if device_type == "controller" then
          trigger_network_changed(pos, node, ts, network_id, state)
          return true, acc + 1
        elseif device_type == "cable" then
          trigger_network_changed(pos, node, ts, network_id, state)
          return true, acc + 1
        else
          trigger_network_changed(pos, node, ts, network_id, state)
          -- allow checking other nodes
          return true, acc + 1
        end
      else
        debug("node", "TS", ts, "CUR_TS", cur_ts, "mark_network")
      end
    end
    return false, acc
  end)
end

local function mark_network_offline(ts, ignore_ts, origin_pos)
  return mark_network(ts, ignore_ts, origin_pos, nil, "off")
end

local function mark_network_online(ts, ignore_ts, origin_pos, network_id)
  return mark_network(ts, ignore_ts, origin_pos, network_id, "on")
end

local function mark_network_conflict(ts, ignore_ts, origin_pos, network_ids)
  return mark_network(ts, ignore_ts, origin_pos, nil, "conflict")
end

local function refresh_network(origin_pos, ts, ignore_ts)
  local controllers = Network.find_controllers(origin_pos, ts, ignore_ts)
  local count = #controllers
  if count == 0 then
    return mark_network_offline(ts, ignore_ts, origin_pos)
  elseif count == 1 then
    local pos = controllers[1]
    local meta = minetest.get_meta(pos)
    local network_id = Network.get_network_id(meta)
    return mark_network_online(ts, ignore_ts, origin_pos, network_id)
  elseif count > 1 then
    local network_ids = {}
    for _,pos in ipairs(controllers) do
      local meta = minetest.get_meta(pos)
      local network_id = Network.get_network_id(meta)
      if network_id then
        debug("node", "TS", ts, "CONFLICTING NID", network_id)
        table.insert(network_ids, network_id)
      end
    end
    return mark_network_conflict(ts, ignore_ts, origin_pos, network_ids)
  end
end

function Network.refresh_network_topography(origin_pos, ts, params)
  debug("node", "TS", ts, "Refreshing Network due to", params.kind)
  if params.kind == "refresh" then
    -- just good old refresh
    return refresh_network(origin_pos, ts)
  elseif params.kind == "cable_added" or params.kind == "device_added" then
    -- find all controllers from current position
    return refresh_network(origin_pos, ts)
  elseif params.kind == "cable_removed" or params.kind == "controller_removed" then
    -- have neighbours look for a new controller
    local acc = 0
    for _dir,vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
      local pos = vector.add(origin_pos, vec3)
      acc = acc + refresh_network(pos, ts)
    end
    return acc
  elseif params.kind == "controller_initialized" then
    -- find any other controllers
    return refresh_network(origin_pos, ts)
  elseif params.kind == "controller_load" then
    -- refresh
    return refresh_network(origin_pos, ts, true)
  else
    error("unexpected params")
  end
  return 0
end

function Network.schedule_refresh_network_topography(pos, params)
  Network.need_refresh = true
  table.insert(Network.refresh_queue, {pos, params})
end

local function reduce_group_members(network, name, acc, fun)
  local group = network.group_members[name]
  if group then
    local cont = true
    for member_id,_ in pairs(group) do
      local member = network.members[member_id]
      local pos = member.pos
      local node = minetest.get_node(pos)
      cont, acc = fun(pos, node, acc)
      if not cont then
        break
      end
    end
  end
  return acc
end

local function update_network_refresh(dtime, counter)
  if Network.need_refresh then
    local ts = Network.time()
    debug("network_update", counter, "REFRESHING NETWORKS")
    local refresh_queue = Network.refresh_queue
    Network.need_refresh = false
    Network.refresh_queue = {}
    for _,pair in ipairs(refresh_queue) do
      local pos = pair[1]
      local params = pair[2]
      local affected_count = Network.refresh_network_topography(pos, ts, params)
      debug("network_update", counter, "Refreshed ", affected_count, " devices")
    end
  end
end

local function update_lost_nodes(dtime, counter)
  if Network.has_lost_nodes then
    debug(counter, "RESOLVING LOST NODES")
    local ts = Network.time()
    local lost_nodes = Network.lost_nodes
    Network.has_lost_nodes = false
    Network.lost_nodes = {}
    for _,entry in ipairs(lost_nodes) do
      local node = minetest.get_node(entry.pos)
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef then
        if nodedef.on_yatm_network_changed then
          debug("network_update", counter, "NETWORK LOST", entry.pos.x, entry.pos.y, entry.pos.z, node.name)
          nodedef.on_yatm_network_changed(entry.pos, node, ts, nil, "off")
        else
          debug("network_update", counter, "NETWORK LOST but couldn't handle it", entry.pos.x, entry.pos.y, entry.pos.z, node.name)
        end
      end
    end
  end
end

local function update_network(dtime, counter, network_id, network)
  debug("network_update", counter, "UPDATING NETWORK", network_id)

  -- Highest priority, produce energy
  -- It's up to the node how it wants to deal with the energy, whether it's buffered, or just burst
  local energy_produced = reduce_group_members(network, "energy_producer", 0, function (pos, node, acc)
    debug("network_energy_update", counter, "PRODUCE ENERGY", pos.x, pos.y, pos.z, node.name)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if nodedef.yatm_network and nodedef.yatm_network.produce_energy then
        acc = acc + nodedef.yatm_network.produce_energy(pos, node)
      else
        debug("network_energy_update", counter, "INVALID ENERGY PRODUCER", pos.x, pos.y, pos.z, node.name)
      end
    end
    return true, acc
  end)

  -- Second highest priority, how much energy is stored in the network right now
  -- This is combined with the produced to determine how much is available
  -- The node is allowed to lie about it's contents, to cause energy trickle or gating
  local energy_stored = reduce_group_members(network, "energy_storage", 0, function (pos, node, acc)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if nodedef.yatm_network and nodedef.yatm_network.get_usable_stored_energy then
        acc = acc + nodedef.yatm_network.get_usable_stored_energy(pos, node)
      else
        debug("network_energy_update", counter, "INVALID ENERGY STORAGE", pos.x, pos.y, pos.z, node.name)
      end
    end
    return true, acc
  end)

  local total_energy_available = energy_stored + energy_produced
  local energy_available = total_energy_available

  debug("network_energy_update", counter, "ENERGY_AVAILABLE", energy_available, "=", energy_stored, " + ", energy_produced)

  local energy_consumed = reduce_group_members(network, "energy_consumer", 0, function (pos, node, acc)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if nodedef.yatm_network and nodedef.yatm_network.consume_energy then
        local consumed = nodedef.yatm_network.consume_energy(pos, node, energy_available)
        if consumed then
          energy_available = energy_available - consumed
        end
        acc = acc + consumed
      else
        debug("network_energy_update", counter, "INVALID ENERGY CONSUMER", pos.x, pos.y, pos.z, node.name)
      end
    end
    -- can't continue if we have no energy available
    return energy_available > 0, acc
  end)

  debug("network_energy_update", counter, "ENERGY_CONSUMED", energy_consumed)

  local energy_storage_consumed = energy_consumed - energy_produced
  -- if we went over the produced, then the rest must be taken from the storage
  if energy_storage_consumed > 0 then
    reduce_group_members(network, "energy_storage", 0, function (pos, node, acc)
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef then
        if nodedef.yatm_network and nodedef.yatm_network.use_stored_energy then
          local used = nodedef.yatm_network.use_stored_energy(pos, node, energy_storage_consumed)
          energy_storage_consumed = energy_storage_consumed - used
        else
          debug("network_energy_update", counter, "INVALID ENERGY STORAGE", pos.x, pos.y, pos.z, node.name)
        end
      end
      -- only continue if the energy_storage_consumed is still greater than 0
      return energy_storage_consumed > 0, acc + 1
    end)
  end

  -- how much extra energy is left, note the stored is subtracted from the available
  -- if it falls below 0 then there is no extra energy.
  if energy_available > energy_stored then
    local energy_left = energy_available - energy_stored

    debug("network_energy_update", counter, "ENERGY_LEFT", energy_left)
    -- Receivers are the lowest priority, they accept any left over energy from the production
    -- Incidentally, storage nodes tend to be also receivers
    reduce_group_members(network, "energy_receiver", 0, function (pos, node, acc)
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef then
        if nodedef.yatm_network and nodedef.yatm_network.receive_energy then
          local energy_received = nodedef.yatm_network.receive_energy(pos, node, energy_left)
          energy_left = energy_left - energy_received
        else
          debug("network_energy_update", counter, "INVALID ENERGY RECEIVER", pos.x, pos.y, pos.z, node.name)
        end
      end
      return energy_left > 0, acc + 1
    end)
  end

  reduce_group_members(network, "has_update", 0, function (pos, node, acc)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if nodedef.yatm_network and nodedef.yatm_network.update then
        nodedef.yatm_network.update(pos, node)
      else
        debug("network_device_update", counter, "INVALID UPDATABLE DEVICE", pos.x, pos.y, pos.z, node.name)
      end
    end
    return true, acc + 1
  end)
end

function Network.update(dtime)
  local counter = Network.counter

  -- high priority
  update_network_refresh(dtime, counter)
  update_lost_nodes(dtime, counter)

  -- normal priority
  Network.timer = Network.timer - 1
  if Network.timer > 0 then
    return
  else
    -- force the network to act only ever 4 frames, yielding a 20 FPS
    Network.timer = 4
  end

  for network_id,network in pairs(Network.networks) do
    update_network(dtime, counter, network_id, network)
  end

  Network.counter = counter + 1
end

function Network.on_shutdown()
  print("Shutting down")
end

minetest.register_on_shutdown(Network.on_shutdown)
minetest.register_globalstep(Network.update)
yatm_core.Network = Network
