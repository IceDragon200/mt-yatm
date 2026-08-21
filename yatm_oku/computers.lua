--
-- Computers service, allows registering computers
--
local assertions = assert(foundation.com.assertions)
local HEX_UENC = assert(foundation.com.HEX_UPPERCASE_ENCODE_TABLE)
local OKU = assert(yatm_oku.OKU)
local BB_LE = assert(foundation.com.ByteBuf.LE)
local BinSchema = assert(foundation.com.BinSchema)
local path_join = assert(foundation.com.path_join)
local table_copy = assert(foundation.com.table_copy)
local Trace = foundation.com.Trace
local Vector3 = assert(foundation.com.Vector3)
local format = assert(string.format)
local string_byte = assert(string.byte)
local floor = assert(math.floor)
local concat = assert(table.concat)

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

--- Since 2026-08-20
local ComputerStateHeaderSchemaV3 =
  BinSchema:new("ComputerStateHeaderV3", {
    --
    {"id", "u8string"},
    {"label", "u8string"},
    --
    {"active", "i32"},
    {"type", "i32"},
    {"secret", "u8string"},
    -- Just hash these to get the id again if needed
    {"x", "i32"},
    {"y", "i32"},
    {"z", "i32"},
    --
    {"node_name", "u8string"},
    {"node_param1", "i32"},
    {"node_param2", "i32"},
    -- Whether or not this is a shallow header, shallow simply means the machine state
    -- is not included in the stream.
    {"shallow", "i32"},
    -- Here would be the oku state, but OKU handles its own serialization.
  })

local secrand = SecureRandom()

