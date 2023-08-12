--
-- Computers service, allows registering computers
--
local OKU = yatm_oku.OKU
if not OKU then
  yatm.error("Cannot create computer service, OKU not available!")
  return
end

local BinSchema = foundation.com.BinSchema
if not BinSchema then
  yatm.error("computers service not available, foundation.com.BinSchema is unavailable")
  return
end

local path_join = assert(foundation.com.path_join)
local Trace = foundation.com.Trace
local Vector3 = foundation.com.Vector3

-- Pick a buffer module, prefer binary or string, as it's faster
local Buffer
if foundation.com.BinaryBuffer then
  yatm.info("using BinaryBuffer as primary buffer for computers")
  Buffer = assert(foundation.com.BinaryBuffer)
else
  yatm.info("using StringBuffer as primary buffer for computers")
  Buffer = assert(foundation.com.StringBuffer)
end

--- @namespace yatm_oku

--
-- This is the header of the computer state file, since OKU
-- handles the actual machine state, it's not included here.
-- Doesn't help that the format is variable depending on the size and type.
--
local ComputerStateHeaderBaseSchema =
  BinSchema:new("ComputerStateHeaderBase", {
    {"magic", foundation.com.binary_types.Bytes:new(4)},
    --
    {"version", "i32"},
  })

local ComputerStateHeaderSchemaV1 =
  BinSchema:new("ComputerStateHeaderV1", {
    --
    {"secret", "u8string"},
    -- Just hash these to get the id again if needed
    {"x", "i32"},
    {"y", "i32"},
    {"z", "i32"},
    --
    {"node_name", "u8string"},
    {"node_param1", "i32"},
    {"node_param2", "i32"},
    -- Here would be the oku state, but OKU handles its own serialization.
  })

local ComputerStateHeaderSchemaV2 =
  BinSchema:new("ComputerStateHeaderV2", {
    --
    {"active", "i32"},
    {"reserved0", "i32"},
    {"secret", "u8string"},
    -- Just hash these to get the id again if needed
    {"x", "i32"},
    {"y", "i32"},
    {"z", "i32"},
    --
    {"node_name", "u8string"},
    {"node_param1", "i32"},
    {"node_param2", "i32"},
    -- Here would be the oku state, but OKU handles its own serialization.
  })

