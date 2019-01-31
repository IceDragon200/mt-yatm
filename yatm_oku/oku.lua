--[[
Registers:

-- General Purpose Registers (8-bit)
A
B
C
D
E

-- Memory Registers (16 bit)
SP - Stack Pointer
PC - Program Counter

-- Union Registers (16 bit)
BC
DE
]]

-- string.rep to initialize the memory
-- string.unpack and string.pack to deserialize and serialize data

local oku_assert = function () end
local oku_print = function() end

local OKU = {
  mt = {},
}

local StringMemory = {
  mt = {},
}

function StringMemory.new(size)
  local memory = {}
  setmetatable(memory, { __index = StringMemory.mt })
  memory:initialize(size)
  return memory
end

function StringMemory.mt:initialize(size)
  self.size = size
  self.data = string.rep('\0', size)
end

function StringMemory.mt:bytes(index, len)
  local len = len or 1
  if len > 0 then
    local end_index = index + len - 1
    return {string.byte(self.data, index + 1, end_index + 1)}
  else
    return {}
  end
end

function StringMemory.mt:put_bytes(index, bytes)
  if type(bytes) == "string" then
    --
  elseif type(bytes) == "number" then
    bytes = string.char(bytes)
  elseif type(bytes) == "table" then
    bytes = string.char(unpack(bytes))
  end
  local index = index + 1
  local end_index = index + #bytes - 1
  self.data =
    string.sub(self.data, 1, index - 1) ..
    bytes ..
    string.sub(self.data, end_index, #self.data)
  return self
end

local StringChunkMemory = {
  mt = {},
}
local BLOCK_SIZE = 256
function StringChunkMemory.new(size)
--function StringChunkMemory.new(size)
  local memory = {}
  setmetatable(memory, { __index = StringChunkMemory.mt })
  memory:initialize(size)
  return memory
end

function StringChunkMemory.mt:initialize(size)
--function StringChunkMemory.mt:initialize(size)
  oku_assert(size, "expected a size")
  self.size = size
  self.blocks = {}
  self.block_count = math.floor(self.size / BLOCK_SIZE)
  for i=1,self.block_count do
    self.blocks[i] = string.rep('\0', BLOCK_SIZE)
  end
  oku_assert(#self.blocks == self.block_count, "expected " .. self.block_count .. " blocks to be initialized only " .. #self.blocks .. " are initialized")
end

function StringChunkMemory.mt:reduce_slice(index, len, func)
--function StringChunkMemory.mt:reduce_slice(index, len, func)
  oku_assert(index >= 0, "expected index to be greater than or equal to 0")
  len = len or 1
  while len > 0 do
    local block_index = math.floor(index / BLOCK_SIZE) + 1
    local block_offset = index % BLOCK_SIZE + 1
    local block = self.blocks[block_index]
    oku_assert(block, "expected memory block " .. block_index .. " to exist")
    local tail = math.min(block_offset + len - 1, BLOCK_SIZE)
    local used_len = tail - block_offset + 1
    oku_print("reduce_slice/3", "index", index, "len", len, "block_offset", block_offset, "tail", tail)
    oku_assert(used_len > 0, "used_len is negative!? " .. used_len)
    len = len - used_len
    index = index + used_len
    local new_block = func(block, block_offset, tail, used_len)
    oku_assert(#new_block == BLOCK_SIZE, "expected new block to be of BLOCK_SIZE got " .. #new_block)
    self.blocks[block_index] = new_block
  end
end

-- StringChunkMemory is 0 indexed to the outside, but respects lua's 1 indexing internally
---- StringChunkMemory is 0 indexed to the outside, but respects lua's 1 indexing internally
function StringChunkMemory.mt:bytes(index, len)
--function StringChunkMemory.mt:bytes(index, len)
  local result = {}
  local result_i = 1
  local len = len or 1
  self:reduce_slice(index, len, function (block, block_offset, tail, used_len)
    oku_print("read-block-slice", "index", index, "len", len, "block_offset", block_offset, "tail", tail, "used_len", used_len)
    local r = {string.byte(block, block_offset, tail)}
    for i=1,#r do
      result[result_i] = r[i]
      result_i = result_i + 1
    end
    return block
  end)
  return result
end

function StringChunkMemory.mt:put_bytes(index, bytes)
--function StringChunkMemory.mt:put_bytes(index, bytes)
  if type(bytes) == "string" then
    bytes = {string.byte(bytes, 1, #bytes)}
  elseif type(bytes) == "number" then
    bytes = {bytes}
  elseif type(bytes) == "table" then
    -- okay
  end
  local len = #bytes
  local bytes_start = 1
  self:reduce_slice(index, len, function (block, block_offset, tail, used_len)
    oku_print("write-block-slice", "index", index, "len", len, "block_offset", block_offset, "tail", tail, "used_len", used_len)
    local head
    head = string.sub(block, 1, block_offset - 1) or ""
    local body = {}
    local body_i = 1
    local bytes_end = bytes_start + used_len - 1
    for bytes_i=bytes_start,bytes_end do
      oku_assert(bytes_i <= len)
      local byte = bytes[bytes_i]
      oku_print(#bytes, byte)
      body[body_i] = string.char(byte)
      body_i = body_i + 1
    end
    bytes_start = bytes_end
    local tail = string.sub(block, tail + 1, BLOCK_SIZE)
    oku_print("write-block-slice-pieces", #head, #body, #tail)
    return head .. table.concat(body) .. tail
  end)
  return self
end

local TableMemory = {
  mt = {}
}

function TableMemory.new(size)
  local memory = {}
  setmetatable(memory, { __index = TableMemory.mt })
  memory:initialize(size)
  return memory
end

function TableMemory.mt:initialize(size)
  self.size = size
  self.data = {}
  for i=1,size do
    self.data[i] = 0
  end
end

function TableMemory.mt:bytes(index, end_index)
  oku_assert(index >= 0, "expected index to greater than 0")
  oku_assert(index < self.size, "expected index to be less than size")
  local end_index = end_index or index
  oku_assert(end_index < self.size, "expected end_index to be less than size")
  local result = {}
  local i = 1
  for j=index,end_index do
    result[i] = self.data[j + 1]
    i = i + 1
  end
  return result
end

function TableMemory.mt:put_bytes(index, bytes)
  oku_assert(index >= 0, "expected index to greater than 0")
  oku_assert(index <= self.size, "expected index to be less than size")
  if type(bytes) == "string" then
    bytes = {string.byte(bytes, 1, #bytes)}
  elseif type(bytes) == "number" then
    bytes = {bytes}
  elseif type(bytes) == "table" then
    -- all is well
  end
  local len = #bytes
  if len > 0 then
    local end_index = index + len - 1
    oku_assert(end_index < self.size, "expected end_index to be less than size")
    local i = 1
    for j = index,end_index do
      self.data[j + 1] = bytes[i]
    end
  end
  return self
end

function OKU.new()
  local oku = {
    registers = {
      a = 0,
      b = 0,
      c = 0,
      d = 0,
      e = 0,
      sp = 0,
      pc = 0,
    },
    memory = StringMemory.new(math.floor(math.pow(2, 16)))
    --memory = StringChunkMemory.new(math.floor(math.pow(2, 16)))
    --memory = TableMemory.new(math.floor(math.pow(2, 16)))
  }
  setmetatable(oku, { __index = OKU.mt })
  return oku
end

function OKU.mt:get_memory(index, len)
  return self.memory:bytes(index, len)
end

function OKU.mt:put_memory(index, bytes)
  return self.memory:put_bytes(index, bytes)
end

yatm_oku.OKU = OKU
