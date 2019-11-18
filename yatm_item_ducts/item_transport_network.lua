--[[

  This Network handles Item Transport, devices can still handle their own item handling.

  Only item ducts should register on this network.

  The 3 main components of an item transport are:
  * Inserters - these will insert items from the network and place them into their adjacent devices
  * Extractors - these will extract items from adjacent devices for consumption by the network
  * Transporters - these only act as a pathway for the network and only matter when tracing the path

]]
local GenericTransportNetwork = assert(yatm.transport.GenericTransportNetwork)
local DIR6_TO_VEC3 = assert(yatm_core.DIR6_TO_VEC3)
local invert_dir = assert(yatm_core.invert_dir)
local ItemDevice = assert(yatm_item_storage.ItemDevice)

local ItemTransportNetwork = GenericTransportNetwork:extends()
local m = assert(ItemTransportNetwork.instance_class)

function m:initialize(options)
  m._super.initialize(self, options)

  yatm.clusters:observe('on_block_expired', 'item_transport_network/block_unloader', function (block_id)
    self:unload_block(block_id)
  end)
end

function m:update_extractor_duct(network, extractor_hash, extractor, items_available)
  for dir, v3 in pairs(DIR6_TO_VEC3) do
    local new_pos = vector.add(extractor.pos, v3)
    local node_face_dir = invert_dir(dir)

    local stack, err = ItemDevice.get_item(new_pos, node_face_dir)
    if err then
      if network.debug then
        print("ITN: update_extractor_duct error", err, minetest.pos_to_string(new_pos), yatm_core.inspect_axis(node_face_dir))
      end
    else
      if yatm_core.itemstack_is_blank(stack) then
        --
      else
        local new_hash = minetest.hash_node_position(new_pos)
        if not items_available[extractor_hash] then
          items_available[extractor_hash] = {}
        end

        items_available[extractor_hash][new_hash] = {
          pos = new_pos,
          dir = node_face_dir,
          stack = stack,
        }

        if network.debug then
          print("DEBUG", self.m_description, minetest.pos_to_string(new_pos), yatm_core.inspect_axis(node_face_dir), "found an item stack", stack:to_string())
        end
      end
    end
  end
end

function m:update_inserter_duct(network, inserter_hash, inserter, items_available)
  local new_items_available = items_available
  for dir, v3 in pairs(DIR6_TO_VEC3) do
    if yatm_core.is_table_empty(new_items_available) then
      break
    end

    local insert_dir = invert_dir(dir)
    local target_pos = vector.add(inserter.pos, v3)

    local old_items_available = new_items_available
    new_items_available = {}

    for extractor_hash, old_entries in pairs(old_items_available) do
      local new_entries = {}

      for entry_hash, entry in pairs(old_entries) do
        local stack = entry.stack:peek_item(1)

        if ItemDevice.room_for_item(target_pos, insert_dir, stack) then
          local remaining, err = ItemDevice.insert_item(target_pos, insert_dir, stack, true)
          if err then
            if network.debug then
              print(self.m_description, "insert_item error", err, minetest.pos_to_string(target_pos), yatm_core.inspect_axis(insert_dir))
            end
            new_entries[entry_hash] = entry
          else
            if remaining:is_empty() then
              local extracted, err = ItemDevice.extract_item(entry.pos, entry.dir, stack, true)
              if network.debug then
                print(self.m_description, "inserted item", minetest.pos_to_string(target_pos), yatm_core.inspect_axis(insert_dir), yatm_core.itemstack_inspect(stack))
                print(self.m_description, "remaining item", minetest.pos_to_string(target_pos), yatm_core.inspect_axis(insert_dir), yatm_core.itemstack_inspect(remaining))
              end

              local new_stack = ItemStack(entry.stack)
              new_stack:take_item(extracted:get_count())

              if new_stack:is_empty() then
                --
              else
                entry.stack = new_stack
                new_entries[entry_hash] = entry
              end
            else
              if network.debug then
                print(self.m_description, "remaining is not empty", minetest.pos_to_string(target_pos), yatm_core.inspect_axis(insert_dir), yatm_core.itemstack_inspect(stack), yatm_core.itemstack_inspect(remaining))
              end
              new_entries[entry_hash] = entry
            end
          end
        else
          new_entries[entry_hash] = entry
        end
      end

      if not yatm_core.is_table_empty(new_entries) then
        new_items_available[extractor_hash] = new_entries
      end
    end
  end
  return new_items_available
end

function m:update_network(network, counter, delta)
  local extractors = network.members_by_type["extractor"]
  local inserters = network.members_by_type["inserter"]

  if extractors and inserters then
    local items_available = {}

    for extractor_hash,extractor in pairs(extractors) do
      if self:check_network_member(extractor, network) then
        self:update_extractor_duct(network, extractor_hash, extractor, items_available)
      end
    end

    if yatm_core.is_table_empty(items_available) then
      if network.debug then
        print(self.m_description, network.id, "no available items")
      end
    else
      for inserter_hash,inserter in pairs(inserters) do
        if yatm_core.is_table_empty(items_available) then
          if network.debug then
            print(self.m_description, network.id, "items finished")
          end
          break
        end
        if self:check_network_member(inserter, network) then
          items_available = self:update_inserter_duct(network, inserter_hash, inserter, items_available)
        end
      end
    end
  end
end

yatm_item_ducts.ItemTransportNetwork = ItemTransportNetwork:new({
  description = "Item Transport Network",
  abbr = "itn",
  node_interface_name = "item_transport_device",
})

do
  minetest.register_globalstep(function (delta)
    yatm_item_ducts.ItemTransportNetwork:update(delta)
  end)

  minetest.register_lbm({
    name = "yatm_item_ducts:item_transport_network_reload_lbm",
    nodenames = {
      "group:item_network_device",
    },
    run_at_every_load = true,
    action = function (pos, node)
      yatm_item_ducts.ItemTransportNetwork:register_member(pos, node)
    end
  })
end
