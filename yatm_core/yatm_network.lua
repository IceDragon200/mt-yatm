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

  device_meta_schema = yatm_core.MetaSchema:new("network_device", "", {
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

local function v3s(vec3)
  return "(" .. vec3.x .. ", " .. vec3.y .. ", " .. vec3.z .. ")"
end

local function debug(scope, ...)
  if scope == "" then
  elseif scope == "network_energy_update" then
    return
  elseif scope == "network_update" then
    return
  elseif scope == "network_device_update" then
    return
  end
  print(Network.counter, scope, ...)
end

function Network.time()
  return minetest.get_us_time()
end

function Network.hash_pos(pos)
  return string.format("%i", minetest.hash_node_position(pos))
end

function Network.generate_network_id(pos)
  local ts = Network.time()
  local network_id = Network.hash_pos(pos)
  return network_id, ts
end

local function is_valid_network_id(network_id)
  if yatm_core.is_blank(network_id) then
    return false
  else
    return network_id
  end
end

local function is_host_network_registered(pos, network_id)
  local network = Network.networks[network_id]
  if network then
    print("is_host_network_registered/2", v3s(pos), "comparing to network pos", v3s(network.pos))
    return network.pos.x == pos.x and
           network.pos.y == pos.y and
           network.pos.z == pos.z
  end
  return false
end

--[[
@type network_id :: String.t
@spec Network.initialize_network(vector3.t, network_id, String.t) :: network_id
]]
function Network.initialize_network(pos, network_id, node_name)
  Network.networks[network_id] = {
    id = network_id,
    -- host node name
    node_name = node_name,
    -- origin position of the controller, can be used to index some features
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

local function create_network(pos, node_name)
  print("create_network/2", v3s(pos), node_name)
  local network_id, ts = Network.generate_network_id(pos)
  return Network.initialize_network(pos, network_id, node_name), ts
end

local function destroy_network(network_id)
  assert(network_id, "expected a network_id")
  local ot = yatm_core.trace.new("Network.destroy_network/1")
  debug("network_registry", "DESTROY NETWORK", network_id)
  local network = Network.networks[network_id]
  if network then
    local lost_nodes = Network.lost_nodes
    local n = #lost_nodes
    for _,node in pairs(network.members) do
      debug("network_registry", "lost child", v3s(node.pos))
      Network.has_lost_nodes = true
      n = n + 1
      lost_nodes[n] = node
    end
    Network.networks[network_id] = nil
  end
  yatm_core.trace.span_end(ot)
  yatm_core.trace.inspect(ot)
end

function Network.leave_network(network_id, pos)
  local ot = yatm_core.trace.new("Network.leave_network/2")
  debug("network_registry", "LEAVE NETWORK", v3s(pos), network_id)
  local network = Network.networks[network_id]
  local left = false
  if network then
    local key = Network.hash_pos(pos)
    local member_group = network.member_groups[key]
    if member_group then
      for _index,group in ipairs(network.member_groups[key]) do
        local member_map = network.group_members[group]
        if member_map then
          -- remove the member
          member_map[key] = nil
          debug("network_registry", "LEAVE GROUP", v3s(pos), group)
        end
      end
    end
    network.member_groups[key] = nil
    network.members[key] = nil
    left = true
  end
  yatm_core.trace.span_end(ot)
  yatm_core.trace.inspect(ot)
  return left
end

function Network.join_network(network_id, pos, nodedef)
  local ot = yatm_core.trace.new("Network.join_network/3")
  local joined = false
  if nodedef then
    local network = Network.networks[network_id]
    if network then
      debug("network_registry", "JOINING NETWORK", v3s(pos), network_id)
      local key = Network.hash_pos(pos)
      if network.members[key] then
        debug("network_registry", "ALREADY MEMBER", v3s(pos), network_id)
      else
        local groups = nodedef.yatm_network.groups or {}
        network.members[key] = { pos = pos, groups = groups }
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
            debug("network_registry", "JOIN GROUP", v3s(pos), group)
          end
          network.member_groups[key] = member_groups
        end
        debug("network_registry", "JOINED NETWORK", v3s(pos), network_id)
      end
      joined = true
    end
  end
  yatm_core.trace.span_end(ot)
  yatm_core.trace.inspect(ot)
  return joined
end

--[[
Merge 2 networks together, given a leader and a list of followers

@spec Network.merge_network(network_id, ...network_id) :: network_id
]]
function Network.merge_network(leader_id, ...)
  local ot = yatm_core.trace.new("Network.merge_network/1+")
  local leader_network = assert(Network.networks[leader_id], "expected leader network to exist")
  for _, follower_id in ipairs({...}) do
    if leader_id ~= follower_id then
      local span = yatm_core.trace.span_start(ot, "Follower:" .. follower_id)
      local follower_network = Network.networks[follower_network]
      if follower_network then
        for _, member in pairs(follower_network.members) do
          Network.leave_network(follower_id, member.pos)
          Network.join_network(leader_network, member.pos, member.groups)
        end
      end
      destroy_network(follower_id)
      yatm_core.trace.span_end(span)
    end
  end
  yatm_core.trace.span_end(ot)
  yatm_core.trace.inspect(ot, "")
  return leader_id
end

function Network.has_network(network_id)
  return Network.networks[network_id] ~= nil
end

function Network.set_meta_network_id(meta, value)
  Network.device_meta_schema:set_field(meta, "yatm", Network.KEY, value)
end

function Network.get_meta_network_id(meta)
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
        local explore_neighbours
        for dir,_ in pairs(yatm_core.DIR6_TO_VEC3) do
          accessible_dirs[dir] = true
        end
        explore_neighbours, acc = func(pos, node, nodedef, accessible_dirs, acc)
        if explore_neighbours then
          for dir,flag in pairs(accessible_dirs) do
            if flag and dir ~= from_dir then
              local vec3 = yatm_core.DIR6_TO_VEC3[dir]
              n = n + 1
              local next_pos = vector.add(pos, vec3)
              --debug("Network.reduce_network/3", v3s(pos), node.name, "exploring neighbour", v3s(next_pos))
              positions[n] = {yatm_core.invert_dir(dir), next_pos}
            end
          end
        else
          --debug("Network.reduce_network/3", v3s(pos), node.name, "not exploring neighbours")
        end
      end
    end
  end
  return acc
end

--[[
@spec Network.find_hosts(vector3.t, non_neg_integer, boolean) :: [{pos :: vector3.t, node :: Node.t, nodedef :: NodeDef.t}]
]]
function Network.find_hosts(origin_pos, ts, ignore_ts)
  local ot = yatm_core.trace.new("Network.find_hosts/3")
  local hosts = Network.reduce_network(origin_pos, {}, function (pos, node, nodedef, accessible_dirs, acc)
    if nodedef then
      local meta = minetest.get_meta(pos)
      local cur_ts = Network.get_network_ts(meta)
      -- if the device's ts is higher or equal to the locator, it should be ignored
      if ignore_ts or cur_ts < ts then
        local host_priority = yatm_core.groups.get_item(nodedef, "yatm_network_host")
        if host_priority then
          debug("network_explorer", "ts", ts, "cur_ts", cur_ts, "pos", v3s(pos), "host.node.name", node.name)
          table.insert(acc, {pos = pos, node = node, nodedef = nodedef})
          return true, acc
        elseif yatm_device_type(nodedef) then
          return true, acc
        end
      else
        debug("network_explorer", "ts", ts, "cur_ts", cur_ts, "find_hosts")
      end
    end
    return false, acc
  end)
  yatm_core.trace.span_end(ot)
  yatm_core.trace.inspect(ot, "")
  return hosts
end

function Network.default_on_network_state_changed(pos, node, state)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.yatm_network.states then
    local new_name = nodedef.yatm_network.states[state]
    if new_name then
      if node.name ~= new_name then
        debug("node", "NETWORK CHANGED", v3s(pos), node.name, "STATE", state)
        node.name = new_name
        minetest.swap_node(pos, node)
      end
    else
      debug("node", "WARN", node.name, "does not have a network state", state)
    end
  end
end

function Network.default_handle_network_changed(pos, node, ts, network_id, state)
  debug("node", "TS", ts, "NOTIFY NETWORK CHANGED", v3s(pos), node.name, "NID", network_id, "STATE", state)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.yatm_network then
      local meta = minetest.get_meta(pos)
      Network.set_network_ts(meta, ts)
      local old_network_id = Network.get_meta_network_id(meta)
      if is_valid_network_id(old_network_id) and old_network_id ~= network_id then
        Network.leave_network(old_network_id, pos)
      end
      if is_valid_network_id(network_id) then
        Network.join_network(network_id, pos, nodedef)
      end
      Network.set_meta_network_id(meta, network_id)
      Network.set_network_state(meta, state)
      if nodedef.yatm_network.refresh_infotext then
        nodedef.yatm_network.refresh_infotext(pos, node, meta, {
          cause = "network_changed",
          network_id = network_id,
          network_ts = ts,
          state = state,
        })
      else
        print("No yatm_network.refresh_infotext/4 defined for", node.name, "falling back to setting infotext manually")
        meta:set_string("infotext", "Network ID <" .. network_id .. "> " .. state)
      end
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
  return Network.reduce_network(origin_pos, 0, function (pos, node, nodedef, accessible_dirs, acc)
    if nodedef then
      local device_type = yatm_device_type(nodedef)
      if device_type then
        local meta = minetest.get_meta(pos)
        local cur_ts = Network.get_network_ts(meta)
        if ignore_ts or cur_ts < ts then
          trigger_network_changed(pos, node, ts, network_id, state)
          -- allow checking other nodes
          return true, acc + 1
        else
          debug("node", "TS", ts, "CUR_TS", cur_ts, "mark_network")
        end
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
  local hosts = Network.find_hosts(origin_pos, ts, ignore_ts)
  local count = #hosts
  debug("refresh_network/3", "found hosts", count)
  if count == 0 then
    return mark_network_offline(ts, ignore_ts, origin_pos)
  elseif count == 1 then
    local host = hosts[1]
    local meta = minetest.get_meta(host.pos)
    local network_id = Network.get_meta_network_id(meta)
    if not is_host_network_registered(host.pos, network_id) then
      debug("refresh_network/3", v3s(origin_pos), "host network is unavailable")
      network_id = create_network(host.pos, host.node.name)
    end
    return mark_network_online(ts, ignore_ts, origin_pos, network_id)
  elseif count > 1 then
    -- Multiple possible hosts have been detected,
    -- the hosts will all become followers of the highest priority host
    -- (aka. whichever node has the lowest yatm_network_host value is the leader)
    -- The process should fail if multiple priority 1 nodes exist, otherwise if the priority is higher, then a random node is selected
    local priority_groups = {}
    local host_network_ids = {}
    for _,host in ipairs(hosts) do
      local key = yatm_core.groups.get_item(host.nodedef, "yatm_network_host")
      priority_groups[key] = priority_groups[key] or {}
      local group = priority_groups[key]
      table.insert(group, host)
      local host_meta = minetest.get_meta(host.pos)
      local host_network_id = Network.get_meta_network_id(host_meta)
      -- Even though we have a host, we need to make sure that it's the actual host of the network
      -- Otherwise it should be considered inaccessible
      if is_host_network_registered(host.pos, host_network_id) then
        host_network_ids[host_network_id] = true
      end
    end

    if priority_groups[1] then
      local group = priority_groups[1]
      if #group == 1 then
        debug("refresh_network/3", v3s(origin_pos), "priority 1 hosts are present")
        local leader_host = group[1]
        local leader_meta = minetest.get_meta(leader_host.pos)
        local leader_network_id = Network.get_meta_network_id(leader_meta)
        if not host_network_ids[leader_network_id] then
          debug("refresh_network/3", "host network", leader_network_id, "is not available")
          leader_network_id = create_network(leader_host.pos, leader_host.node.name)
        end
        for priority, hosts in pairs(priority_groups) do
          for _, follower_host in ipairs(hosts) do
            local follower_meta = minetest.get_meta(follower_host.pos)
            local follower_network_id = Network.get_meta_network_id(follower_meta)
            if follower_network_id then
              Network.merge_network(leader_network_id, follower_network_id)
            end
          end
        end
        return mark_network_online(ts, ignore_ts, origin_pos, leader_network_id)
      else
        debug("refresh_network/3", v3s(origin_pos), "priority 1 hosts conflicts")
        local network_ids = {}
        for priority, hosts in pairs(priority_groups) do
          for _, follower_host in ipairs(hosts) do
            local follower_meta = minetest.get_meta(follower_host.pos)
            local follower_network_id = Network.get_meta_network_id(follower_meta)

            if follower_network_id then
              network_ids[follower_network_id] = true
            end
          end
        end
        return mark_network_conflict(ts, ignore_ts, origin_pos, yatm_core.table_keys(network_ids))
      end
    else
      debug("refresh_network/3", v3s(origin_pos), "no priority 1 hosts exist, electing a leader")
      local leader_priority = 1000
      for priority, _ in pairs(priority_groups) do
        if priority < leader_priority then
          leader_priority = priority
        end
      end
      local group = priority_groups[leader_priority]
      local leader_host = group[1]
      local leader_meta = minetest.get_meta(leader_host.pos)
      local leader_network_id = Network.get_meta_network_id(leader_meta)
      if not host_network_ids[leader_network_id] then
        debug("refresh_network/3", v3s(origin_pos), "host network", leader_network_id, "is not available")
        leader_network_id = create_network(leader_host.pos, leader_host.node.name)
      end
      for priority, hosts in pairs(priority_groups) do
        for _, follower_host in ipairs(hosts) do
          local follower_meta = minetest.get_meta(follower_host.pos)
          local follower_network_id = Network.get_meta_network_id(follower_meta)
          if follower_network_id then
            Network.merge_network(leader_network_id, follower_network_id)
          end
        end
      end
      return mark_network_online(ts, ignore_ts, origin_pos, leader_network_id)
    end
  end
end

local function host_initialize(pos, ts)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.yatm_network then
    if yatm_core.groups.get_item(nodedef, "yatm_network_host") then
      local meta = minetest.get_meta(pos)
      local network_id = Network.get_meta_network_id(meta)
      if is_valid_network_id(network_id) then
        debug("Network.host_initialize/2", v3s(pos), "network id appears to be valid")
      else
        local new_network_id = create_network(pos, node.name)
        Network.set_meta_network_id(meta, new_network_id)
      end
      return refresh_network(pos, ts)
    else
      debug("Network.host_initialize/2", v3s(pos), "not a valid yatm host node")
    end
  else
    debug("Network.host_initialize/2", v3s(pos), "not a valid yatm node")
  end
  return 0
end

function Network.refresh_network_topography(origin_pos, ts, params)
  debug("node", "TS", ts, "Refreshing Network due to", params.kind)
  if params.kind == "refresh" then
    -- just good old refresh
    return refresh_network(origin_pos, ts)
  elseif params.kind == "cable_added" or params.kind == "device_added" then
    print("Handling device_added refresh", v3s(origin_pos))
    -- find all hosts from current position
    return refresh_network(origin_pos, ts)
  elseif params.kind == "cable_removed" or params.kind == "device_removed" then
    print("Handling device_removed refresh", v3s(origin_pos))
    -- have neighbours look for a new host
    local acc = 0
    for _dir,vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
      local pos = vector.add(origin_pos, vec3)
      acc = acc + refresh_network(pos, ts)
    end
    return acc
  elseif params.kind == "host_initialize" then
    -- find any other hosts
    return host_initialize(origin_pos, ts)
  elseif params.kind == "host_load" then
    -- refresh
    return refresh_network(origin_pos, ts, true)
  else
    error("unexpected params.kind " .. params.kind)
  end
  return 0
end

function Network.schedule_refresh_network_topography(pos, params)
  debug("Network.schedule_refresh_network_topography/2", v3s(pos), "kind", params.kind, "caused by", params.cause)
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
    debug("update_lost_nodes/2")
    local ts = Network.time()
    local lost_nodes = Network.lost_nodes
    Network.has_lost_nodes = false
    Network.lost_nodes = {}
    for _,entry in ipairs(lost_nodes) do
      local node = minetest.get_node(entry.pos)
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef then
        if nodedef.on_yatm_network_changed then
          debug("update_lost_nodes/2", "NETWORK LOST", v3s(entry.pos), node.name)
          nodedef.on_yatm_network_changed(entry.pos, node, ts, nil, "off")
        else
          debug("update_lost_nodes/2", "NETWORK LOST but couldn't handle it", v3s(entry.pos), node.name)
        end
      end
    end
  end
end

local function update_network(pot, dtime, counter, network_id, network)
  local trace = yatm_core.trace
  local ot = trace.span_start(pot, network_id)
  debug("network_update", counter, "UPDATING NETWORK", network_id)

  -- Highest priority, produce energy
  -- It's up to the node how it wants to deal with the energy, whether it's buffered, or just burst
  local span = trace.span_start(ot, "energy_producer")
  local energy_produced = reduce_group_members(network, "energy_producer", 0, function (pos, node, acc)
    debug("network_energy_update", "PRODUCE ENERGY", pos.x, pos.y, pos.z, node.name)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if nodedef.yatm_network and nodedef.yatm_network.produce_energy then
        acc = acc + nodedef.yatm_network.produce_energy(pos, node, span)
      else
        debug("network_energy_update", "INVALID ENERGY PRODUCER", pos.x, pos.y, pos.z, node.name)
      end
    end
    return true, acc
  end)
  trace.span_end(span)

  -- Second highest priority, how much energy is stored in the network right now
  -- This is combined with the produced to determine how much is available
  -- The node is allowed to lie about it's contents, to cause energy trickle or gating
  local span = trace.span_start(ot, "energy_storage")
  local energy_stored = reduce_group_members(network, "energy_storage", 0, function (pos, node, acc)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if nodedef.yatm_network and nodedef.yatm_network.get_usable_stored_energy then
        acc = acc + nodedef.yatm_network.get_usable_stored_energy(pos, node)
      else
        debug("network_energy_update", "INVALID ENERGY STORAGE", pos.x, pos.y, pos.z, node.name)
      end
    end
    return true, acc
  end)
  trace.span_end(span)

  local span = trace.span_start(ot, "energy_consumer")
  local total_energy_available = energy_stored + energy_produced
  local energy_available = total_energy_available

  debug("network_energy_update", "ENERGY_AVAILABLE", energy_available, "=", energy_stored, " + ", energy_produced)

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
        debug("network_energy_update", "INVALID ENERGY CONSUMER", pos.x, pos.y, pos.z, node.name)
      end
    end
    -- can't continue if we have no energy available
    return energy_available > 0, acc
  end)
  trace.span_end(span)

  debug("network_energy_update", "ENERGY_CONSUMED", energy_consumed)

  local span = trace.span_start(ot, "energy_storage")
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
          debug("network_energy_update", "INVALID ENERGY STORAGE", pos.x, pos.y, pos.z, node.name)
        end
      end
      -- only continue if the energy_storage_consumed is still greater than 0
      return energy_storage_consumed > 0, acc + 1
    end)
  end
  trace.span_end(span)

  -- how much extra energy is left, note the stored is subtracted from the available
  -- if it falls below 0 then there is no extra energy.
  local span = trace.span_start(ot, "energy_receiver")
  if energy_available > energy_stored then
    local energy_left = energy_available - energy_stored

    debug("network_energy_update", "ENERGY_LEFT", energy_left)
    -- Receivers are the lowest priority, they accept any left over energy from the production
    -- Incidentally, storage nodes tend to be also receivers
    reduce_group_members(network, "energy_receiver", 0, function (pos, node, acc)
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef then
        if nodedef.yatm_network and nodedef.yatm_network.receive_energy then
          local energy_received = nodedef.yatm_network.receive_energy(pos, node, energy_left)
          energy_left = energy_left - energy_received
        else
          debug("network_energy_update", "INVALID ENERGY RECEIVER", pos.x, pos.y, pos.z, node.name)
        end
      end
      return energy_left > 0, acc + 1
    end)
  end
  trace.span_end(span)

  local span = trace.span_start(ot, "has_update")
  reduce_group_members(network, "has_update", 0, function (pos, node, acc)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if nodedef.yatm_network and nodedef.yatm_network.update then
        local s = trace.span_start(span, node.name)
        nodedef.yatm_network.update(pos, node, s)
        trace.span_end(s)
      else
        debug("network_device_update", "INVALID UPDATABLE DEVICE", pos.x, pos.y, pos.z, node.name)
      end
    end
    return true, acc + 1
  end)
  trace.span_end(span)

  trace.span_end(ot)
end

function Network.update(dtime)
  local counter = Network.counter

  -- high priority
  update_network_refresh(dtime, counter)
  update_lost_nodes(dtime, counter)

  -- normal priority
  --[[Network.timer = Network.timer - 1
  if Network.timer > 0 then
    return
  else
    -- force the network to act only ever 4 frames, yielding a 20 FPS
    Network.timer = 1 -- 4
  end]]

  local ot = yatm_core.trace.new("Network.update/1")

  for network_id,network in pairs(Network.networks) do
    update_network(ot, dtime, counter, network_id, network)
  end

  yatm_core.trace.span_end(ot)
  --yatm_core.trace.inspect(ot, "")

  Network.counter = counter + 1
end

function Network.on_shutdown()
  debug("yatm_core.Network.on_shutdown/0", "Shutting down")
end

function Network.on_host_destruct(pos, node)
  -- the controller is about to be lost, destroy it's existing network
  local meta = minetest.get_meta(pos)
  local network_id = Network.get_meta_network_id(meta)
  if network_id then
    destroy_network(network_id)
  end
  Network.schedule_refresh_network_topography(pos, { kind = "device_removed", node = node, cause = "host_destruct" })
end

function Network.default_yatm_notify_neighbours_changed(origin, node)
  assert(origin, "expected an origin position")
  assert(node, "expected a node")
  debug("Network.default_yatm_notify_neighbours_changed/2", v3s(origin), node.name)
  local origin_node = minetest.get_node(origin)
  for dir_code, vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
    local pos = vector.add(origin, vec3)
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    -- check if the node works with the yatm network
    if nodedef and nodedef.on_yatm_device_changed then
      nodedef.on_yatm_device_changed(pos, node, origin, origin_node)
    end
  end
end

function Network.device_after_place_node(pos)
  print("Network.device_after_place_node/2", v3s(pos))
  Network.schedule_refresh_network_topography(pos, { kind = "device_added", cause = "place_node" })
end

function Network.device_on_destruct(pos)
  assert(pos, "expected a pos")
  print("Network.device_on_destruct/2", v3s(pos))
  local meta = minetest.get_meta(pos)
  local network_id = Network.get_meta_network_id(meta)
  if network_id then
    Network.leave_network(network_id, pos)
  end
end

function Network.device_after_destruct(pos, node)
  assert(pos, "expected a pos")
  assert(node, "expected a node")
  print("Network.device_after_destruct/2", v3s(pos), node.name)
  Network.schedule_refresh_network_topography(pos, { kind = "device_removed", node = node, cause = "destruct" })
end

minetest.register_on_shutdown(Network.on_shutdown)
minetest.register_globalstep(Network.update)
yatm_core.Network = Network

--[[
Register the Network Host ABM and LBMs
]]
minetest.register_abm({
  label = "yatm_core:network_host_abm",
  nodenames = {
    "group:yatm_network_host",
  },
  interval = 1,
  chance = 1,
  action = function (pos, node)
    -- for now, we'll just activate any existing hosts
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef and nodedef.yatm_network then
      local meta = minetest.get_meta(pos)
      local network_id = Network.get_meta_network_id(meta)
      if is_valid_network_id(network_id) then
        -- it has a valid network registered already
      else
        print("Initializing network host " .. node.name)
        Network.schedule_refresh_network_topography(pos, { kind = "host_initialize", node = node, cause = "abm" })
      end
    end
  end
})

minetest.register_lbm({
  name = "yatm_core:network_host_lbm",
  nodenames = {
    "group:yatm_network_host",
  },
  run_at_every_load = true,
  action = function (pos, node)
    print("SCHEDULE NETWORK REFRESH", v3s(pos))
    local meta = minetest.get_meta(pos)
    local network_id = Network.get_meta_network_id(meta)
    if network_id then
      yatm_core.Network.initialize_network(pos, network_id, node.name)
    else
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef and nodedef.yatm_network then
        node.name = nodedef.yatm_network.states.off
        minetest.swap_node(pos, node)
      end
    end
    Network.schedule_refresh_network_topography(pos, {kind = "host_load"})
  end
})
