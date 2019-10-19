local EnergyDevices = assert(yatm_core.EnergyDevices)

local Network = {
  stage = 0,
  dirty = true,
  networks = {},
  has_lost_nodes = false,
  lost_nodes = {},
  need_refresh = false,
  refresh_queue = {},
  counter = 0,
  timer = 0,

  systems = {},

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

  pending_actions = {},
}

local function v3s(vec3)
  return "(" .. vec3.x .. ", " .. vec3.y .. ", " .. vec3.z .. ")"
end

local function debug(scope, ...)
  if scope == "" then
  elseif scope == "network_energy_update_error" then
    --
  elseif scope == "network_energy_update" then
    return
  elseif scope == "network_update" then
    return
  elseif scope == "network_device_update" then
    return
  end
  print(Network.counter, scope, ...)
end

--
-- NetworkCluster
--
local NetworkCluster = yatm_core.Class:extends("NetworkCluster")
local ic = NetworkCluster.instance_class

function ic:initialize(pos, network_id, node_name)
  self.idle_time = 0

  self.id = network_id
  -- host node name
  self.node_name = node_name
  -- origin position of the controller, can be used to index some features
  self.pos = pos
  -- {member_id = member_entry}
  self.members = {}
  -- {group_id = {(member_id = true)...}}
  self.group_members = {}
  -- {block_id = {member_id = true}}
  self.member_blocks = {}
end

function ic:reduce_group_members(name, acc, reducer)
  local group = self.group_members[name]
  if group then
    local cont = true
    for member_id,_ in pairs(group) do
      local member = self.members[member_id]
      local pos = member.pos
      local node = minetest.get_node(pos)
      if node.name == "ignore" then
        --print("YATM Network; WARN: ignoring node", minetest.pos_to_string(pos), "of group", name)
      else
        cont, acc = reducer(pos, node, acc)
        if not cont then
          break
        end
      end
    end
  end
  return acc
end

function ic:add_member(pos, nodedef, ot)
  debug("network_registry", "ADD MEMBER", v3s(pos), self.id)
  local member_id = Network.hash_pos(pos)
  if self.members[member_id] then
    debug("network_registry", "ALREADY MEMBER", v3s(pos), self.id)
    return false
  else
    local groups = nodedef.yatm_network.groups or {}
    local block_id = yatm.clusters:mark_node_block(pos)

    self.members[member_id] = {
      block_id = block_id,
      pos = pos,
      groups = groups
    }

    if not self.member_blocks[block_id] then
      self.member_blocks[block_id] = {}
    end
    self.member_blocks[block_id][member_id] = true

    -- Indexing stuff, to use for faster lookups
    if groups then
      for group,rating in pairs(groups) do
        if not self.group_members[group] then
          self.group_members[group] = {}
        end
        self.group_members[group][member_id] = rating
        debug("network_registry", "JOINED GROUP", v3s(pos), group)
      end
    end
    debug("network_registry", "ADDED MEMBER", v3s(pos), self.id)
  end
  return true
end

function ic:remove_member(pos)
  debug("network_registry", "REMOVE MEMBER", v3s(pos), self.id)
  local member_id = Network.hash_pos(pos)
  local member = self.members[member_id]
  if member then
    if member.groups then
      for group_id,_ in pairs(member.groups) do
        local group_members = self.group_members[group_id]
        if group_members then
          group_members[member_id] = nil
          debug("network_registry", "LEFT GROUP", v3s(pos), group_id)
        end
      end
    end
    self.members[member_id] = nil
    local block_members = self.member_blocks[member.block_id]
    if block_members then
      block_members[member_id] = nil
    end
    return true
  end
  return false
end

function ic:unload_block(block_id)
  debug("network_registry", "UNLOAD BLOCK", block_id, self.id)
  local block_members = self.member_blocks[block_id]
  self.member_blocks[block_id] = nil
  if block_members then
    for member_id,_ in pairs(block_members) do
      local member = self.members[member_id]
      if member then
        self:remove_member(member.pos)
      end
    end
  end
  debug("network_registry", "UNLOADED BLOCK", block_id, self.id)
