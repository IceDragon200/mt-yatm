--
-- RadioNetwork
--
local mod = assert(yatm_radio_network)

local Vector4 = assert(foundation.com.Vector4)
local MinHeap = assert(foundation.com.MinHeap)
local RingBuffer = assert(foundation.com.RingBuffer)
local hash_node_position = assert(core.hash_node_position)
local get_node = assert(tetra.get_node)
local path_dirname = assert(foundation.com.path_dirname)

--- @namespace yatm_radio_network

local TICK_INTERVAL = 0.10

---
---
--- @class RadioNetwork
local RadioNetwork = foundation.com.Class:extends("yatm_radio_network.RadioNetwork")
do
  local ic = RadioNetwork.instance_class

  --- @type InitOptions: {
  ---   filename: String,
  --- }

  --- @spec #initialize(options: InitOptions): void
  function ic:initialize(options)
    options = options or {}
    ic._super.initialize(self)

    self.m_filename = options.filename

    self.m_mailbox_id = 0
    self.m_monotonic_time = 0
    self.m_tick_time = 0

    self.m_messages = RingBuffer:new()
    self.m_sub_timers = MinHeap:new()
    self.m_mailbox_timers = MinHeap:new()
    self.m_entries = {}
    self.m_mailboxes = {}
  end

  --- @spec #init(): void
  function ic:init()
    core.log("info", "initializing radio network")
    self:maybe_load()
  end

  --- @spec #terminate(): void
  function ic:terminate()
    core.log("info", "terminating radio network")
    self:maybe_save()
  end

  --- @since "0.3.0"
  --- @spec #maybe_load(): void
  function ic:maybe_load()
    if self.m_filename then
      local f = io.open(self.m_filename, 'r')
      if f then
        local blob = f:read("*all")
        f:close()
        local data = core.deserialize(blob)
        self:load_data(data)
      end
    end
  end

  --- @since "0.3.0"
  --- @spec #maybe_save(): void
  function ic:maybe_save()
    if self.m_filename then
      core.mkdir(path_dirname(self.m_filename))
      local blob = core.serialize(self:dump_data())
      core.safe_file_write(self.m_filename, blob)
    end
  end

  --- @spec #update(dtime: Float): void
  function ic:update(dtime)
    if dtime <= 0 then
      return
    end

    self.m_monotonic_time = self.m_monotonic_time + dtime
    if self.m_monotonic_time >= self.m_tick_time then
      self.m_tick_time = self.m_tick_time + TICK_INTERVAL
      self:flush_messages()
      self:reap_expired_subscribers()
      self:reap_expired_mailboxes()
    end
  end

  --- Flushes all pending messages to subscribers or mailboxes.
  ---
  --- @since "0.3.0"
  --- @spec #flush_messages(): void
  function ic:flush_messages()
    local ts
    local addr
    local message
    local metadata
    local msg_item
    local dimensions
    local mailboxes
    local node
    local nodedef

    while self.m_messages.m_size > 0 do
      msg_item = self.m_messages:peek()
      ts = msg_item[1]
      if ts < self.m_monotonic_time then
        self.m_messages:pop()
        addr = msg_item[2]
        message = msg_item[3]
        metadata = msg_item[4]
        dimensions = self.m_entries[addr]
        if dimensions then
          for _, nodes in pairs(dimensions) do
            for _id, entry in pairs(nodes) do
              if entry.expires_at > self.m_monotonic_time then
                --- entry has not expired
                node = get_node(entry.pos)
                nodedef = core.registered_nodes[node.name]
                if nodedef then
                  if nodedef.radio_network then
                    print("info", string.format(
                      "on_message %s, %s, %s, %s, %s",
                      vector.to_string(entry.pos),
                      node.name,
                      addr,
                      dump(message),
                      dump(metadata)
                    ))
                    nodedef.radio_network:on_message(entry.pos, node, addr, message, metadata)
                  end
                end
              end
            end
          end
        end

        mailboxes = self.m_mailboxes[addr]
        if mailboxes then
          for _, entry in pairs(mailboxes) do
            if entry.expires_at > self.m_monotonic_time then
              --- entry has not expired yet
              entry.head = entry.head + 1
              entry.data[entry.head] = msg_item
            end
          end
        end
      else
        break
      end
    end
  end

  --- @since "0.3.0"
  function ic:reap_expired_subscribers()
    local addr
    local item
    local dim_id
    local id
    local expires_at
    local entry
    local dimensions
    local nodes
    --- no, don't do this, I just know the internal structure of the heap and abusing it
    while self.m_sub_timers.m_cursor > 0 do
      item, expires_at = self.m_sub_timers:peek()
      if expires_at <= self.m_monotonic_time then
        self.m_sub_timers:pop_min() -- discard
        addr = item[1]
        dim_id = item[2]
        id = item[3]
        dimensions = self.m_entries[addr]
        if dimensions then
          nodes = dimensions[dim_id]
          if nodes then
            entry = nodes[id]
            if entry then
              if entry.expires_at <= self.m_monotonic_time then
                -- the entry has expired
                nodes[id] = nil
                if not next(nodes) then
                  -- no more entries for this address
                  dimensions[dim_id] = nil
                end
              end
            end
          end
          if not next(dimensions) then
            self.m_entries[addr] = nil
          end
        end
      else
        break
      end
    end
  end

  --- @since "0.3.0"
  function ic:reap_expired_mailboxes()
    local item
    local expires_at
    local addr
    local id
    local mailboxes
    local mailbox

    while self.m_mailbox_timers.m_cursor > 0 do
      item, expires_at = self.m_mailbox_timers:peek()
      if expires_at <= self.m_monotonic_time then
        self.m_mailbox_timers:pop_min() -- discard
        addr = item[1]
        id = item[2]
        mailboxes = self.m_mailboxes[addr]
        if mailboxes then
          mailbox = mailboxes[id]
          if mailbox then
            if mailbox.expires_at <= self.m_monotonic_time then
              mailboxes[id] = nil
              if not next(mailboxes) then
                self.m_mailboxes[addr] = nil
              end
            end
          end
        end
      else
        break
      end
    end
  end

  --- Used by nodes to register for radio messages, nodes only need to supply their position,
  --- the radio address they wish to listen on and how long they wish to remain subscribed (ttl).
  ---
  --- @spec #subscribe_for_messages(pos: WorldVector, addr: String, ttl: Number): void
  function ic:subscribe_for_messages(pos, addr, ttl)
    local id = hash_node_position(pos)
    print("info", string.format("subscribing %s, %s, %s", id, addr, ttl))
    pos.w = pos.w or 0
    local dim_id = pos.w
    local expires_at = self.m_monotonic_time + ttl

    self.m_sub_timers:insert({addr, dim_id, id}, expires_at)

    local dimensions = self.m_entries[addr]
    if not dimensions then
      dimensions = {}
      self.m_entries[addr] = dimensions
    end
    local nodes = dimensions[dim_id]
    if not nodes then
      nodes = {}
      dimensions[dim_id] = nodes
    end
    local entry = nodes[id]
    if entry then
      entry.expires_at = expires_at
    else
      nodes[id] = {
        dim_id = dim_id,
        id = id,
        pos = Vector4.copy(pos),
        addr = addr,
        expires_at = expires_at,
      }
    end
  end

  --- Remove an entry before its TTL is up.
  --- Normally this isn't necessary, unless you really want to keep your subscriptions super clean.
  ---
  --- @since "0.3.0"
  --- @spec #unsubscribe_for_messages(pos: WorldVector, addr: String): void
  function ic:unsubscribe_for_messages(pos, addr)
    local dimensions = self.m_entries[addr]
    if dimensions then
      local dim_id = pos.w or 0
      local nodes = dimensions[dim_id]
      if nodes then
        local id = hash_node_position(pos)
        nodes[id] = nil
        if not next(nodes) then
          dimensions[dim_id] = nil
        end
      end
      if not next(dimensions) then
        self.m_entries[addr] = nil
      end
    end
  end

  --- Reports if the network has ANY subscribers (i.e. nodes), mailboxes are not considered.
  ---
  --- @since "0.3.0"
  --- @spec #has_subscribers(): Boolean
  function ic:has_subscribers()
    if next(self.m_entries) then
      return true
    end
    return false
  end

  --- Ask the radio network to fabricate a new mailbox id that can be used by anything to store
  --- messages that can be retrieved at a later time.
  --- This should be primarily used by entities that want to fetch messages at their own pace.
  --- However, nodes can also use this instead of #subscribe_for_messages/3.
  --- Note. Passing no arguments will only return a new mailbox_id.
  ---       Otherwise both the address and ttl must be passed to subscribe the mailbox immediately.
  ---
  --- @since "0.3.0"
  --- @spec #request_mailbox_id(): Any
  --- @spec #request_mailbox_id(addr: String, ttl: Number): Any
  function ic:request_mailbox_id(addr, ttl)
    self.m_mailbox_id = self.m_mailbox_id + 1
    local id = self.m_mailbox_id
    if addr and ttl then
      self:subscribe_mailbox(id, addr, ttl)
    end
    return id
  end

  --- Use a known mailbox_id to upsert a mailbox to receive messages later with
  --- get_next_mailbox_message/2.
  --- `mailbox_id` can be retrieved by using `request_mailbox_id/0` or `request_mailbox_id/2`
  --- Note that the address can be changed at anytime, however the old mailbox at its original
  --- address will continue to live until it's ttl.
  ---
  --- @since "0.3.0"
  --- @spec #subscribe_mailbox(mailbox_id: Any, addr: String, ttl: Number): void
  function ic:subscribe_mailbox(mailbox_id, addr, ttl)
    local expires_at = self.m_monotonic_time + ttl
    self.m_mailboxes[addr] = self.m_mailboxes[addr] or {}
    local mailbox = self.m_mailboxes[addr][mailbox_id]
    if mailbox then
      mailbox.expires_at = expires_at
    else
      self.m_mailboxes[addr][mailbox_id] = {
        expires_at = expires_at,
        id = mailbox_id,
        addr = addr,
        head = 0,
        tail = 0,
        data = {},
      }
    end
    -- Push a new timer event to the mailbox timers, it should hopefully sort itself out
    self.m_mailbox_timers:insert({addr, mailbox_id}, expires_at)
  end

  --- Destroy an existing mailbox.
  ---
  --- @since "0.3.0"
  --- @spec #unsubscribe_mailbox(mailbox_id: Any, addr: String): void
  function ic:unsubscribe_mailbox(mailbox_id, addr)
    local mailboxes = self.m_mailboxes[addr]
    if mailboxes then
      mailboxes[mailbox_id] = nil
      if not next(mailboxes) then
        self.m_mailboxes[addr] = nil
      end
    end
  end

  --- Retrieves the next message in a mailbox, returns nil if there was no message.
  ---
  --- @since "0.3.0"
  --- @spec #get_next_mailbox_message(
  ---   mailbox_id: Any,
  ---   addr: String
  --- ): (message: Any, meta: Any) | nil
  function ic:get_next_mailbox_message(mailbox_id, addr)
    local mailboxes = self.m_mailboxes[addr]
    if mailboxes then
      local mailbox = mailboxes[mailbox_id]
      if mailbox then
        if mailbox.tail < mailbox.head then
          mailbox.tail = mailbox.tail + 1
          local item = mailbox.data[mailbox.tail]
          mailbox.data[mailbox.tail] = nil
          if mailbox.head == mailbox.tail then
            -- reset the cursors
            mailbox.head = 0
            mailbox.tail = 0
          end
          return item[3], item[4]
        end
      end
    end
    return nil, nil
  end

  --- Reports if the network has ANY mailboxes.
  ---
  --- @since "0.3.0"
  --- @spec #has_mailboxes(): Boolean
  function ic:has_mailboxes()
    if next(self.m_mailboxes) then
      return true
    end
    return false
  end

  --- Publish a new message to the network.
  --- `message` AND `meta` should be persistable, that is, they should not contain:
  ---   * userdata (i.e. ItemStack)
  ---   * functions
  --- `meta` is any optional data to include in the message.
  ---
  --- @spec #publish_message(addr: String, message: Any, meta?: Any): void
  function ic:publish_message(addr, message, meta)
    self.m_messages:push({ self.m_monotonic_time, addr, message, meta })
  end

  --- @spec #dump_data(): Table
  function ic:dump_data()
    return {
      mailbox_id = self.m_mailbox_id,
      monotonic_time = self.m_monotonic_time,
      tick_time = self.m_tick_time,
      messages = self.m_messages:dump_data(),
      sub_timers = self.m_sub_timers:dump_data(),
      mailbox_timers = self.m_mailbox_timers:dump_data(),
      entries = self.m_entries,
      mailboxes = self.m_mailboxes,
    }
  end

  --- @spec #load_data(data: Table): void
  function ic:load_data(data)
    self.m_mailbox_id = data.mailbox_id
    self.m_monotonic_time = data.monotonic_time
    self.m_tick_time = data.tick_time
    self.m_messages = self.m_messages:load_data(data.messages)
    self.m_sub_timers = self.m_sub_timers:load_data(data.sub_timers)
    self.m_mailbox_timers = self.m_mailbox_timers:load_data(data.mailbox_timers)
    self.m_entries = data.entries
    self.m_mailboxes = data.mailboxes
  end
end

mod.RadioNetwork = RadioNetwork
