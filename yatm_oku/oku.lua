local ByteBuf = yatm_core.ByteBuf

if not ByteBuf then
  yatm.error("yatm_core.ByteBuf is not available, cannot create OKU state")
  return
end

local ffi = assert(yatm_oku.ffi, "oku needs ffi")

yatm_oku.OKU = yatm_core.Class:extends('OKU')
yatm_oku.OKU.isa = {}

dofile(yatm_oku.modpath .. "/lib/oku/token_buffer.lua")
dofile(yatm_oku.modpath .. "/lib/oku/memory.lua")
dofile(yatm_oku.modpath .. "/lib/oku/isa/riscv.lua")
dofile(yatm_oku.modpath .. "/lib/oku/isa/mos_6502.lua")

local OKU = yatm_oku.OKU

OKU.DEFAULT_ARCH = "mos6502"
OKU.AVAILABLE_ARCH = {
  mos6502 = yatm_oku.OKU.isa.MOS6502,
  rv32i = yatm_oku.OKU.isa.RISCV,
  ["8086"] = yatm_oku.OKU.isa.I8086,
}

function OKU:has_arch(arch)
  if OKU.AVAILABLE_ARCH[arch] then
    return true
  end
  return false
end

local ic = OKU.instance_class

local function check_memory_size(memory_size)
  if memory_size < 4 then
    error("requested memory size too small")
  end
  if memory_size > 0x100000 then
    error("requested memory size too large, cannot exceed 1Mb")
  end
end

--
-- Options:
--   arch = "mos6502" | "rv32i"
--   label = String
--   memory_size = Integer
--
function ic:initialize(options)
  options = options or {}

  self.disposed = false
  self.arch = options.arch or OKU.DEFAULT_ARCH
  assert(OKU.AVAILABLE_ARCH[self.arch], "arch=" .. self.arch .. " not available")

  if not options.memory_size then
    if self.arch == "rv32i" or self.arch == "8086" then
      options.memory_size = 0x20000 --[[ Roughly 128Kb ]]
    elseif self.arch == "mos6502" then
      options.memory_size = 0x10000 --[[ Roughly 64Kb ]]
    else
      error("unsupported arch=" .. self.arch)
    end
  end
  check_memory_size(options.memory_size)

  self.label = options.label or ""

  -- memory
  self.memory = yatm_oku.OKU.Memory:new(options.memory_size)

  self.exec_counter = 0

  self.isa_assigns = {}
  self:_init_isa()
end

-- Invokes function on given ARCH module
-- The method must accept the OKU state and ISA assigns as it's first 2 arguments.
--
-- @spec call_arch(method_name: String, ...: [term]) :: term
function ic:call_arch(method_name, ...)
  local mod = OKU.AVAILABLE_ARCH[self.arch]
  if mod then
    return mod[method_name](self, self.isa_assigns, ...)
  else
    error("arch module " .. self.arch .. " is not available")
  end
end

function ic:_init_isa()
  return self:call_arch('init')
end

function ic:dispose()
  self:call_arch('dispose')
  self.memory = nil
  self.disposed = true
end

-- (see Memory:set_circular_access for details)
function ic:set_memory_circular_access(bool)
  self.memory:set_circular_access(bool)
  return self
end

function ic:reset()
  self:call_arch('reset')
  return self
end

function ic:step(steps)
  if self.disposed then
    return 0, "disposed"
  end

  assert(steps, "expected steps to a number")

  for step_i = 1,steps do
    local okay, err
    okay, err = self:call_arch('step')

    if not okay then
      return step_i, err
    end
  end
  return steps, nil
end

for _,key in ipairs({"i8", "i16", "i32", "i64", "u8", "u16", "u32", "u64"}) do
  ic["get_memory_" .. key] = function (self, index)
    return self.memory["r_" .. key](self.memory, index)
  end

  ic["put_memory_" .. key] = function (self, index, value)
    self.memory["w_" .. key](self.memory, index, value)
    return self
  end
end

function ic:clear_memory_slice(index, size)
  self.memory:fill_slice(index, size, 0)
  return self
end

function ic:r_memory_blob(index, size)
  return self.memory:r_blob(index, size)
end

function ic:w_memory_blob(index, bytes)
  assert(index, "expected an index")
  assert(index, "expected a blob")
  self.memory:w_blob(index, bytes)
  return self
end

function ic:fill_memory(value)
  assert(value, "expected a value")
  self.memory:fill(value)
  return self
end

function ic:upload_memory(blob)
  self.memory:upload(blob)
  return self
end

