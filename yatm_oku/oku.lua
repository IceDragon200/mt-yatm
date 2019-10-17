--
-- Registers:
--   x0-x31
--   pc
--
local ByteBuf = assert(yatm_core.ByteBuf)

yatm_oku.OKU = yatm_core.Class:extends()
yatm_oku.OKU.isa = {}

dofile(yatm_oku.modpath .. "/lib/oku/memory.lua")

local ffi = assert(yatm_oku.ffi)

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

local OKU = yatm_oku.OKU
local ic = OKU.instance_class

local function check_memory_size(memory_size)
  if memory_size < 4 then
    error("requested memory size too small")
  end
  if memory_size > 0x40000 then
    error("requested memory size too larger, cannot exceed 1Mb")
  end
end

function ic:initialize(options)
  options = options or {}
  options.memory_size = options.memory_size or 0x20000 --[[ Roughly 512Kb ]]
  check_memory_size(options.memory_size)
  -- the registers
  self.registers = ffi.new("struct yatm_oku_registers32")
  -- memory
  self.m_memory = yatm_oku.OKU.Memory:new(options.memory_size)

  self.exec_counter = 0
end

-- Reset the stack pointer to the end of memory
function ic:reset_sp()
  self.registers.x[2].u32 = self.m_memory:size()
end

function ic:step(steps)
  assert(steps, "expected steps to a number")
  for step_i = 1,steps do
    local okay, err = yatm_oku.OKU.isa.RISCV.step(self)
    if not okay then
      return step_i, err
    end
  end
  return steps, nil
end

for _,key in ipairs({"i8", "i16", "i32", "i64", "u8", "u16", "u32", "u64"}) do
  ic["get_memory_" .. key] = function (self, index)
    return self.m_memory["r_" .. key](self.m_memory, index)
  end

  ic["put_memory_" .. key] = function (self, index, value)
    self.m_memory["w_" .. key](self.m_memory, index, value)
    return self
  end
end

function ic:clear_memory_slice(index, size)
  self.m_memory:fill_slice(index, size, 0)
  return self
end

function ic:r_memory_blob(index, size)
  return self.m_memory:r_blob(index, size)
end

function ic:w_memory_blob(index, bytes)
  assert(index, "expected an index")
  assert(index, "expected a blob")
  self.m_memory:w_blob(index, bytes)
  return self
end

function ic:upload_memory(blob)
  self.m_memory:upload(blob)
  return self
end

function ic:load_elf_binary(blob)
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
  local bw, err = ByteBuf.write(stream, "OKU1")
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  local bw, err = ByteBuf.w_u8string(stream, "rv32i")
  bytes_written = bytes_written + bw

  if err then
    return bytes_written, err
  end

  --
  -- Registers
  for i = 0,31 do
    local rv = self.registers.x[i].i32
    local bw, err = ByteBuf.w_i32(stream, rv)
    bytes_written = bytes_written + bw

    if err then
      return bytes_written, err
    end
  end

  local bw = ByteBuf.w_u32(stream, self.registers.pc.u32)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  --
  -- Memory
  local bw = ByteBuf.w_u32(stream, self.m_memory:size())
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  local bw = ByteBuf.w_u8bool(stream, true)
  bytes_written = bytes_written + bw
  if err then
    return bytes_written, err
  end

  local bw = self.m_memory:bindump(stream)
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
    if arch == "rv32i" then
      -- reinitialize a RISCV-32I machine
      self.registers = ffi.new("struct yatm_oku_registers32")
      -- Restore registers
      for i = 0,31 do
        local rv, br = ByteBuf.r_i32(stream)
        bytes_read = bytes_read + br
        self.registers.x[i].i32 = rv
      end
      self.registers.pc.u32 = ByteBuf.r_u32(stream)

      -- time to figure out what the memory size was
      local memory_size, br = ByteBuf.r_u32(stream)

      bytes_read = bytes_read + br
      check_memory_size(memory_size) -- make sure someone isn't trying something funny.
      self.m_memory = yatm_oku.OKU.Memory:new(memory_size)

      -- okay, now determine if the memory should be reloaded, or was it volatile
      local has_state, br = ByteBuf.r_u8bool(stream)
      bytes_read = bytes_read + br
      if has_state then
        -- the state was persisted, attempt to reload it
        self.m_memory:binload(stream)
      else
        -- the state was not persisted, we're done now.
      end
    else
      error("unhandled OKU arch got:" .. arch)
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

yatm_oku.OKU = OKU
