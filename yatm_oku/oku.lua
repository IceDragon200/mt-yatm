--
-- Registers:
--   x0-x31
--   pc
--
local ByteBuf = yatm_core.ByteBuf

if not ByteBuf then
  yatm.error("yatm_core.ByteBuf is not available, cannot create OKU state")
  return
end

yatm_oku.OKU = yatm_core.Class:extends()
yatm_oku.OKU.isa = {}

dofile(yatm_oku.modpath .. "/lib/oku/memory.lua")

local ffi = assert(yatm_oku.ffi, "oku needs ffi")

ffi.cdef[[
union yatm_oku_register32 {
  int8_t   i8v[4];
  uint8_t  u8v[4];
  int16_t  i16v[2];
  uint16_t u16v[2];
  int32_t  i32v[1];
  uint32_t u32v[1];
  float    fv[1];
  int32_t  i32;
  uint32_t u32;
  float    f32;
};
]]

ffi.cdef[[
struct yatm_oku_registers32 {
  union yatm_oku_register32 x[32];
  union yatm_oku_register32 pc;
};
]]

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
  if memory_size > 0x40000 then
    error("requested memory size too larger, cannot exceed 1Mb")
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

  -- the registers
  self.registers = ffi.new("struct yatm_oku_registers32")

  -- memory
  self.memory = yatm_oku.OKU.Memory:new(options.memory_size)

  self.exec_counter = 0

  self.isa_assigns = {}
  self:_init_isa()
end

function ic:_init_isa()
  OKU.AVAILABLE_ARCH[self.arch].init(self, self.isa_assigns)
end

function ic:dispose()
  OKU.AVAILABLE_ARCH[self.arch].dispose(self, self.isa_assigns)

  self.memory = nil
  self.registers = nil

  self.disposed = true
end

-- (see Memory:set_circular_access for details)
function ic:set_memory_circular_access(bool)
  self.memory:set_circular_access(bool)
  return self
end

-- Reset the stack pointer to the end of memory
function ic:reset_sp()
  self.registers.x[2].u32 = self.memory:size()
end

function ic:reset()
  local isa = OKU.AVAILABLE_ARCH[self.arch]
  isa.reset(self, self.isa_assigns)
  return self
end

function ic:step(steps)
  if self.disposed then
    return 0, "disposed"
  end

  assert(steps, "expected steps to a number")

  for step_i = 1,steps do
    local isa = OKU.AVAILABLE_ARCH[self.arch]
    local okay, err
    if isa then
      okay, err = isa.step(self, self.isa_assigns)
    else
      error("unsupported arch=" .. self.arch)
    end
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

-- Honestly only usable with the RV32i
function ic:load_elf_binary(blob)
  if self.arch ~= "rv32i" then
    error("cannot load elf binaries in non-rv32i arch")
  end
  local stream = yatm_core.StringBuf:new(blob)

  local elf_prog = yatm_oku.elf:read(stream)

  elf_prog:reduce_segments(nil, function (segment, _unused)
    if segment.header.type == "PT_LOAD" then
      --print(dump(segment))
      self:clear_memory_slice(segment.header.vaddr, segment.header.memsz)
      self:w_memory_blob(segment.header.vaddr, segment.blob)
    end
  end)

  self.registers.pc.u32 = elf_prog:get_entry_vaddr()

  --print(elf_prog:inspect())

  return self
end

--
-- Binary Serialization
--
function ic:bindump(stream)
  local bytes_written = 0
  local bw, err = ByteBuf.write(stream, "OKU2")
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  -- Write the version
  local bw, err = ByteBuf.w_u32(stream, 1)
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
  -- Registers
  local bw, err = self:_bindump_registers(stream)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  --
  -- Memory
  local bw, err = self:_bindump_memory(stream)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  --
  -- ISA State
  local bw, err = isa.bindump(self, stream, self.isa_assigns)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  return bytes_written, nil
end

function ic:binload(stream)
  self.exec_counter = 0
  local bytes_read = 0
  -- First thing is to read the magic bytes
  local mahou, br = ByteBuf.read(stream, 4)
  bytes_read = bytes_read + br
  if mahou == "OKU1" then
    -- next we read the arch, normally just rv32i
    local arch, br = ByteBuf.r_u8string(stream)
    bytes_read = bytes_read + br

    -- Reset registers
    self.registers = ffi.new("struct yatm_oku_registers32")

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

      -- next we read the arch, normally just rv32i
      local arch, br = ByteBuf.r_u8string(stream)
      bytes_read = bytes_read + br

      self.arch = arch

      -- Reset registers
      self.registers = ffi.new("struct yatm_oku_registers32")

      local isa = OKU.AVAILABLE_ARCH[self.arch]
      if isa then
        -- Restore registers
        bytes_read = bytes_read + self:_binload_registers(stream)
        -- Restore memory
        bytes_read = bytes_read + self:_binload_memory(stream)
        -- Restore ISA state
        bytes_read = bytes_read + isa.binload(self, stream, self.isa_assigns)
      else
        error("unsupported OKU arch=" .. arch)
      end
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

function ic:_bindump_registers(stream)
  local bytes_written = 0

  for i = 0,31 do
    local rv = self.registers.x[i].i32
    local bw, err = ByteBuf.w_i32(stream, rv)
    bytes_written = bytes_written + bw

    if err then
      return bytes_written, err
    end
  end

  local bw, err = ByteBuf.w_u32(stream, self.registers.pc.u32)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end
  return bytes_written, nil
end

function ic:_binload_registers(stream)
  local bytes_read = 0
  for i = 0,31 do
    local rv, br = ByteBuf.r_i32(stream)
    bytes_read = bytes_read + br
    self.registers.x[i].i32 = rv
  end
  self.registers.pc.u32 = ByteBuf.r_u32(stream)
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
  bytes_read = bytes_read + self:_binload_registers(stream)
  -- Restore memory
  bytes_read = bytes_read + self:_binload_memory(stream)

  return bytes_read
end

yatm_oku.OKU = OKU