--- @class Computers
local Computers = foundation.com.Class:extends("ComputersService")
do
  local ic = assert(Computers.instance_class)

  --- @spec #initialize(): void
  function ic:initialize()
    self.m_root_dir = path_join(minetest.get_worldpath(), "/yatm/oku")
    minetest.mkdir(self.m_root_dir)

    --- @member m_computers: { [name: String]: ComputerState }
    self.m_computers = {}
  end

  local function pos_to_basename(pos)
    return string.format("computer-%08x", minetest.hash_node_position(pos)) .. ".bin"
  end

  ---
  --- Should be called by the minetest startup to do stuff.
  ---
  --- @spec #setup(): void
  function ic:setup()
    --
  end

  local function make_label(pos, node)
    return "computer-" .. node.name .. "-" .. minetest.pos_to_string(pos)
  end

  ---
  ---
  --- @spec #load_computer_state_at_pos(pos: Vector3): (ComputerState | nil, Error)
  function ic:load_computer_state_at_pos(pos)
    local basename = pos_to_basename(pos)
    local filename = path_join(self.m_root_dir, basename)

    local trace
    if Trace then
      trace = Trace:new('load_computer_state_at_pos/' .. minetest.pos_to_string(pos))
    end
    local span
    if trace then
      span = trace:span_start("io.open")
    end
    local file = io.open(filename, "r")
    if span then
      span:span_end()
    end

    if file then
      if trace then
        span = trace:span_start('file#read')
      end
      local stream = Buffer:new(file:read('*all'), 'r')
      file:close()
      if span then
        span:span_end()
      end

      if trace then
        span = trace:span_start('state-load')
      end
      -- FIXME: This entire section should be wrapped in a protected call
      --        and the file closed properly.
      -- Read the state header
      local state, br
      state, br = ComputerStateHeaderSchemaBase:read(stream, {})

      if state.version == 1 then
        state, br = ComputerStateHeaderSchemaV1:read(stream, {})
      else
        state, br = ComputerStateHeaderSchemaV2:read(stream, {})
      end

      -- Let OKU read the rest
      local oku
      oku, br = OKU:binload(stream)

      stream:close()

      if span then
        span:span_end() -- close state-load
      end
      if trace then
        trace:span_end() -- close trace
        trace:inspect()
      end

      local state_pos = vector.new(state.x, state.y, state.z)
      local node = {
        name = state.node_name,
        param1 = state.node_param1,
        param2 = state.node_param2,
      }

      return {
        id = minetest.hash_node_position(pos),
        pos = state_pos,
        node = node,
        secret = state.secret,
        active = state.active or 1,
        label = make_label(pos, node),
        oku = oku
      }, nil
    else
      return nil, "file cannot be opened"
    end
  end

  ---
  --- @spec #save_computer_state(ComputerState, Trace): (bytes_written: Integer, error: Error)
  function ic:save_computer_state(state, trace)
    print("Saving Computer State", minetest.pos_to_string(state.pos))
    local basename = pos_to_basename(state.pos)
    local filename = path_join(self.m_root_dir, basename)

    local span
    if trace then
      span = trace:span_start('save_computer_state/' .. minetest.pos_to_string(state.pos))
    else
      if Trace then
        span = Trace:new('save_computer_state/' .. minetest.pos_to_string(state.pos))
      end
    end
    local stream = Buffer:new('', 'w')

    local func_trace = span:span_start("dump")

    local bytes_written = 0
    local bw
    local err

    bw, err =
      ComputerStateHeaderBaseSchema:write(stream, {
        magic = "OCS1",
        version = 2,
      })
    bytes_written = bytes_written + bw

    bw, err =
      ComputerStateHeaderSchemaV2:write(stream, {
        active = state.active,
        secret = state.secret,
        reserved0 = 0,

        x = state.pos.x,
        y = state.pos.y,
        z = state.pos.z,

        node_name = state.node.name,
        node_param1 = state.node.param1,
        node_param2 = state.node.param2,
      })
    bytes_written = bytes_written + bw

    if err then
      stream:close()
      return bytes_written, "error while writing header " .. err
    end

    bw, err = state.oku:bindump(stream)
    bytes_written = bytes_written + bw

    func_trace:span_end()

    if err then
      stream:close()
      return bytes_written, "error while writing oku state " .. err
    end

    stream:close()

    func_trace = span:span_start("safe_file_write")
    minetest.safe_file_write(filename, stream:blob())
    func_trace:span_end()

    span:span_end()
    if not trace then
      span:inspect()
    end
    return bytes_written, nil
  end

  ---
  --- @spec #delete_computer_state_at_pos(pos: Vector3): Boolean
  function ic:delete_computer_state_at_pos(pos)
    local basename = pos_to_basename(pos)
    local filename = path_join(self.m_root_dir, basename)

    local file = io.open(filename, "r")
    if file then
      file:close()
      os.remove(filename)
      return true
    else
      return false
    end
  end

  --- @spec #persist_computer_states(): void
  function ic:persist_computer_states()
    local trace
    if Trace then
      trace = Trace:new('persist_computer_states')
    end
    for _hash,state in pairs(self.m_computers) do
      self:save_computer_state(state, trace)
    end
    if trace then
      trace:span_end()
      trace:inspect()
    end
  end

  --- @spec #terminate(): void
  function ic:terminate()
    print("yatm.computers", "terminating")
    -- Persist all active computer states
    self:persist_computer_states()
    -- release all the computers
    self.m_computers = {}
    print("yatm.computers", "terminated")
  end

  --- @spec #update(dt: Float, trace: Trace): void
  function ic:update(dt, trace)
    --
    local clock_speed = math.floor(dt * 1000)
    local span
    for _, computer in pairs(self.m_computers) do
      if trace then
        span = trace:span_start(computer.label)
      end

      if computer.active > 0 then
        local steps_taken, err = computer.oku:step(clock_speed)
        print("STEPS", ct.name, steps_taken, err)
      end

      if trace then
        span:span_end()
      end
    end
  end

  --
  -- Creates a brand spanking new instance of a computer
  --
  -- Options:
  --   See OKU:new() for details
  --- @spec #create_computer_at_pos(pos: Vector3, node: NodeRef, secret: String, options: Table): ComputerState
  function ic:create_computer_at_pos(pos, node, secret, options)
    assert(type(secret) == "string", "expected secret to be a string got:" .. type(secret))
    assert(type(options) == "table", "expected an options table got:" .. type(options))

    local hash = minetest.hash_node_position(pos)
    local computer = self.m_computers[hash]
    if computer then
      error("a computer already exists hash=" .. hash)
    else
      computer = {
        id = hash,
        pos = pos,
        node = node,
        secret = secret,
        active = 0,
        label = make_label(pos, node),
        oku = OKU:new(options)
      }
      self.m_computers[hash] = computer
    end

    return computer
  end

  ---
  --- Retrieve a computer entry.
  ---
  --- For the love of god, don't do anything funky with it!
  ---
  --- @spec #get_computer_at_pos(pos: Vector3): nil | ComputerState
  function ic:get_computer_at_pos(pos)
    local hash = minetest.hash_node_position(pos)

    return self.m_computers[hash]
  end

  ---
  --- Destroys a computer instance, this will also remove any state files.
  ---
  --- @spec #destroy_computer_at_pos(pos: Vector3): Boolean
  function ic:destroy_computer_at_pos(pos)
    print("Destroying Computer", minetest.pos_to_string(pos))
    local hash = minetest.hash_node_position(pos)
    if self.m_computers[hash] then
      self:delete_computer_state_at_pos(pos)
      self.m_computers[hash] = nil
      return true
    else
      return false
    end
  end

  --- @spec #update_computer_at_pos(pos: Vector3, node: NodeRef, secret: String, options: Table): ComputerState
  function ic:update_computer_at_pos(pos, node, secret, options)
    print("Updating Computer", minetest.pos_to_string(pos), node.name)
    local hash = minetest.hash_node_position(pos)
    local computer = self.m_computers[hash]

    if computer then
      computer.node = node
      computer.secret = secret
      -- TODO: maybe update oku state
      return computer
    else
      error("no such computer hash:" .. hash)
    end
    return nil
  end

  ---
  --- Registers a computer (possibly creating a new instance).
  --- This should be used for nodes that are being reloaded.
  ---
  --- @spec #register_computer_at_pos(pos: Vector3, node: NodeRef, secret: String, options: Table): ComputerState
  function ic:register_computer_at_pos(pos, node, secret, options)
    local old_state = self:load_computer_state_at_pos(pos)
    if old_state then
      if old_state.secret == secret then
        local hash = minetest.hash_node_position(pos)
        old_state.id = hash
        self.m_computers[old_state.id] = old_state
        return old_state
      else
        -- warn about a secret mismatch
        print("Secret Mismatch: got ", old_state.secret, "expected ", secret)
        return self:create_computer_at_pos(pos, node, secret, options)
      end
    else
      return self:create_computer_at_pos(pos, node, secret, options)
    end
  end

  --- @spec #upsert_computer_at_pos(pos: Vector3, node: NodeRef, secret: String, options: Table): ComputerState
  function ic:upsert_computer_at_pos(pos, node, secret, options)
    local hash = minetest.hash_node_position(pos)
    if self.m_computers[hash] then
      return self:update_computer_at_pos(pos, node, secret, options)
    else
      return self:register_computer_at_pos(pos, node, secret, options)
    end
  end
end

yatm_oku.Computers = Computers
yatm_oku.computers = Computers:new()
