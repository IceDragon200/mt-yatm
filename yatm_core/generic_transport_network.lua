--[[
Generic Transport Network

GTN is an implementation of the IET (Inserter, Extractor, Transporter) pattern in YATM.

Currently it's only used for Items and Fluids, but could be used for other resources.
]]
local GenericTransportNetwork = yatm_core.Class:extends()
local m = assert(GenericTransportNetwork.instance_class)

--[[
@type config_options :: {
  -- A name for the network, only used for logging
  description = String.t,
  -- The name of the of the interface key in the node definition
  node_interface_name = String.t,
  -- A short abbreviated name for the network, will be used when generating ids
  abbr = String.t,
}
]]

--[[
@spec m:initialize(config :: config_options) :: void
]]
function m:initialize(config)
  -- abbreviation
  self.m_abbr = config.abbr
  self.m_description = config.description
  self.m_node_interface_name = config.node_interface_name
  -- this contains a list of all the members in the network indexed by their hashed position
  self.m_members = {}
  -- this contains a map of members indexed first by their main type (i.e. inserter, extractor, transporter) and then by their hash position
  self.m_members_by_type = {}
  self.m_networks = {}
  self.m_queue = {}
  self.m_counter = 0
  self.m_need_network_gc = false
  self.m_invalid_networks = {}
end

-- If something odd happens to a network, call this function to force an invalidation and self-check
function m:invalidate_network(network)
  assert(network, "expected a network")
  assert(network.id, "expected network to have an id")
  print(self.m_description, "invalidating network", network.id)
  self.m_invalid_networks[network.id] = true
end

-- Call this when trying to use a network member, this will ensure that it hasn't become invalid
function m:check_network_member(member, network)
  local node = minetest.get_node(assert(member.pos))
  if node.name == member.name then
    return true
  else
    self:invalidate_network(network)
    return false
  end
end

function m:register_member(pos, node)
  assert(pos, "expected a position")
  assert(node, "expected a node")
  self:update_member(pos, node, true)
end

function m:update_member(pos, node, is_register)
  assert(pos, "expected a position")
  assert(node, "expected a node")
  if is_register then
    print(self.m_description, "update_member/3", "registering", minetest.pos_to_string(pos), node.name)
  else
    print(self.m_description, "update_member/3", "updating registration", minetest.pos_to_string(pos), node.name)
  end
  local hash = minetest.hash_node_position(pos)
  local nodedef = minetest.registered_nodes[node.name]
  local interface = assert(nodedef[self.m_node_interface_name])
  local device_type = assert(interface.type)
  local old_record = self.m_members[hash]
  local old_network_id = nil
  if old_record then
    if is_register then
      print("WARN", "duplicate registration attempted", minetest.pos_to_string(pos), node.name)
    end
    self.m_members_by_type[device_type][hash] = nil
    if yatm_core.is_table_empty(self.m_members_by_type[device_type]) then
      self.m_members_by_type[device_type] = nil
    end
    if old_record.network_id then
      old_network_id = old_record.network_id
      if self.m_networks[network_id] then
        -- invalidate the network
        local n = self.m_networks[network_id]
        n.members[hash] = nil
        if n.members_by_type[old_record.device_type] then
          n.members_by_type[old_record.device_type][hash] = nil
        end
      end
    end
  end

  local record = {
    pos = pos,
    name = node.name,
    device_type = device_type,
    counter = -1,
    interface = interface,
  }
  self.m_members[hash] = record
  self.m_members_by_type[device_type] = self.m_members_by_type[device_type] or {}
  self.m_members_by_type[device_type][hash] = record

  -- register will cause a refresh on it's own position
  self.m_queue[hash] = pos
end

function m:queue_all_adjacent(pos)
  local hash = minetest.hash_node_position(pos)
  self.m_queue[hash] = pos
  for dir,v3 in pairs(yatm_core.DIR6_TO_VEC3) do
    local new_pos = vector.add(pos, v3)
    local new_hash = minetest.hash_node_position(new_pos)
    self.m_queue[new_hash] = new_pos
  end
end

function m:unregister_member(pos)
  print(self.m_description, "unregister_member/1", "unregistering", minetest.pos_to_string(pos))
  local hash = minetest.hash_node_position(pos)

  local record = self.m_members[hash]
  if record then
    local device_type = record.device_type
    self.m_members[hash] = nil
    self.m_members_by_type[device_type][hash] = nil
    if yatm_core.is_table_empty(self.m_members_by_type[device_type]) then
      self.m_members_by_type[device_type] = nil
    end
    local network = self.m_networks[record.network_id]
    if network then
      network.members[hash] = nil
      local mbt = network.members_by_type[record.device_type]
      if mbt then
        network.members_by_type[record.device_type][hash] = nil
      end
    end
    -- unregister will cause a refresh on ALL positions adjacent to the current
    self:queue_all_adjacent(pos)
  else
    print(self.m_description, "unregister_member/1", "nothing was registered at that position!?", minetest.pos_to_string(pos))
  end
end

function m:get_members_by_type(device_type)
  return self.m_members_by_type[device_type]
end

--[[
Checks if colors match, if any color is nil, then it will match
If any color is default, then it will match
Otherwise both colors must be the same
]]
local function matches_color(a, b)
  if a == nil or b == nil then
    return true
  elseif a == "default" or b == "default" then
    return true
  else
    return a == b
  end
