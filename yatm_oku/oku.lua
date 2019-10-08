--[[
Registers:
x0-x31
pc
]]
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
  union {
    union yatm_oku_register32 x[32];
    struct {
      union yatm_oku_register32 x0;
      union yatm_oku_register32 x1;
      union yatm_oku_register32 x2;
      union yatm_oku_register32 x3;
      union yatm_oku_register32 x4;
      union yatm_oku_register32 x5;
      union yatm_oku_register32 x6;
      union yatm_oku_register32 x7;
      union yatm_oku_register32 x8;
      union yatm_oku_register32 x9;
      union yatm_oku_register32 x10;
      union yatm_oku_register32 x11;
      union yatm_oku_register32 x12;
      union yatm_oku_register32 x13;
      union yatm_oku_register32 x14;
      union yatm_oku_register32 x15;
      union yatm_oku_register32 x16;
      union yatm_oku_register32 x17;
      union yatm_oku_register32 x18;
      union yatm_oku_register32 x19;
      union yatm_oku_register32 x20;
      union yatm_oku_register32 x21;
      union yatm_oku_register32 x22;
      union yatm_oku_register32 x23;
      union yatm_oku_register32 x24;
      union yatm_oku_register32 x25;
      union yatm_oku_register32 x26;
      union yatm_oku_register32 x27;
      union yatm_oku_register32 x28;
      union yatm_oku_register32 x29;
      union yatm_oku_register32 x30;
      union yatm_oku_register32 x31;
    };
  };
  uint32_t pc;
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
    error("requested memory size too larger, cannot exceed 1mb")
  end
end

function ic:initialize(options)
  options = options or {}
  options.memory_size = options.memory_size or 0x40000 --[[ Roughly 1Mb ]]
  check_memory_size(options.memory_size)
  -- the registers
  self.registers = ffi.new("struct yatm_oku_registers32")
  -- utility for decoding instructions
  self.ins = ffi.new("union yatm_oku_rv32i_ins")
  -- memory
  self.memory = yatm_oku.OKU.Memory:new(options.memory_size)
end

function ic:step()
  yatm_oku.OKU.isa.RISCV.step(self)
end

function ic:get_memory_byte(index)
  return self.memory:i8(index)
end

function ic:put_memory_byte(index, value)
  self.memory:w_i8(index, value)
  return self
end

function ic:get_memory_slice(index, len)
  return self.memory:bytes(index, len)
end

function ic:put_memory_slice(index, bytes)
  self.memory:put_bytes(index, bytes)
  return self
end

function ic:upload_memory(blob)
  self.memory:upload(blob)
  return self
end

function ic:load_elf_binary(blob)
  local stream = yatm_core.StringBuf:new(blob)

  local elf_file = yatm_oku.elf:read(stream)
  print("ELF-FILE", dump(elf_file))
end

--
-- Binary Serialization
--

function ic:bindump(stream)
  -- TODO: handle write errors
  local bytes_written = 0
  local bw = ByteBuf.write(stream, "OKU1")
  bytes_written = bytes_written + bw

  local bw = ByteBuf.w_u8string(stream, "rv32i")
  bytes_written = bytes_written + bw

  for i = 0,31 do
    local rv = self.registers.x[i].i32
    local bw = ByteBuf.w_i32(stream, rv)
    bytes_written = bytes_written + bw
  end

  local bw = ByteBuf.w_u32(stream, self.size)
  bytes_written = bytes_written + bw

  local bw = ByteBuf.w_u8bool(stream, true)
  bytes_written = bytes_written + bw

  local bw = self.memory:bindump(stream)
  bytes_written = bytes_written + bw

  return bytes_written
end

function ic:binload(stream)
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

      self.ins = ffi.new("union yatm_oku_rv32i_ins")
      -- time to figure out what the memory size was
      local memory_size, br = ByteBuf.r_u32(stream)
      bytes_read = bytes_read + br
      check_memory_size(memory_size) -- make sure someone isn't trying something funky.
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
    else
      error("unhandled OKU arch " .. arch)
    end
  else
    error("expected an OKU1 state")
  end
  return self, bytes_read
end

function OKU:binload(stream)
  local oku = self:alloc()
  local oku, br = oku:binload(stream)
  return oku, br
end

yatm_oku.OKU = OKU
