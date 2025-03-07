--[[

  Generic Transport Network

  GTN is an implementation of the IETV (Inserter, Extractor, Transporter, Valve) pattern in YATM.

  Currently it's only used for Items and Fluids, but could be used for other resources.

]]
local Directions = assert(foundation.com.Directions)
local random_string16 = assert(foundation.com.random_string16)
local table_keys = assert(foundation.com.table_keys)
local copy_node = assert(foundation.com.copy_node)
local node_to_string = assert(foundation.com.node_to_string)

local GenericTransportNetwork = foundation.com.Class:extends("GenericTransportNetwork")
do
  local ic = assert(GenericTransportNetwork.instance_class)

  --- @type config_options :: {
  ---   -- A name for the network, only used for logging
  ---   description = String.t,
  ---   -- The name of the of the interface key in the node definition
  ---   node_interface_name = String.t,
  ---   -- A short abbreviated name for the network, will be used when generating ids
  ---   abbr = String.t,
  --- }

  ---
  --- @spec #initialize(config :: config_options) :: void
  function ic:initialize(config)
    -- abbreviation
    self.m_abbr = config.abbr
    self.m_description = config.description
    self.m_node_interface_name = config.node_interface_name

    -- this contains a list of all the members in the network indexed by their hashed position
    self.m_members = {}
    -- this contains a map of members indexed first by their main type (i.e. inserter, extractor, transporter) and then by their hash position
    self.m_members_by_type = {}
    self.m_block_members = {}

    self.m_networks = {}
    self.m_queue = {}
    self.m_counter = 0
    self.m_need_network_gc = false
    self.m_invalid_networks = {}
  end

  -- If something odd happens to a network, call this function to force an invalidation and self-check
  function ic:invalidate_network(network)
    assert(network, "expected a network")
    assert(network.id, "expected network to have an id")
    print(self.m_description, "invalidating network", network.id)
    self.m_invalid_networks[network.id] = true
  end

  -- Call this when trying to use a network member, this will ensure that it hasn't become invalid
  function ic:check_network_member(member, network)
    local node = minetest.get_node(assert(member.pos))
    if node.name == member.name then
      return true
    else
      self:invalidate_network(network)
      return false
    end
  end

  function ic:get_network(network_id)
    return self.m_networks[network_id]
  end

  function ic:get_member(pos)
    local id = minetest.hash_node_position(pos)
    return self.m_members[id]
  end

  function ic:register_member(pos, node)
    assert(pos, "expected a position")
    assert(node, "expected a node")
    self:update_member(pos, node, true)
  end

  function ic:update_member(pos, node, is_register)
    assert(pos, "expected a position")
    assert(node, "expected a node")

    if is_register then
      print(self.m_description, "update_member/3", "registering", minetest.pos_to_string(pos), node_to_string(node))
    else
      print(self.m_description, "update_member/3", "updating registration", minetest.pos_to_string(pos), node_to_string(node))
    end

    local node_id = minetest.hash_node_position(pos)
    local nodedef = assert(minetest.registered_nodes[node.name])
    local interface = nodedef[self.m_node_interface_name]
    if not interface then
      error(
        self.m_description ..
        " update_member/3 missing interface=" .. self.m_node_interface_name ..
        " at pos=" .. minetest.pos_to_string(pos) ..
        " for node=" .. node_to_string(node)
      )
    end
    local device_type = assert(interface.type)
    local device_subtype = interface.subtype
    local old_record = self.m_members[node_id]
    local old_network_id = nil

    if old_record then
      if is_register then
        print(self.m_description, "WARN", "duplicate registration attempted", minetest.pos_to_string(pos), node.name)
      else
        print(self.m_description, "removing old record", minetest.pos_to_string(pos), node.name)
      end

      self.m_members_by_type[old_record.device_type][node_id] = nil
      if not next(self.m_members_by_type[old_record.device_type]) then
        self.m_members_by_type[old_record.device_type] = nil
      end

      if old_record.network_id then
        old_network_id = old_record.network_id

        if self.m_networks[old_network_id] then
          -- invalidate the network
          local n = self.m_networks[old_network_id]
          n.members[node_id] = nil
          if n.members_by_type[old_record.device_type] then
            n.members_by_type[old_record.device_type][node_id] = nil
          else
            print(self.m_description, "WARN", "no members of type", old_network_id, old_record.device_type)
          end
        else
          print(self.m_description, "ERROR", "network does not exist", old_network_id, minetest.pos_to_string(pos), node.name)
        end
      end
    end

    local record = {
      id = node_id,
      block_id = 0,
      pos = vector.copy(pos),
      node = copy_node(node),
      name = node.name,
      param1 = node.param1,
      param2 = node.param2,
      device_type = assert(device_type),
      device_subtype = device_subtype,
      groups = interface.groups,
      counter = -1,
      interface = interface,
    }

    self.m_members[node_id] = record
    if not self.m_members_by_type[device_type] then
      self.m_members_by_type[device_type] = {}
    end
    self.m_members_by_type[device_type][node_id] = record

    local block_id = yatm.clusters:mark_node_block(pos, node)
    record.block_id = block_id
    if not self.m_block_members[record.block_id] then
      self.m_block_members[record.block_id] = {}
    end
    self.m_block_members[record.block_id][node_id] = true

    -- register will cause a refresh on it's own position
    self:queue_all_adjacent(pos)
  end

  function ic:queue_all_adjacent(pos)
    local node_id = minetest.hash_node_position(pos)

    self.m_queue[node_id] = pos

    local neighbour_pos
    local neighbour_node_id
    for dir,v3 in pairs(Directions.DIR6_TO_VEC3) do
      neighbour_pos = vector.add(pos, v3)
      neighbour_node_id = minetest.hash_node_position(neighbour_pos)
      self.m_queue[neighbour_node_id] = neighbour_pos
    end
  end

  function ic:unregister_member(pos)
    print(self.m_description, "unregister_member/1", "unregistering", minetest.pos_to_string(pos))
    local node_id = minetest.hash_node_position(pos)

    local record = self.m_members[node_id]

    if record then
      local device_type = record.device_type

      self.m_members[node_id] = nil
      self.m_members_by_type[device_type][node_id] = nil

      if not next(self.m_members_by_type[device_type]) then
        self.m_members_by_type[device_type] = nil
      end

      if record.network_id then
        local network = self.m_networks[record.network_id]
        if network then
          network.members[node_id] = nil

          local mbt = network.members_by_type[record.device_type]

          if mbt then
            mbt[node_id] = nil
          end
        end
      end

      if record.block_id then
        if self.m_block_members[record.block_id] then
          self.m_block_members[record.block_id][node_id] = nil

          if not next(self.m_block_members[record.block_id]) then
            self.m_block_members[record.block_id] = nil
          end
        end
      end

      -- unregister will cause a refresh on ALL positions adjacent to the current
      self:queue_all_adjacent(pos)
    else
      print(self.m_description, "unregister_member/1", "nothing was registered at that position!?", minetest.pos_to_string(pos))
    end
  end

  function ic:unload_block(block_id)
    if self.m_block_members[block_id] then
      local member_ids = self.m_block_members[block_id]
      self.m_block_members[block_id] = {}

      for member_id,_ in pairs(member_ids) do
        local member = self.m_members[member_id]
        if member then
          self:unregister_member(member.pos)
        end
      end
    end
  end

  function ic:get_members_by_type(device_type)
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

  function ic:get_connected_pos(pos, node, nodedef, to_visit)
    local interface = nodedef[self.m_node_interface_name]
    for _d6,v3 in pairs(Directions.DIR6_TO_VEC3) do
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
          elseif interface.type == "valve" then
            -- Valves can only connect if their state is on
            if interface.state == "on" then
              table.insert(to_visit, npos)
            end
          elseif interface.type == "transporter" then
            -- Transporters can connect to anything that is a transport device, that's kinda their job.
            table.insert(to_visit, npos)
          end
        end
      end
    end
  end

  function ic:generate_network_id()
    local result = {self.m_abbr}

    for i = 1,4 do
      table.insert(result, random_string16(4))
    end

    return table.concat(result, ":")
  end

  function ic:resolve_invalid_networks(counter, delta, trace)
    if next(self.m_invalid_networks) then
      local network
      local node
      local old_invalid_networks = self.m_invalid_networks
      self.m_invalid_networks = {}

      for network_id,_ in pairs(old_invalid_networks) do
        network = self.m_networks[network_id]

        if network then
          for member_hash,member_entry in pairs(network.members) do
            node = minetest.get_node(member_entry.pos)

            if node.name ~= member_entry.name then
              print(self.m_description, "expected", member_entry.name, "got", node.name, "unregistrering for refresh")
              self:unregister_member(member_entry.pos)
            end
          end
        end
      end
    end
  end

  function ic:resolve_queue(counter, _delta, trace)
    if not next(self.m_queue) then
      return
    end
    local should_continue
    local queue = self.m_queue
    local member
    self.m_queue = {}

    for hash,pos in pairs(queue) do
      should_continue = true

      if self.m_members[hash] then
        member = self.m_members[hash]

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

        while next(to_visit) do
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

        if next(members) then
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
                  print(self.m_description, "WARN", "node still exists in a network", minetest.pos_to_string(entry.pos), entry.network_id)

                  n.members[ohash] = nil
                  local mbt = n.members_by_type[entry.device_type]

                  if mbt then
                    mbt[ohash] = nil
                  end

                  if not next(mbt) then
                    n.members_by_type[entry.device_type] = nil
                  end
                end
              end

              entry.network_id = network_id
              network.members[ohash] = entry
              network.members_by_type[entry.device_type] = network.members_by_type[entry.device_type] or {}
              network.members_by_type[entry.device_type][ohash] = entry

              local meta = minetest.get_meta(entry.pos)

              local node_description = minetest.registered_nodes[entry.name].description

              meta:set_string("infotext", node_description .. "\n" .. self.m_description .. " ID <" .. network_id .. ">")
            end
          end

          print(self.m_description, "new network", network_id)
          self.m_networks[network_id] = network
        end
      end
    end
  end

  function ic:update_networks(counter, delta, trace)
    for _network_id,network in pairs(self.m_networks) do
      if next(network.members) then
        network.wait = (network.wait or 0) - delta

        while network.wait <= 0 do
          network.wait = network.wait + 0.25
          self:update_network(network, counter, delta, trace)
        end
      else
        self.m_need_network_gc = true
      end
    end
  end

  function ic:gc_networks(counter, delta)
    print(self.m_description, "gc_networks/0", "running garbage collection")
    local keys = table_keys(self.m_networks)
    local network

    for _,network_id in ipairs(keys) do
      network = self.m_networks[network_id]

      if not next(network.members) then
        self.m_networks[network_id] = nil

        print(self.m_description, "Removed empty network", network_id)
      end
    end
  end

  function ic:update(delta, trace)
    local counter = self.m_counter

    local span
    if trace then
      span = trace:span_start("resolve_invalid_networks")
    end
    self:resolve_invalid_networks(counter, delta, span)
    if span then
      span:span_end()
    end

    if trace then
      span = trace:span_start("resolve_queue")
    end
    self:resolve_queue(counter, delta, span)
    if span then
      span:span_end()
    end

    if trace then
      span = trace:span_start("update_networks")
    end
    self:update_networks(counter, delta, span)
    if span then
      span:span_end()
    end

    if self.m_need_network_gc then
      self.m_need_network_gc = false
      self:gc_networks(counter, delta)
    end

    self.m_counter = counter + 1
  end
end

yatm_clusters.GenericTransportNetwork = GenericTransportNetwork