end

--
-- Network Defintiion
--
function Network.to_infotext(meta)
  local network_id = Network.get_meta_network_id(meta)
  local state = Network.get_network_state(meta)
  local result = "NIL"
  if network_id then
    result = "<" .. network_id .. ">"
  else
    result = "NIL"
  end

  return result .. " (" .. state .. ")"
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

function Network.format_id(network_id)
  if network_id then
    return network_id
  else
    return "NULL"
  end
end

--[[
@type network_id :: String.t
@spec Network.initialize_network(vector3.t, network_id, String.t) :: network_id
]]
function Network.initialize_network(pos, network_id, node_name)
  Network.networks[network_id] = NetworkCluster:new(pos, network_id, node_name)
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
    left = network:remove_member(pos)
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
      joined = network:add_member(pos, nodedef, ot)
    end
  end
  yatm_core.trace.span_end(ot)
  yatm_core.trace.inspect(ot)
  return joined
end

--[[
Merge 2 networks together, given a leader and a list of followers

@spec merge_network(network_id, ...network_id) :: network_id
]]
function Network:merge_network(leader_id, ...)
  local ot = yatm_core.trace.new("Network.merge_network/1+")
  local leader_network = assert(self.networks[leader_id], "expected leader network to exist")
  for _, follower_id in ipairs({...}) do
    if leader_id ~= follower_id then
      local span = yatm_core.trace.span_start(ot, "Follower:" .. follower_id)
      local follower_network = self.networks[follower_network]
      if follower_network then
        for _, member in pairs(follower_network.members) do
          self.leave_network(follower_id, member.pos)
          self.join_network(leader_network, member.pos, member.groups)
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

function Network:unload_block(block_id)
  for network_id,network in pairs(self.networks) do
    network:unload_block(block_id)
  end
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
      local visited_hash = minetest.hash_node_position(pos)

      if not visited[visited_hash] then
        visited[visited_hash] = true

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
        local host_priority = yatm_core.groups.get_item(nodedef, "device_cluster_controller")
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
      if nodedef.yatm_network.on_network_state_changed then
        nodedef.yatm_network.on_network_state_changed(pos, node, state)
      end
      Network:queue_refresh_infotext(pos)
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
    -- (aka. whichever node has the lowest device_cluster_controller value is the leader)
    -- The process should fail if multiple priority 1 nodes exist, otherwise if the priority is higher, then a random node is selected
    local priority_groups = {}
    local host_network_ids = {}
    for _,host in ipairs(hosts) do
      local key = yatm_core.groups.get_item(host.nodedef, "device_cluster_controller")
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
              Network:merge_network(leader_network_id, follower_network_id)
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
            Network:merge_network(leader_network_id, follower_network_id)
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
    if yatm_core.groups.get_item(nodedef, "device_cluster_controller") then
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

