--[[
OKU's memory model using chunked strings.
]]

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

yatm_oku.OKU.StringChunkMemory = StringChunkMemory
