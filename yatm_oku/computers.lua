--
--
--
local OKU = yatm_oku.OKU
if not OKU then
  yatm.error("Cannot create computer service, OKU not available!?")
  return
end

local BinSchema = yatm_core.BinSchema

if not BinSchema then
  yatm.error("computers service not available, yatm_core.BinSchema is unavailable")
  return
end

-- Pick a buffer module, prefer binary or string, as it's faster
local Buffer = yatm_core.BinaryBuffer or yatm_core.StringBuf

local Computers = yatm_core.Class:extends()
local ic = assert(Computers.instance_class)

--
-- This is the header of the computer state file, since OKU
-- Handles the actual machine state, it's not included here.
-- Doesn't help that the format is variable depending on the size and type.
--
local ComputerStateHeaderSchema =
  BinSchema:new("ComputerStateHeader", {
    {"magic", yatm_core.binary_types.Bytes:new(4)},
    --
    {"version", "i32"},
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

function ic:initialize()
  self.m_root_dir = yatm_core.path_join(minetest.get_worldpath(), "/yatm/oku")
  minetest.mkdir(self.m_root_dir)
  self.m_computers = {}
end

local function pos_to_basename(pos)
  return string.format("computer-%08x", minetest.hash_node_position(pos)) .. ".bin"
end

--
-- Should be called by the minetest startup to do stuff.
--
function ic:setup()
  --
end

--
--
-- @spec load_computer_state(Vector) :: {ComputerState | nil, error}
function ic:load_computer_state(pos)
  local basename = pos_to_basename(pos)
  local filename = yatm_core.path_join(self.m_root_dir, basename)

  local trace = yatm_core.trace.new('load_computer_state/' .. minetest.pos_to_string(pos))
  local file = io.open(filename, "r")
  if file then
    local ot = yatm_core.trace.span_start(trace, 'read-binary')
    local stream = Buffer:new(file:read('*all'), 'r')
    file:close()
    yatm_core.trace.span_end(ot)

    local ot = yatm_core.trace.span_start(trace, 'decode-stream')
    -- FIXME: This entire section should be wrapped in a protected call
    --        and the file closed properly.
    -- Read the state header
    local state, _bytes_read =
      ComputerStateHeaderSchema:read(stream, {})

    -- Let OKU read the rest
    local oku, br = OKU:binload(stream)

    stream:close()
    yatm_core.trace.span_end(ot)
    yatm_core.trace.span_end(trace)
    yatm_core.trace.inspect(trace)

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

      oku = oku
    }, nil
  else
    return nil, "file cannot be opened"
  end
end

--
-- @spec save_computer_state(ComputerState) :: {bytes_written :: non_neg_integer, error}
function ic:save_computer_state(state, parent_trace)
  print("Saving Computer State", minetest.pos_to_string(state.pos))
  local basename = pos_to_basename(state.pos)
  local filename = yatm_core.path_join(self.m_root_dir, basename)

  local ot
  if parent_trace then
    ot = yatm_core.trace.span_start(parent_trace, 'save_computer_state/' .. minetest.pos_to_string(state.pos))
  else
    ot = yatm_core.trace.new('save_computer_state/' .. minetest.pos_to_string(state.pos))
  end
  local stream = Buffer:new('', 'w')

  local bytes_written = 0
  local bw, err =
    ComputerStateHeaderSchema:write(stream, {
      magic = "OCS1",

      version = 1,
      secret = state.secret,

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

  local bw, err = state.oku:bindump(stream)
  bytes_written = bytes_written + bw

  if err then
    stream:close()
    return bytes_written, "error while writing oku state " .. err
  end

  stream:close()

  minetest.safe_file_write(filename, stream:blob())
  yatm_core.trace.span_end(ot)
  if not parent_trace then
    yatm_core.trace.inspect(ot)
  end
  return bytes_written, nil
end

--
-- @spec delete_computer_state(Vector) :: boolean
function ic:delete_computer_state(pos)
  local basename = pos_to_basename(pos)
  local filename = yatm_core.path_join(self.m_root_dir, basename)

  local file = io.open(filename, "r")
  if file then
    file:close()
    os.remove(filename)
    return true
  else
    return false
  end
end

function ic:persist_computer_states()
  local ot = yatm_core.trace.new('persist_computer_states')
  for _hash,state in pairs(self.m_computers) do
    self:save_computer_state(state, ot)
  end
  yatm_core.trace.span_end(ot)
  yatm_core.trace.inspect(ot)
end

function ic:terminate()
  print("yatm.computers", "terminating")
  -- Persist all active computer states
  self:persist_computer_states()
  -- release all the computers
  self.m_computers = {}
  print("yatm.computers", "terminated")
end

function ic:update(dt)
  local ot = yatm_core.trace.new("oku_computers_update")
  --
  local clock_speed = math.floor(dt * 1000)
  for _, computer in pairs(self.m_computers) do
    local ct = yatm_core.trace.span_start(ot, "computer-" .. computer.node.name .. "-" .. minetest.pos_to_string(computer.pos))
    --local steps_taken, err = computer.oku:step(clock_speed)
    --print("STEPS", ct.name, steps_taken, err)
    yatm_core.trace.span_end(ct)
  end
  yatm_core.trace.span_end(ot)
  --yatm_core.trace.inspect(ot)
end

--
-- Creates a brand spanking new instance of a computer
--
-- Options:
--   See OKU:new() for details
function ic:create_computer(pos, node, secret, options)
  assert(type(secret) == "string", "expected secret to be a string got:" .. type(secret))
  assert(type(options) == "table", "expected an options table got:" .. type(options))
  local hash = minetest.hash_node_position(pos)
  if self.m_computers[hash] then
    error("a computer already exists hash=" .. hash)
  else
    self.m_computers[hash] = {
      id = hash,
      pos = pos,
      node = node,
      secret = secret,

      oku = OKU:new(options)
    }
  end

  return self
end

--
-- Retrieve a computer entry.
--
-- For the love of god, don't do anything funky with it!
function ic:get_computer(pos, node)
  local hash = minetest.hash_node_position(pos)

  return self.m_computers[hash]
end

--
-- Destroys a computer instance, this will also remove any state files.
--
function ic:destroy_computer(pos, node)
  print("Destroying Computer", minetest.pos_to_string(pos), node.name)
  local hash = minetest.hash_node_position(pos)
  if self.m_computers[hash] then
    self:delete_computer_state(pos)
    self.m_computers[hash] = nil
    return true
  else
    return false
  end
end

function ic:update_computer(pos, node, secret, options)
  print("Updating Computer", minetest.pos_to_string(pos), node.name)
  local hash = minetest.hash_node_position(pos)
  local computer = self.m_computers[hash]

  if computer then
    computer.node = node
    computer.secret = secret
    -- TODO: maybe update oku state
  else
    error("no such computer hash:" .. hash)
  end
end

--
-- Registers a computer (possibly creating a new instance).
-- This should be used for nodes that are being reloaded.
--
function ic:register_computer(pos, node, secret, options)
  local old_state = self:load_computer_state(pos)
  if old_state then
    if old_state.secret == secret then
      local hash = minetest.hash_node_position(pos)
      old_state.id = hash
      self.m_computers[old_state.id] = old_state
    else
      -- warn about a secret mismatch
      print("Secret Mismatch: got ", old_state.secret, "expected ", secret)
      self:create_computer(pos, node, secret, options)
    end
  else
    self:create_computer(pos, node, secret, options)
  end
  return self
end

function ic:upsert_computer(pos, node, secret, options)
  local hash = minetest.hash_node_position(pos)
  if self.m_computers[hash] then
    return self:update_computer(pos, node, secret, options)
  else
    return self:register_computer(pos, node, secret, options)
  end
end

yatm_oku.Computers = Computers
yatm_oku.computers = Computers:new()
