--
-- RadioNetwork
--
local mod = assert(yatm_radio_network)

local Vector3 = assert(foundation.com.Vector3)
local MinHeap = assert(foundation.com.MinHeap)
local RingBuffer = assert(foundation.com.RingBuffer)
local hash_node_position = assert(core.hash_node_position)

local MIN_INTEGER = math.mininteger or -0xFFFFFFFFFFFFFFF

--- @namespace yatm_radio_network

---
---
--- @class RadioNetwork
local RadioNetwork = foundation.com.Class:extends("yatm_radio_network.RadioNetwork")
do
  local ic = RadioNetwork.instance_class

  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)

    self.m_monotonic_time = MIN_INTEGER

    self.m_messages = RingBuffer:new()
    self.m_timers = MinHeap:new()
    self.m_entries = {}
  end

  --- @spec #init(): void
  function ic:init()
  end

  --- @spec #terminate(): void
  function ic:terminate()
  end

  --- @spec #update(dtime: Float): void
  function ic:update(dtime)
    self.m_monotonic_time = self.m_monotonic_time + dtime

    local ts
    local addr
    local message
    local msg_item
    local nodes

    local node
    local nodedef
    while self.m_messages.m_size > 0 do
      msg_item = self.m_messages:peek()
      ts = msg_item[1]
      if ts < self.m_monotonic_time then
        self.m_messages:pop()
        addr = msg_item[2]
        message = msg_item[3]
        nodes = self.m_entries[addr]
        if nodes then
          for _id, entry in pairs(nodes) do
            node = core.get_node(entry.pos)
            nodedef = core.registered_nodes[node.name]
            if nodedef then
              if nodedef.radio_network then
                nodedef.radio_network:on_message(pos, node, addr, message)
              end
            end
          end
        end
      else
        break
      end
    end

    local item
    local id
    local timer
    local entry
    --- no, don't do this, I just know the internal structure of the heap and abusing it
    while self.m_timers.m_cursor > 0 do
      item, timer = self.m_timers:peek()
      if timer <= self.m_monotonic_time then
        self.m_timers:pop_min() -- discard
        addr = item[1]
        id = item[2]
        nodes = self.m_entries[addr]
        if nodes then
          entry = nodes[id]
          if entry then
            if entry.timer < self.m_monotonic_time then
              -- the entry has expired
              nodes[id] = nil
            end
          end
          if not next(nodes) then
            -- no more entries for this address
            self.m_entries[addr] = nil
          end
        end
      else
        break
      end
    end
  end

  --- @spec #subscribe_for_messages(pos: Vector3, addr: String, ttl: Number): void
  function ic:subscribe_for_messages(pos, addr, ttl)
    local id = hash_node_position(pos)
    local addr = addr
    local timer = self.m_monotonic_time + ttl

    self.m_timers:insert({addr, id}, timer)

    local nodes = self.m_entries[addr]
    if not nodes then
      nodes = {}
      self.m_entries[addr] = nodes
    end
    local entry = nodes[entry.id]
    if entry then
      entry.timer = timer
    else
      nodes[entry.id] = {
        id = id,
        pos = Vector3.copy(pos),
        addr = addr,
        timer = timer,
      }
    end
  end

  --- @spec #publish_message(addr: String, message: Any, meta?: Any): void
  function ic:publish_message(addr, message, meta)
    self.m_messages:push({ self.m_monotonic_time, addr, message, meta })
  end
end

yatm_radio_network.RadioNetwork = RadioNetwork