--
-- Binary Serialization
--
function ic:bindump(stream)
  local bytes_written = 0
  -- Write the magic bytes
  local bw, err = ByteBuf.write(stream, "OKU2")
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Write the version
  local bw, err = ByteBuf.w_u32(stream, 2)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Write the label
  assert(self.label, 'label is missing')
  local bw, err = ByteBuf.w_u8string(stream, self.label)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Write the arch
  assert(self.arch, 'arch is missing')
  local bytes_written = 0
  local bw, err = ByteBuf.w_u8string(stream, self.arch)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  local isa = OKU.AVAILABLE_ARCH[self.arch]
  assert(isa, "unsupported arch=" .. self.arch)

  --
  -- Memory
  local bw, err = self:_bindump_memory(stream)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  --
  -- ISA State
  local bw, err = isa.bindump(self, self.isa_assigns, stream)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  return bytes_written, nil
end

function ic:binload(stream)
  self.isa_assigns = {}
  self.exec_counter = 0
  local bytes_read = 0
  -- First thing is to read the magic bytes
  local mahou, br = ByteBuf.read(stream, 4)
  bytes_read = bytes_read + br
  if mahou == "OKU1" then
    -- next we read the arch, normally just rv32i
    local arch, br = ByteBuf.r_u8string(stream)
    bytes_read = bytes_read + br

    self.label = ""

    if arch == "rv32i" then
      self.arch = arch
      bytes_read = bytes_read + self:_binload_arch_rv32i_oku1(stream)
    else
      error("unsupported OKU arch=" .. arch)
    end
  elseif mahou == "OKU2" then
    -- read the version
    local version, br = ByteBuf.r_u32(stream)
    bytes_read = bytes_read + br

    if version == 1 then
      -- read the label
      local label, br = ByteBuf.r_u8string(stream)
      bytes_read = bytes_read + br
      self.label = label or ""

      -- next we read the arch
      local arch, br = ByteBuf.r_u8string(stream)
      bytes_read = bytes_read + br

      self.arch = arch

      -- Reset registers
      local registers = ffi.new("struct yatm_oku_registers32")
      self.isa_assigns.registers = registers

      -- Restore registers
      bytes_read = bytes_read + self:_binload_registers(stream, registers)
      -- Restore memory
      bytes_read = bytes_read + self:_binload_memory(stream)
      -- Restore ISA state
      bytes_read = bytes_read + self:call_arch('binload', stream)
    elseif version == 2 then
      -- read the label
      local label, br = ByteBuf.r_u8string(stream)
      bytes_read = bytes_read + br
      self.label = label or ""

      -- next we read the arch
      local arch, br = ByteBuf.r_u8string(stream)
      bytes_read = bytes_read + br

      self.arch = arch

      -- Restore memory
      bytes_read = bytes_read + self:_binload_memory(stream)
      -- Restore ISA state
      bytes_read = bytes_read + self:call_arch('binload', stream)
    else
      error("invalid version, got=" .. version)
    end
  else
    error("expected an OKU1 state got:" .. dump(mahou))
  end
  return self, bytes_read
end

function OKU:binload(stream)
  local oku = self:alloc()
  local oku, br = oku:binload(stream)
  return oku, br
end

function ic:_bindump_memory(stream)
  local bytes_written = 0
  local bw, err = ByteBuf.w_u32(stream, self.memory:size())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  local bw, err = ByteBuf.w_u8bool(stream, true)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  local bw, err = self.memory:bindump(stream)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  return bytes_written, nil
end

function ic:_binload_registers(stream, registers)
  local bytes_read = 0
  for i = 0,31 do
    local rv, br = ByteBuf.r_i32(stream)
    bytes_read = bytes_read + br
    registers.x[i].i32 = rv
  end
  registers.pc.u32 = ByteBuf.r_u32(stream)
  return bytes_read
end

function ic:_binload_memory(stream)
  local bytes_read = 0
  -- time to figure out what the memory size was
  local memory_size, br = ByteBuf.r_u32(stream)

  bytes_read = bytes_read + br
  check_memory_size(memory_size) -- make sure someone isn't trying something funny.
  self.memory = yatm_oku.OKU.Memory:new(memory_size)

  -- okay, now determine if the memory should be reloaded, or was it volatile
  local has_state, br = ByteBuf.r_u8bool(stream)
  bytes_read = bytes_read + br
  if has_state then
    -- the state was persisted, attempt to reload it
    self.memory:binload(stream)
  else
    -- the state was not persisted, we're done now.
  end
  return bytes_read
end

function ic:_binload_arch_rv32i_oku1(stream)
  local bytes_read = 0

  -- Restore registers
  self.isa_assigns.registers = ffi.new("struct yatm_oku_registers32")
  bytes_read = bytes_read + self:_binload_registers(stream, self.isa_assigns.registers)
  -- Restore memory
  bytes_read = bytes_read + self:_binload_memory(stream)

  return bytes_read
end

yatm_oku.OKU = OKU
