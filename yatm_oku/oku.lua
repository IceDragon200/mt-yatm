--- @namespace yatm_oku
local BB_LE = assert(foundation.com.ByteBuf.LE)

local ffi = yatm_oku.ffi
if not ffi then
  core.log("warn", "OKU requires ffi for some components, trying to initialize anyway")
end

--- @class OKU
yatm_oku.OKU = foundation.com.Class:extends('OKU')
yatm_oku.OKU.isa = {}

yatm_oku:require("lib/oku/registers.lua")
yatm_oku:require("lib/oku/token_buffer.lua")
yatm_oku:require("lib/oku/memory.lua")
yatm_oku:require("lib/oku/isa/actu8.lua")

local OKU = yatm_oku.OKU
local Memory = OKU.Memory

--- @const DEFAULT_ARCH: String = "actu8"
OKU.DEFAULT_ARCH = "actu8"

--- @const AVAILABLE_ARCH: { [String]: Any }
do
  local archs = {
    ["actu8"] = {
      engine = yatm_oku.OKU.isa.ACTU8,
      default_memory_size = 0x800, -- Roughly 2Kb
    },
  }
  OKU.AVAILABLE_ARCH = {}

  for key, value in pairs(archs) do
    if value.engine then
      OKU.AVAILABLE_ARCH[key] = value
    end
  end
  archs = nil
end

OKU.ERR_OK = 0
OKU.ERR_DISPOSED = 1
OKU.ERR_NO_MEMORY = 2

--- Determines if a specified architecture is available
---
--- @spec &has_arch(arch: String): Boolean
function OKU:has_arch(arch)
  if OKU.AVAILABLE_ARCH[arch] ~= nil then
    return true
  end
  return false
end

