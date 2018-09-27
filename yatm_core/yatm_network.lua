yatm_core.Network = {
  dirty = true,
  networks = {},
  has_lost_nodes = false,
  lost_nodes = {},
  need_refresh = false,
  refresh_queue = {},
}

yatm_core.Network.KEY = "yatm_network_id"
yatm_core.Network.TS = "yatm_network_updated_at"

function yatm_core.Network.encode_vec3(pos)
  return pos.x .. "." .. pos.y .. "." .. pos.z
end

function yatm_core.Network.generate_network_id(pos)
  local ts = os.time()
  local network_id = yatm_core.Network.encode_vec3(pos) .. "." .. ts
  return network_id, ts
end

function yatm_core.Network.initialize_network(network_id)
  yatm_core.Network.networks[network_id] = {
    id = network_id,
    members = {},
  }
  return network_id
end

function yatm_core.Network.create_network(pos)
  local network_id, ts = yatm_core.Network.generate_network_id(pos)
  return yatm_core.Network.initialize_network(network_id), ts
end

function yatm_core.Network.destroy_network(network_id)
  print("DESTROY NETWORK", network_id)
  local network = yatm_core.Network.networks[network_id]
  if network then
    local lost_nodes = yatm_core.Network.lost_nodes
    for _,node in pairs(network.members) do
      print("lost child", node.pos.x, node.pos.y, node.pos.z)
      yatm_core.Network.has_lost_nodes = true
      table.insert(lost_nodes, node)
    end
    yatm_core.Network.networks[network_id] = nil
  end
end

function yatm_core.Network.leave_network(network_id, pos)
  print("LEAVE NETWORK", pos.x, pos.y, pos.z, network_id)
  local network = yatm_core.Network.networks[network_id]
  if network then
    network.members[yatm_core.Network.encode_vec3(pos)] = nil
    return true
  end
  return false
end

function yatm_core.Network.join_network(network_id, pos)
  print("JOIN NETWORK", pos.x, pos.y, pos.z, network_id)
  local network = yatm_core.Network.networks[network_id]
  if network then
    local key = yatm_core.Network.encode_vec3(pos)
    if not network.members[key] then
      network.members[key] = {pos = pos}
    end
    return true
  end
  return false
end

function yatm_core.Network.has_network(network_id)
  return yatm_core.Network.networks[network_id] ~= nil
end

function yatm_core.Network.set_network_id(meta, value)
  meta:set_string(yatm_core.Network.KEY, value)
end

function yatm_core.Network.get_network_id(meta)
  return meta:get(yatm_core.Network.KEY)
end

function yatm_core.Network.set_network_ts(meta, value)
  assert(meta, "requires a NodeMetaRef")
  assert(value, "need a timestamp")
  meta:set_int(yatm_core.Network.TS, value)
end

function yatm_core.Network.get_network_ts(meta)
  return meta:get_int(yatm_core.Network.TS)
end

local function yatm_device_type(nodedef)
  if nodedef and nodedef.yatm_network then
    return nodedef.yatm_network.kind
  end
  return nil
end

function yatm_core.Network.reduce_network(origin_pos, acc, func)
  local positions = {{0, origin_pos}}
  local controllers = {}
  local visited = {}
  while #positions > 0 do
    local current_positions = positions
    positions = {}
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
        explore_neighbours, acc = func(pos, node, device_type, acc)
        if explore_neighbours then
          for dir,vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
            if dir ~= from_dir then
              table.insert(positions, {yatm_core.invert_dir(dir), vector.add(pos, vec3)})
            end
          end
        end
      end
    end
  end
  return acc
end

function yatm_core.Network.find_controllers(origin_pos, ts)
  return yatm_core.Network.reduce_network(origin_pos, {}, function (pos, node, device_type, acc)
    if device_type then
      local meta = minetest.get_meta(pos)
      local cur_ts = yatm_core.Network.get_network_ts(meta)
      -- if the device's ts is higher or equal to the locator, it should be ignored
      if cur_ts < ts then
        if device_type == "controller" then
          table.insert(acc, pos)
          return true, acc
        elseif device_type == "cable" then
          return true, acc
        else
          return true, acc
        end
      end
    end
    acc.first = false
    return false, acc
  end)
end

