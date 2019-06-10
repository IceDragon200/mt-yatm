--[[
Registers:
x0-x31
pc
]]

-- string.rep to initialize the memory
-- string.unpack and string.pack to deserialize and serialize data
yatm_oku.OKU = yatm_core.Class:extends()

--dofile(yatm_oku.modpath .. "/lib/oku/memory/string_memory.lua")
dofile(yatm_oku.modpath .. "/lib/oku/memory/binary_memory.lua")

local OKU = yatm_oku.OKU
local m = OKU.instance_class

function m:initialize()
  self.registers = {

    pc = 0,
  }

  self.memory_size = math.floor(math.pow(2, 16))
  self.memory = yatm_oku.OKU.BinaryMemory:new(self.memory_size)
end

function m:get_memory_byte(index)
  return self.memory:i8(index)
end

function m:put_memory_byte(index, value)
  return self.memory:w_i8(index, value)
end

function m:get_memory_slice(index, len)
  return self.memory:bytes(index, len)
end

function m:put_memory_slice(index, bytes)
  return self.memory:put_bytes(index, bytes)
end

yatm_oku.OKU = OKU