do
  local ic = OKU.instance_class

  local function check_memory_size(memory_size)
    if memory_size < 4 then
      error("requested memory size too small")
    end
    if memory_size > 0x100000 then
      error("requested memory size too large, cannot exceed 1Mb")
    end
  end

  ---
  --- @type Options: {
  ---   arch: "actu8" | "mos6502" | "rv32i",
  ---   label: String,
  ---   memory_size: Integer,
  --- }

  --- @option arch
  --- @option label
  --- @option memory_size
  ---
  --- @override
  --- @spec #initialize(Options): void
  function ic:initialize(options)
    ic._super.initialize(self)
    options = options or {}

    self.disposed = false
    self.arch = options.arch or OKU.DEFAULT_ARCH
    local entry = OKU.AVAILABLE_ARCH[self.arch]
    assert(entry, "arch=" .. self.arch .. " not available")

    if not options.memory_size then
      options.memory_size = assert(entry.default_memory_size)
    end
    check_memory_size(options.memory_size)

    self.label = options.label or ""

    -- memory
    self.memory = Memory:new(options.memory_size)

    self.exec_counter = 0

    self.isa_assigns = {}
    self:_init_isa()
  end

  --- Invokes function on given ARCH module
  --- The method must accept the OKU state and ISA assigns as it's first 2 arguments.
  ---
  --- @spec #call_arch(method_name: String, ...: [term]): Any
  function ic:call_arch(method_name, ...)
    local entry = OKU.AVAILABLE_ARCH[self.arch]
    if entry then
      if not entry.engine then
        error("arch module is set with no engine, name=" .. self.arch)
      end
      return entry.engine[method_name](self, self.isa_assigns, ...)
    else
      error("arch module " .. self.arch .. " is not available")
    end
  end

  --- @spec #_init_isa(): Any
  function ic:_init_isa()
    return self:call_arch('init')
  end

  --- @spec #dispose(): void
  function ic:dispose()
    self:call_arch('dispose')
    self.memory = nil
    self.disposed = true
  end

  --- (see Memory:set_circular_access for details)
  ---
  --- @spec #set_memory_circular_access(Boolean): self
  function ic:set_memory_circular_access(bool)
    self.memory:set_circular_access(bool)
    return self
  end

  --- @spec #reset(): self
  function ic:reset()
    self:call_arch('reset')
    return self
  end

  --- @spec #step(steps: Integer): (steps: Integer, error: Integer)
  function ic:step(steps)
    if self.disposed then
      return 0, OKU.ERR_DISPOSED
    end

    if not self.memory then
      return 0, OKU.ERR_NO_MEMORY
    end

    local err
    if steps > 0 then
      local okay
      local entry = OKU.AVAILABLE_ARCH[self.arch]
      local step = entry.engine.step
      local assigns = self.isa_assigns
      for step_i = 1,steps do
        okay, err = step(self, assigns)

        if not okay then
          return step_i, err
        end
      end
    end
    return steps, err
  end

  --- @spec #get_memory_i8(index: Integer): Integer/8

  --- @spec #get_memory_i16(index: Integer): Integer/16

  --- @spec #get_memory_i32(index: Integer): Integer/32

  --- @spec #get_memory_i64(index: Integer): Integer/64

  --- @spec #get_memory_u8(index: Integer): Integer/8

  --- @spec #get_memory_u16(index: Integer): Integer/16

  --- @spec #get_memory_u32(index: Integer): Integer/32

  --- @spec #get_memory_u64(index: Integer): Integer/64

  --- @spec #put_memory_i8(index: Integer, value: Integer/8): Integer/8

  --- @spec #put_memory_i16(index: Integer, value: Integer/16): Integer/16

  --- @spec #put_memory_i32(index: Integer, value: Integer/32): Integer/32

  --- @spec #put_memory_i64(index: Integer, value: Integer/64): Integer/64

  --- @spec #put_memory_u8(index: Integer, value: Integer/8): Integer/8

  --- @spec #put_memory_u16(index: Integer, value: Integer/16): Integer/16

  --- @spec #put_memory_u32(index: Integer, value: Integer/32): Integer/32

  --- @spec #put_memory_u64(index: Integer, value: Integer/64): Integer/64

  for _,key in ipairs({"i8", "i16", "i32", "i64", "u8", "u16", "u32", "u64"}) do
    local reader_name = "r_" .. key
    local writer_name = "w_" .. key
    ic["get_memory_" .. key] = function (self, index)
      return self.memory[reader_name](self.memory, index)
    end

    ic["put_memory_" .. key] = function (self, index, value)
      self.memory[writer_name](self.memory, index, value)
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

  --- @spec #fill_memory(value: Integer): self
  function ic:fill_memory(value)
    assert(value, "expected a value")
    self.memory:fill(value)
    return self
  end

  function ic:upload_memory(blob)
    self.memory:upload(blob)
    return self
  end

  ---
  --- Binary Serialization
  ---
  --- @spec #bindump(Stream): (bytes_written: Integer, err?: Any)
  function ic:bindump(stream)
    local bytes_written = 0
    local bw, err
    -- Write the magic bytes
    bw, err = BB_LE:write(stream, "OKU2")
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- Write the version
    bw, err = BB_LE:w_u32(stream, 2)
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- Write the label
    assert(self.label, 'label is missing')
    bw, err = BB_LE:w_u8string(stream, self.label)
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    -- Write the arch
    assert(self.arch, 'arch is missing')
    bw, err = BB_LE:w_u8string(stream, self.arch)
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    local entry = OKU.AVAILABLE_ARCH[self.arch]
    if entry then
      --
      -- Memory
      bw, err = self:_bindump_memory(stream)
      bytes_written = bytes_written + bw
      if err then
        return bytes_written, err
      end

      --
      -- ISA State
      if entry.engine.bindump then
        bw, err = entry.engine.bindump(self, self.isa_assigns, stream)
        bytes_written = bytes_written + bw
        if err then
          return bytes_written, err
        end
      else
        error("ISA engine="..self.arch .. " does not define bindump/3")
      end
    else
      error("unsupported arch=" .. self.arch)
    end

    return bytes_written, nil
  end

  --- @spec #binload(Stream): (self, bytes_read: Integer)
  function ic:binload(stream)
    self.isa_assigns = {}
    self.exec_counter = 0
    local bytes_read = 0
    local br
    -- First thing is to read the magic bytes
    local mahou
    mahou, br = BB_LE:read(stream, 4)
    bytes_read = bytes_read + br
    if mahou == "OKU1" then
      -- next we read the arch, normally just rv32i
      local arch
      arch, br = BB_LE:r_u8string(stream)
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
      local version
      version, br = BB_LE:r_u32(stream)
      bytes_read = bytes_read + br

      if version == 1 then
        -- read the label
        local label
        label, br = BB_LE:r_u8string(stream)
        bytes_read = bytes_read + br
        self.label = label or ""

        -- next we read the arch
        local arch
        arch, br = BB_LE:r_u8string(stream)
        bytes_read = bytes_read + br

        self.arch = arch

        -- Reset registers
        local registers = yatm_oku.OKU.Registers:new()
        self.isa_assigns.registers = registers

        -- Restore registers
        bytes_read = bytes_read + self:_binload_registers(stream, registers)
        -- Restore memory
        bytes_read = bytes_read + self:_binload_memory(stream)
        -- Restore ISA state
        bytes_read = bytes_read + self:call_arch('binload', stream)
      elseif version == 2 then
        -- read the label
        local label
        label, br = BB_LE:r_u8string(stream)
        bytes_read = bytes_read + br
        self.label = label or ""

        -- next we read the arch
        local arch
        arch, br = BB_LE:r_u8string(stream)
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

  --- @spec &binload(Stream): OKU
  function OKU:binload(stream)
    local oku = self:alloc()
    local oku, br = oku:binload(stream)
    return oku, br
  end

  --- @spec #_bindump_memory(Stream): (bytes_written: Integer, err?: Any)
  function ic:_bindump_memory(stream)
    local bytes_written = 0
    local bw
    local err
    bw, err = BB_LE:w_u32(stream, self.memory:size())
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    bw, err = BB_LE:w_u8bool(stream, true)
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    bw, err = self.memory:bindump(stream)
    bytes_written = bytes_written + bw
    if err then
      return bytes_written, err
    end

    return bytes_written, nil
  end

  function ic:_binload_registers(stream, registers)
    local bytes_read = 0
    for i = 0,31 do
      local rv, br = BB_LE:r_i32(stream)
      bytes_read = bytes_read + br
      registers.x[i].i32 = rv
    end
    registers.pc.u32 = BB_LE:r_u32(stream)
    return bytes_read
  end

  function ic:_binload_memory(stream)
    local bytes_read = 0
    local br
    -- time to figure out what the memory size was
    local memory_size
    memory_size, br = BB_LE:r_u32(stream)

    bytes_read = bytes_read + br
    check_memory_size(memory_size) -- make sure someone isn't trying something funny.
    self.memory = yatm_oku.OKU.Memory:new(memory_size)

    -- okay, now determine if the memory should be reloaded, or was it volatile
    local has_state
    has_state, br = BB_LE:r_u8bool(stream)
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
    self.isa_assigns.registers = yatm_oku.OKU.Registers:new()
    bytes_read = bytes_read + self:_binload_registers(stream, self.isa_assigns.registers)
    -- Restore memory
    bytes_read = bytes_read + self:_binload_memory(stream)

    return bytes_read
  end
end

yatm_oku.OKU = OKU
