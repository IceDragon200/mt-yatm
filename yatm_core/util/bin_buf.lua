--
-- Binary Buffer - same interface as StringBuf but using an FFI allocated uchar array
--
local ffi = assert(yatm.ffi)
local BinaryBuffer = yatm_core.Class:extends('BinaryBuffer')
local ic = BinaryBuffer.instance_class

local BLOCK_SIZE = 4096

local function next_block_size(size)
  local blocks = math.floor(size / BLOCK_SIZE)
  return (blocks + 1) * BLOCK_SIZE
end

function ic:initialize(initial_size_or_data, mode)
  local size, allocated_size, data
  if type(initial_size_or_data) == 'number' then
    allocated_size = initial_size_or_data
    data = ''
  else
    data = initial_size_or_data or ''
  end
  size = #data
  allocated_size = allocated_size or next_block_size(size)
  self.m_size = size
  self.m_allocated_size = allocated_size
  self.m_data = ffi.new('unsigned char[?]', self.m_allocated_size)
  ffi.fill(self.m_data, self.m_allocated_size)
  ffi.copy(self.m_data, data, #data)

  self:open(mode)
end

function ic:blob()
  return ffi.string(self.m_data, self.m_size)
end

function ic:resize(new_size)
  local old_allocated_size = self.m_allocated_size
  local old_data = self.m_data

  self.m_allocated_size = new_size
  self.m_data = ffi.new('unsigned char[?]', self.m_allocated_size)
  ffi.fill(self.m_data, self.m_allocated_size)

  ffi.copy(self.m_data, old_data, math.min(old_allocated_size, self.m_allocated_size))

  return self
end

function ic:resize_to_next_block()
  return self:resize(next_block_size(self.m_allocated_size))
end

function ic:close()
  self.m_mode = nil
end

function ic:open(mode)
  self.m_cursor = 1
  self.m_mode = mode
  -- append
  if self.m_mode == 'a' then
    self.m_cursor = 1 + self.m_size
  end
end

function ic:tell()
  return self.m_cursor
end

function ic:seek(new_pos)
  self.m_cursor = new_pos
  return self
end

function ic:calc_read_length(len)
  assert(self.m_mode == "r" or self.m_mode == "rw", "expected read mode")
  local remaining_len = self.m_size - self.m_cursor + 1
  local len = math.min(len or remaining_len, remaining_len)
  return len
end

function ic:read(len)
  local len = self:calc_read_length(len)
  local pos = self.m_cursor - 1
  self.m_cursor = self.m_cursor + len
  if len > 0 then
    return ffi.string(self.m_data + pos, len), len
  else
    return nil, len
  end
end

function ic:write(blob)
  assert(self.m_mode == 'w' or self.m_mode == 'rw', 'must be opened for writing')
  blob = tostring(blob)
  local blob_size = #blob
  local next_cursor = self.m_cursor + blob_size

  while next_cursor > self.m_allocated_size do
    self:resize_to_next_block()
  end

  ffi.copy(self.m_data + (self.m_cursor - 1), blob)
  self.m_cursor = self.m_cursor + #blob

  --[[local i = 1
  while self.m_cursor < next_cursor do
    self.m_data[self.m_cursor - 1] = string.byte(blob, i)
    i = i + 1
    self.m_cursor = self.m_cursor + 1
  end]]

  if self.m_size < self.m_cursor then
    self.m_size = self.m_cursor
  end

  return true, nil
end

yatm_core.BinaryBuffer = BinaryBuffer