function yatm_core.Network.default_handle_network_changed(pos, node, ts, network_id, state)
  print("NETWORK CHANGED ", pos.x, pos.y, pos.z, node.name, "TS", ts, "NID", network_id, "STATE", state)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.yatm_network then
      local meta = minetest.get_meta(pos)
      if meta then
        yatm_core.Network.set_network_ts(meta, ts)
      end
      local old_network_id = yatm_core.Network.get_network_id(meta)
      if old_network_id and old_network_id ~= network_id then
        yatm_core.Network.leave_network(old_network_id, pos)
      end
      if network_id then
        yatm_core.Network.join_network(network_id, pos)
      end
      yatm_core.Network.set_network_id(meta, network_id)
      if nodedef.yatm_network.states then
        local new_name = nodedef.yatm_network.states[state]
        if new_name then
          if node.name ~= new_name then
            node.name = new_name
            minetest.swap_node(pos, node)
          end
        else
          print("WARN", node.name, "does not have a network state", state)
        end
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

local function mark_network(ts, origin_pos, network_id, state)
  return yatm_core.Network.reduce_network(origin_pos, 0, function (pos, node, device_type, acc)
    if device_type then
      local meta = minetest.get_meta(pos)
      local cur_ts = yatm_core.Network.get_network_ts(meta)
      if cur_ts < ts then
        if device_type == "controller" then
          trigger_network_changed(pos, node, ts, network_id, state)
          return true, acc + 1
        elseif device_type == "cable" then
          trigger_network_changed(pos, node, ts, network_id, state)
          return true, acc + 1
        else
          trigger_network_changed(pos, node, ts, network_id, state)
          -- don't explore any further
          return false, acc + 1
        end
      end
    end
    return false, acc
  end)
end

local function mark_network_offline(ts, origin_pos)
  return mark_network(ts, origin_pos, nil, "off")
end

local function mark_network_online(ts, origin_pos, network_id)
  return mark_network(ts, origin_pos, network_id, "on")
end

local function mark_network_conflict(ts, origin_pos, network_ids)
  return mark_network(ts, origin_pos, nil, "conflict")
end

local function refresh_network(origin_pos, ts)
  local controllers = yatm_core.Network.find_controllers(origin_pos, ts)
  local count = #controllers
  if count == 0 then
    return mark_network_offline(ts, origin_pos)
  elseif count == 1 then
    local pos = controllers[1]
    local meta = minetest.get_meta(pos)
    local network_id = yatm_core.Network.get_network_id(meta)
    return mark_network_online(ts, origin_pos, network_id)
  elseif count > 1 then
    local network_ids = {}
    for _,pos in ipairs(controllers) do
      local meta = minetest.get_meta(pos)
      local network_id = yatm_core.Network.get_network_id(meta)
      if network_id then
        print("CONFLICTING NID", network_id)
        table.insert(network_ids, network_id)
      end
    end
    return mark_network_conflict(ts, origin_pos, network_ids)
  end
end

function yatm_core.Network.refresh_network_topography(origin_pos, ts, params)
  print("Refreshing Network due to", params.kind, "TS", ts)
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
    return refresh_network(origin_pos, ts)
  else
    error("unexpected params")
  end
  return 0
end

function yatm_core.Network.schedule_refresh_network_topography(pos, params)
  yatm_core.Network.need_refresh = true
  table.insert(yatm_core.Network.refresh_queue, {pos, params})
end

function yatm_core.Network.update(_dtime)
  if yatm_core.Network.need_refresh then
    local ts = os.time()
    local refresh_queue = yatm_core.Network.refresh_queue
    yatm_core.Network.need_refresh = false
    yatm_core.Network.refresh_queue = {}
    for _,pair in ipairs(refresh_queue) do
      local pos = pair[1]
      local params = pair[2]
      local affected_count = yatm_core.Network.refresh_network_topography(pos, ts, params)
      print("Refreshed ", affected_count, " devices")
    end
  end

  if yatm_core.Network.has_lost_nodes then
    local ts = os.time()
    local lost_nodes = yatm_core.Network.lost_nodes
    yatm_core.Network.has_lost_nodes = false
    yatm_core.Network.lost_nodes = {}
    for _,entry in ipairs(lost_nodes) do
      local node = minetest.get_node(entry.pos)
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef then
        if nodedef.on_yatm_network_changed then
          print("NETWORK LOST", entry.pos.x, entry.pos.y, entry.pos.z, node.name)
          nodedef.on_yatm_network_changed(entry.pos, node, ts, nil, "off")
        else
          print("NETWORK LOST but couldn't handle it", entry.pos.x, entry.pos.y, entry.pos.z, node.name)
        end
      end
    end
  end
end

minetest.register_globalstep(yatm_core.Network.update)