local function update_network(network, dtime, counter, pot)
  local trace = yatm_core.trace
  local ot = trace.span_start(pot, network.id)
  debug("network_update", counter, "UPDATING NETWORK", network.id)

  -- Highest priority, produce energy
  -- It's up to the node how it wants to deal with the energy, whether it's buffered, or just burst
  local span = trace.span_start(ot, "energy_producer")
  local energy_produced = network:reduce_group_members("energy_producer", 0, function (pos, node, acc)
    debug("network_energy_update", "PRODUCE ENERGY", pos.x, pos.y, pos.z, node.name)
    acc = acc + EnergyDevices.produce_energy(pos, node, dtime, span)
    return true, acc
  end)
  trace.span_end(span)

  -- Second highest priority, how much energy is stored in the network right now
  -- This is combined with the produced to determine how much is available
  -- The node is allowed to lie about it's contents, to cause energy trickle or gating
  local span = trace.span_start(ot, "energy_storage")
  local energy_stored = network:reduce_group_members("energy_storage", 0, function (pos, node, acc)
    local nodedef = minetest.registered_nodes[node.name]
    acc = acc + EnergyDevices.get_usable_stored_energy(pos, node, dtime, span)
    return true, acc
  end)
  trace.span_end(span)

  local span = trace.span_start(ot, "energy_consumer")
  local total_energy_available = energy_stored + energy_produced
  local energy_available = total_energy_available

  debug("network_energy_update", "ENERGY_AVAILABLE", energy_available, "=", energy_stored, " + ", energy_produced)

  -- Consumers are different from receivers, they use energy without any intention of storing it
  local energy_consumed = network:reduce_group_members("energy_consumer", 0, function (pos, node, acc)
    local consumed = EnergyDevices.consume_energy(pos, node, energy_available, dtime, span)
    if consumed then
      energy_available = energy_available - consumed
      acc = acc + consumed
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
    network:reduce_group_members("energy_storage", 0, function (pos, node, acc)
      local used = EnergyDevices.use_stored_energy(pos, node, energy_storage_consumed, dtime, span)
      if used then
        energy_storage_consumed = energy_storage_consumed + used
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
    network:reduce_group_members("energy_receiver", 0, function (pos, node, acc)
      local energy_received = EnergyDevices.receive_energy(pos, node, energy_left, dtime, span)
      if energy_received then
        energy_left = energy_left -  energy_received
      end
      return energy_left > 0, acc + 1
    end)
  end
  trace.span_end(span)

  local span = trace.span_start(ot, "has_update")
  network:reduce_group_members("has_update", 0, function (pos, node, acc)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if nodedef.yatm_network and nodedef.yatm_network.update then
        local s = trace.span_start(span, node.name)
        nodedef.yatm_network.update(pos, node, dtime, s)
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

function Network:update(dtime)
  local counter = self.counter

  -- high priority
  update_network_refresh(dtime, counter)
  update_lost_nodes(dtime, counter)

  -- normal priority
  --[[self.timer = self.timer - 1
  if self.timer > 0 then
    return
  else
    -- force the network to act only ever 4 frames, yielding a 20 FPS
    self.timer = 1 -- 4
  end]]

  local ot = yatm_core.trace.new("self.update_networks")

  for network_id,network in pairs(self.networks) do
    network.idle_time = network.idle_time - dtime
    while network.idle_time <= 0 do
      network.idle_time = network.idle_time + 0.25
      update_network(network, 0.25, counter, ot)

      for _,system in pairs(self.systems) do
        system:update_network(network, 0.25, counter, ot)
      end
    end
  end

  yatm_core.trace.span_end(ot)

  local ot = yatm_core.trace.new("self.handle_pending_actions")
  if not yatm_core.is_table_empty(self.pending_actions) then
    local pending_actions = self.pending_actions
    self.pending_actions = {}

    for hash,action in pairs(pending_actions) do
      local node = minetest.get_node(action.pos)
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef then
        if action.refresh_infotext then
          if nodedef.refresh_infotext then
            local ot2 = yatm_core.trace.span_start(ot, node.name .. " refresh_infotext/2")
            nodedef.refresh_infotext(action.pos, node)
            yatm_core.trace.span_end(ot2)
          end
        end
      end
    end
  end

  yatm_core.trace.span_end(ot)

  self.counter = counter + 1
end

function Network:start()
  print("yatm_network", "registering on_block_expired observe in clusters")
  yatm.clusters:observe('on_block_expired', 'yatm_network/block_unloader', function (block_entry)
    Network:unload_block(block_entry.id)
  end)
end

function Network:on_shutdown()
  debug("yatm_core.Network.on_shutdown/0", "Shutting down")
end

function Network:register_system(name, system)
  self.systems[name] = system
  return self
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

function Network:queue_refresh_infotext(pos)
  --print("queue_refresh_infotext/1", minetest.pos_to_string(pos))
  local hash = minetest.hash_node_position(pos)
  self.pending_actions[hash] = self.pending_actions[hash] or {pos = pos}
  self.pending_actions[hash].refresh_infotext = true
  return true
end

yatm_core.Network = Network