--- @class Computers
local Computers = foundation.com.Class:extends("ComputersService")
Computers.TYPE_DETACHED = 0
Computers.TYPE_FIXED = 1
do
  local ic = assert(Computers.instance_class)

  --- @override
  --- @spec #initialize(options: Table): void
  function ic:initialize(options)
    options = options or {}
    ic._super.initialize(self)

    --- @member m_root_dir: Path
    self.m_root_dir = options.root_dir or false

    --- @member m_fixed_computers: { [hash: Number]: ID }
    self.m_fixed_computers = {}

    --- @member m_computers: { [id: Any]: ComputerState }
    self.m_computers = {}

    if self.m_root_dir then
      core.mkdir(self.m_root_dir)
    end
  end

  local function id_to_basename(id)
    return format("computer-fixed-%s.bin", id)
  end

  local function pos_to_basename(pos)
    return format("computer-%08x.bin", core.hash_node_position(pos))
  end

  --- Generates a new random ID for use with computers.
  --- @spec #generate_id(): String
  function ic:generate_id()
    local raw = secrand:next_bytes(16)
    local result = {"~"}
    local b
    local hi
    local lo
    for i = 1,16 do
      b = string_byte(raw, i)
      lo = b % 16
      hi = floor(b / 16)
      result[i * 2] =  HEX_UENC[hi]
      result[i * 2 + 1] =  HEX_UENC[lo]
    end
    return concat(result)
  end

  --- @spec #next_unused_id(attempts: Integer = 100): String
  function ic:next_unused_id(attempts)
    local id
    attempts = attempts or 100
    while not id do
      id = self:generate_id()
      if self.m_computers[id] then
        id = nil
        attempts = attempts - 1
      end
      if attempts <= 0 then
        error("could not generate a unique id")
      end
    end
    return id
  end

  ---
  --- Should be called by the core startup to do stuff.
  ---
  --- @spec #setup(): void
  function ic:setup()
    --
  end

  local function make_label(pos, node)
    return "computer-" .. node.name .. "-" .. core.pos_to_string(pos)
  end

  --- @spec #terminate(): void
  function ic:terminate()
    core.log("debug", "yatm.computers is terminating")
    -- Persist all active computer states
    self:persist_computer_states()
    -- release all the computers
    self.m_fixed_computers = {}
    self.m_computers = {}
    core.log("debug", "yatm.computers has terminated")
  end

  --- @spec #update(dt: Float, trace: Trace): void
  function ic:update(dt, trace)
    --
    local steps_taken
    local err
    local clock_speed = floor(dt * 1000)
    local span
    for _id, computer in pairs(self.m_computers) do
      if trace then
        span = trace:span_start(computer.label)
      end

      if computer.active > 0 then
        steps_taken, err = computer.oku:step(clock_speed)
        -- print("STEPS", computer.label, steps_taken, err)
      end

      if trace then
        span:span_end()
      end
    end
  end

  ---
  --- Creates a brand spanking new instance of a computer!
  ---
  --- Options:
  ---   See OKU:new() for details
  ---
  --- @spec #create_computer(
  ---   secret: String,
  ---   options: Table
  --- ): ComputerState | nil
  function ic:create_computer(secret, options)
    assertions.is_string(secret)
    assertions.is_table(options)
    local id = self:generate_id()
    local computer = {
      id = id,
      type = Computers.TYPE_DETACHED,
      secret = secret,
      active = 0,
      label = "",
      oku = OKU:new(options)
    }
    self.m_computers[computer.id] = computer
    return computer
  end

  ---
  --- Creates a brand spanking new instance of a computer at specified position with node.
  ---
  --- Options:
  ---   See OKU:new() for details
  --- @spec #create_computer(
  ---   secret: String,
  ---   options: Table
  --- ): ComputerState | nil
  function ic:create_computer_at_pos(pos, node, secret, options)
    local hash = core.hash_node_position(pos)
    local id = self.m_fixed_computers[hash]
    if id then
      core.log("error", "a computer already exists hash=" .. hash)
      return nil
    else
      local computer = self:create_computer(secret, options)
      computer.type = Computers.TYPE_DETACHED
      computer.pos = vector.copy(pos)
      computer.hash = hash
      computer.node = table_copy(node)
      computer.label = make_label(pos, node)
      self.m_fixed_computers[hash] = id
      return computer
    end
  end

  ---
  --- Registers or reloads a computer by its ID, if nil is given as the id, it will act like
  --- #create_computer/2.
  ---
  --- @spec #register_computer(
  ---   id?: ID,
  ---   secret: String,
  ---   options: Table
  --- ): ComputerState
  function ic:register_computer(id, secret, options)
    if id then
      local state = self:load_computer_state_by_id(id)
      if state then
        if state.secret == secret then
          self.m_computers[id] = state
          if state.type == Computers.TYPE_FIXED then
            self.m_fixed_computers[state.hash] = id
          end
          return state
        end
      end
    end
    return self:create_computer(secret, options)
  end

  ---
  --- Registers a computer (possibly creating a new instance).
  --- This should be used for nodes that are being reloaded.
  ---
  --- @spec #register_computer_at_pos(
  ---   pos: Vector3,
  ---   node: NodeRef,
  ---   secret: String,
  ---   options: Table
  --- ): ComputerState
  function ic:register_computer_at_pos(pos, node, secret, options)
    local state = self:load_computer_state_at_pos(pos)
    if state then
      if state.secret == secret then
        local hash = core.hash_node_position(pos)
        state.hash = hash
        local id = state.id
        if not id then
          id = self:next_unused_id()
          state.id = id
        end
        self.m_computers[id] = state
        self.m_fixed_computers[state.hash] = id
        return state
      else
        -- warn about a secret mismatch
        core.log("warning", "Secret Mismatch: got " .. state.secret .. "expected " .. secret)
        return self:create_computer_at_pos(pos, node, secret, options)
      end
    else
      return self:create_computer_at_pos(pos, node, secret, options)
    end
  end

  --- @spec #update_computer(id: ID, secret: String, options: Table): nil | ComputerState
  function ic:update_computer(id, secret, options)
    local computer = self.m_computers[id]

    if computer then
      computer.secret = secret
      -- TODO: maybe update oku state
      return computer
    end
    return nil
  end

  --- @spec #update_computer_at_pos(
  ---   pos: Vector3,
  ---   node: NodeRef,
  ---   secret: String,
  ---   options: Table
  --- ): nil | ComputerState
  function ic:update_computer_at_pos(pos, node, secret, options)
    core.log("debug", "Updating Computer" .. core.pos_to_string(pos) .. " " .. node.name)
    local hash = core.hash_node_position(pos)
    local id = self.m_fixed_computers[hash]
    if id then
      local computer = self:update_computer(id, secret, options)
      if computer then
        computer.node = table_copy(node)
        return computer
      end
    end
    return nil
  end

  --- @spec #upsert_computer(
  ---   id: ID,
  ---   secret: String,
  ---   options: Table
  --- ): ComputerState
  function ic:upsert_computer(id, secret, options)
    if self.m_computers[id] then
      return self:update_computer(id, secret, options)
    else
      return self:register_computer_at_pos(id, secret, options)
    end
  end

  --- @spec #upsert_computer_at_pos(
  ---   pos: Vector3,
  ---   node: NodeRef,
  ---   secret: String,
  ---   options: Table
  --- ): ComputerState
  function ic:upsert_computer_at_pos(pos, node, secret, options)
    local hash = core.hash_node_position(pos)
    if self.m_fixed_computers[hash] then
      return self:update_computer_at_pos(pos, node, secret, options)
    else
      return self:register_computer_at_pos(pos, node, secret, options)
    end
  end

  ---
  --- Destroys a computer instance, this will also remove any state files.
  ---
  --- @spec #destroy_computer(id: ID): Boolean
  function ic:destroy_computer(id)
    core.log("warning", "Destroying Computer " .. id)
    local state = self.m_computers[hash]
    if state then
      self:delete_computer_state_by_id(id)
      if state.hash then
        self.m_fixed_computers[state.hash] = nil
      end
      self.m_computers[id] = nil
      return true
    else
      return false
    end
  end

  ---
  --- Destroys a computer instance at position, this will also remove any state files.
  ---
  --- @spec #destroy_computer_at_pos(pos: Vector3): Boolean
  function ic:destroy_computer_at_pos(pos)
    core.log("warning", "Destroying Computer @" .. core.pos_to_string(pos))
    local hash = core.hash_node_position(pos)
    local id = self.m_fixed_computers[hash]
    if id then
      return self:destroy_computer(id)
    end
    return false
  end

  --- Retrieve a computer by its ID.
  --- @spec #get_computer(id: ID): nil | ComputerState
  function ic:get_computer(id)
    return self.m_computers[id]
  end

  ---
  --- Retrieve a computer entry.
  ---
  --- For the love of god, don't do anything funky with it!
  ---
  --- @spec #get_computer_at_pos(pos: Vector3): nil | ComputerState
  function ic:get_computer_at_pos(pos)
    local hash = core.hash_node_position(pos)
    local id = self.m_fixed_computers[hash]
    if id then
      return self.m_computers[id]
    end
    return nil
  end

  --- Load a computer from disk by its ID.
  ---
  --- @spec #load_computer_state_by_id(id: ID, trace: Trace): (ComputerState | nil, Error)
  function ic:load_computer_state_by_id(id, trace)
    if self.m_root_dir then
      local basename = id_to_basename(id)
      local filename = path_join(self.m_root_dir, basename)

      return self:load_computer_from_file(filename, trace)
    end
    return nil, "no root dir"
  end

  --- Attempts to load a computer based on its pos in the world, this may load two states,
  --- once for shallow header and then again for the actual computer.
  --- Shallow loads only happen with V3 and later, V2 and earlier machines will return as-is.
  ---
  --- @spec #load_computer_state_at_pos(pos: Vector3, trace: Trace): (ComputerState | nil, Error)
  function ic:load_computer_state_at_pos(pos, trace)
    if self.m_root_dir then
      local basename = pos_to_basename(pos)
      local filename = path_join(self.m_root_dir, basename)

      local state, err = self:load_computer_from_file(filename, trace)
      if err then
        return nil, err
      end
      if state.oku then
        return state
      end

      -- the state was shallow, we'll need to load the actual computer by its ID instead.
      return self:load_computer_state_by_id(state.id, trace)
    end
    return nil, "no root dir"
  end

  --- @spec #load_computer_from_file(filename: Path, trace?: Trace): (ComputerState, nil) | (nil, Error)
  function ic:load_computer_from_file(filename, trace)
    local span
    local func_trace
    if trace then
      span = trace:span_start('load_computer_from_file:' .. filename)
    end
    if span then
      func_trace = span:span_start("io.open")
    end
    local file = io.open(filename, "r")
    if func_trace then
      func_trace:span_end()
    end

    if file then
      if span then
        func_trace = span:span_start('file#read')
      end
      local blob = file:read('*all')
      file:close()
      local stream = Buffer:new(blob, 'r')
      if func_trace then
        func_trace:span_end()
      end

      if span then
        func_trace = span:span_start('state-load')
      end
      -- Read the state header
      local base
      local state
      local br
      base, br = ComputerStateHeaderBaseSchema:read(BB_LE, stream, {})

      if base.version == 1 then
        state, br = ComputerStateHeaderSchemaV1:read(BB_LE, stream, {})
        state.type = Computers.TYPE_FIXED
        state.shallow = 0
      elseif base.version == 2 then
        state, br = ComputerStateHeaderSchemaV2:read(BB_LE, stream, {})
        state.type = Computers.TYPE_FIXED
        state.shallow = 0
      elseif base.version == 3 then
        state, br = ComputerStateHeaderSchemaV3:read(BB_LE, stream, {})
      else
        error("unexpected version")
      end

      -- Let OKU read the rest
      local oku
      if state.shallow == 0 then
        oku, br = OKU:binload(stream)
      end

      stream:close()

      if func_trace then
        func_trace:span_end() -- close state-load
      end

      local state_pos
      local node
      local hash
      local label = state.label
      if state.type == Computers.TYPE_FIXED then
        state_pos = vector.new(state.x, state.y, state.z)
        node = {
          name = state.node_name,
          param1 = state.node_param1,
          param2 = state.node_param2,
        }
        hash = core.hash_node_position(state_pos)
        if not label or #label == 0 then
          label = make_label(state_pos, node)
        end
      end
      if span then
        span:span_end() -- close span
      end

      return {
        id = state.id,
        type = state.type,
        pos = state_pos,
        hash = hash,
        node = node,
        secret = state.secret,
        active = state.active or 1,
        label = label,
        oku = oku
      }, nil
    else
      return nil, "file cannot be opened"
    end
  end

  --- Dumps a computer's state table to disk, FIXED type computers will dump its fixed state (shallow)
  --- and then its actual computer state, creating 2 files, otherwise only 1 file is created.
  ---
  --- @spec #save_computer_state(ComputerState, Trace): (bytes_written: Integer, error: Error)
  function ic:save_computer_state(state, trace)
    if not self.m_root_dir then
      return 0, "no root dir"
    end
    core.log("debug", "Saving Computer State " .. core.pos_to_string(state.id))
    local basename
    local fixed_filename
    if state.type == Computers.TYPE_FIXED then
      basename = pos_to_basename(state.pos)
      fixed_filename = path_join(self.m_root_dir, basename)
    end
    basename = id_to_basename(state.id)
    local filename = path_join(self.m_root_dir, basename)

    local span
    local func_trace
    if trace then
      span = trace:span_start('save_computer_state/' .. filename)
    end
    if span then
      func_trace = span:span_start("dump")
    end

    local bytes_written = 0
    local bw
    local err
    local is_shallow = false

    if state.type == Computers.TYPE_FIXED then
      is_shallow = true
    end

    local header = {
      id = state.id,
      label = state.label or "",
      active = state.active,
      secret = state.secret,
      type = state.type,

      x = 0,
      y = 0,
      z = 0,

      node_name = "",
      node_param1 = 0,
      node_param2 = 0,

      shallow = 0,
    }
    if state.pos then
      header.x = state.pos.x
      header.y = state.pos.y
      header.z = state.pos.z
    end

    if state.node then
      heder.node_name = state.node.name
      heder.node_param1 = state.node.param1
      heder.node_param2 = state.node.param2
    end

  ::dump_state::
    if is_shallow then
      header.shallow = 1
    else
      header.shallow = 0
    end

    local stream = Buffer:new('', 'w')
    bw, err =
      ComputerStateHeaderBaseSchema:write(BB_LE, stream, {
        magic = "OCS1",
        version = 3,
      })
    bytes_written = bytes_written + bw

    if err then
      stream:close()
      return bytes_written, "error while writing header " .. err
    end

    bw, err = ComputerStateHeaderSchemaV3:write(BB_LE, stream, header)
    bytes_written = bytes_written + bw

    if err then
      stream:close()
      return bytes_written, "error while writing header " .. err
    end

    if is_shallow then
      bw, err = state.oku:bindump(stream)
      bytes_written = bytes_written + bw
    end

    if func_trace then
      func_trace:span_end()
      func_trace = nil
    end

    if err then
      stream:close()
      return bytes_written, "error while writing oku state " .. err
    end

    stream:close()

    if span then
      func_trace = span:span_start("safe_file_write:is_shallow=" .. is_shallow)
    end
    if is_shallow then
      core.safe_file_write(assert(fixed_filename, "expected fixed filename"), stream:blob())
    else
      core.safe_file_write(filename, stream:blob())
    end
    if func_trace then
      func_trace:span_end()
      func_trace = nil
    end

    if is_shallow then
      -- if we've built the shallow state, then we need to buld the full state next
      is_shallow = false
      goto dump_state
    end

    if span then
      span:span_end()
    end

    return bytes_written, nil
  end

  --- Deletes a computer's state files by its ID, this leaves the computer in memory however.
  --- @spec #delete_computer_state_by_id(id: ID): (Boolean, Integer)
  function ic:delete_computer_state_by_id(id)
    if not self.m_root_dir then
      return false, 0
    end

    local state = self.m_computers[id]
    if state then
      local count = 0
      local fixed_filename
      local basename
      if state.type == Computers.TYPE_FIXED then
        basename = pos_to_basename(state.pos)
        fixed_filename = path_join(self.m_root_dir, basename)
      end
      basename = pos_to_basename(pos)
      local filename = path_join(self.m_root_dir, basename)

      local file
      if fixed_filename then
        file = io.open(fixed_filename, "r")
        if file then
          file:close()
          os.remove(fixed_filename)
          count = count + 1
        end
      end

      file = io.open(filename, "r")
      if file then
        file:close()
        os.remove(filename)
        count = count + 1
      end

      return true, count
    end
    return false, count
  end

  --- Deletes a computer's state files given its position in the world.
  --- The computer MUST be loaded in the world to remove its state files if any.
  --- Since V3, FIXED position computers (the original default) have 2 files instead of 1.
  ---
  --- @spec #delete_computer_state_at_pos(pos: Vector3): Boolean
  function ic:delete_computer_state_at_pos(pos)
    local hash = core.hash_node_position(pos)
    local id = self.m_fixed_computers[hash]
    if id then
      return self:delete_computer_state_by_id(id)
    end
    return false, 0
  end

  --- @spec #persist_computer_states(trace: Trace): void
  function ic:persist_computer_states(trace)
    local span
    if trace then
      span = trace:span_start('persist_computer_states')
    end
    for _id,state in pairs(self.m_computers) do
      self:save_computer_state(state, trace)
    end
    if span then
      span:span_end()
    end
  end
end

yatm_oku.Computers = Computers