end

function m:get_connected_pos(pos, node, nodedef, to_visit)
  local interface = nodedef[self.m_node_interface_name]
  for _d6,v3 in pairs(yatm_core.DIR6_TO_VEC3) do
    local npos = vector.add(pos, v3)
    local neighbour_node = minetest.get_node(npos)
    local neighbour_nodedef = minetest.registered_nodes[neighbour_node.name]
    if neighbour_nodedef and neighbour_nodedef[self.m_node_interface_name] then
      local neighbour_interface = neighbour_nodedef[self.m_node_interface_name]
      if matches_color(interface.color, neighbour_interface.color) then
        if interface.type == "extractor" then
          -- Extractors cannot connect to other extractors
          if neighbour_interface.type ~= "extractor" then
            table.insert(to_visit, npos)
          end
        elseif interface.type == "inserter" then
          -- Inserters cannot connect to other inserters
          if neighbour_interface.type ~= "inserter" then
            table.insert(to_visit, npos)
          end
        elseif interface.type == "transporter" then
          -- Transporters can connect to anything that is a FTD, that's kinda their job.
          table.insert(to_visit, npos)
        end
      end
    end
  end
end

function m:generate_network_id()
  local result = {self.m_abbr}
  for i = 1,4 do
    table.insert(result, yatm_core.random_string16(4))
  end
  return table.concat(result, ":")
end

function m:resolve_invalid_networks(counter, delta)
  if not yatm_core.is_table_empty(self.m_invalid_networks) then
    local old_invalid_networks = self.m_invalid_networks
    self.m_invalid_networks = {}
    for network_id,_ in pairs(old_invalid_networks) do
      local network = self.m_networks[network_id]
      if network then
        for member_hash,member_entry in pairs(network.members) do
          local node = minetest.get_node(member_entry.pos)
          if node.name ~= member_entry.name then
            print(self.m_description, "expected", member_entry.name, "got", node.name, "unregistrering for refresh")
            self:unregister_member(member_entry.pos)
          end
        end
      end
    end
  end
end

function m:resolve_queue(counter, _delta)
  if not yatm_core.is_table_empty(self.m_queue) then
    local queue = self.m_queue
    self.m_queue = {}

    for hash,pos in pairs(queue) do
      local should_continue = true
      if self.m_members[hash] then
        local member = self.m_members[hash]
        if member.counter and member.counter == counter then
          -- No need to scan this again, it was already encountered and refreshed this round
          should_continue = false
        end
      end

      if should_continue then
        local to_visit = {
          pos,
        }

        local visited = {}
        local members = {}

        while not yatm_core.is_table_empty(to_visit) do
          local old_to_visit = to_visit
          to_visit = {}

          for _,opos in ipairs(old_to_visit) do
            local ohash = minetest.hash_node_position(opos)
            if not visited[ohash] then
              visited[ohash] = true
              local node = minetest.get_node(opos)
              local nodedef = minetest.registered_nodes[node.name]

              if nodedef and nodedef[self.m_node_interface_name] then
                members[ohash] = {
                  pos = opos,
                  type = nodedef[self.m_node_interface_name].type,
                }
                self:get_connected_pos(opos, node, nodedef, to_visit)
              end
            end
          end
        end

        if not yatm_core.is_table_empty(members) then
          local network_id = self:generate_network_id()
          local network = {
            id = network_id,
            members = {},
            members_by_type = {},
          }
          for ohash,omember in pairs(members) do
            local entry = self.m_members[ohash]
            if entry then
              entry.counter = counter
              -- If it has an old network_id
              if entry.network_id then
                local n = self.m_networks[entry.network_id]
                if n then
                  -- Remove it from the old network
                  n.members[ohash] = nil
                end
              end
              entry.network_id = network_id
              network.members[ohash] = entry
              network.members_by_type[entry.device_type] = network.members_by_type[entry.device_type] or {}
              network.members_by_type[entry.device_type][ohash] = entry

              local meta = minetest.get_meta(entry.pos)
              meta:set_string("infotext", self.m_description .. " ID <" .. network_id .. ">")
            end
          end

          print(self.m_description, "new network", network_id)
          self.m_networks[network_id] = network
        end
      end
    end
  end
end

function m:update_networks(counter, delta)
  for _network_id,network in pairs(self.m_networks) do
    if yatm_core.is_table_empty(network.members) then
      self.m_need_network_gc = true
    else
      self:update_network(network, counter, delta)
    end
  end
end

function m:gc_networks(counter, delta)
  print(self.m_description, "gc_networks/0", "running garbage collection")
  local keys = yatm_core.table_keys(self.m_networks)
  for _,network_id in ipairs(keys) do
    local network = self.m_networks[network_id]
    if yatm_core.is_table_empty(network.members) then
      self.m_networks[network_id] = nil
      print(self.m_description, "Removed empty network", network_id)
    end
  end
end

function m:update(delta)
  local counter = self.m_counter
  self:resolve_invalid_networks(counter, delta)
  self:resolve_queue(counter, delta)
  self:update_networks(counter, delta)
  if self.m_need_network_gc then
    self.m_need_network_gc = false
    self:gc_networks(counter, delta)
  end
  self.m_counter = counter + 1
end

yatm_core.GenericTransportNetwork = GenericTransportNetwork
