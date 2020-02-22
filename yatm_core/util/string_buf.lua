--
-- StringBuf is an in-memory equivalent of love's File interface
--
local StringBuf = yatm_core.Class:extends()
local ic = StringBuf.instance_class

function ic:initialize(data, mode)
  assert(type(data) == "string", "expected a string for data")
  ic._super.initialize(self)
  self.m_data = data
  self:open(mode)
end

function ic:size()
  return #self.m_data
end

function ic:open(mode)
  self.m_cursor = 1
  self.m_mode = mode or "r"
  -- append
  if self.m_mode == "a" then
    self.m_cursor = 1 + #self.m_data
  end
end

function ic:close()
  self.m_cursor = 1
  self.m_mode = nil
end

function ic:isEOF()
  return self.m_cursor > #self.m_data
end

function ic:tell()
  return self.m_cursor
end

function ic:rewind()
  self.m_cursor = 1
  return self
end

function ic:seek(pos)
  self.m_cursor = pos
  return self
end

-- Because of lua's annoying 1 index
function ic:cseek(pos)
  return self:seek(pos + 1)
end

function ic:walk(distance)
  distance = distance or 1
  self.m_cursor = self.m_cursor + distance
  return self
end

function ic:find(pattern)
  return string.find(self.m_data, pattern, self.m_cursor)
end

function ic:scan(pattern)
  local i, j = self:find("^" .. pattern)
  if i then
    return self:read(j - i + 1)
  else
    return nil, 0
  end
end

function ic:scan_until(pattern)
  local k = self:tell()
  local i, j = self:find(pattern)
  if i then
    return self:read(j - k + 1)
  else
    return nil, 0
  end
end

function ic:scan_upto(pattern)
  local k = self:tell()
  local i, j = self:find(pattern)
  if i then
    return self:read(j - k)
  else
    return nil, 0
  end
end

function ic:scan_while(pattern)
  local k = self:tell()
  local result = {}

  while not self:isEOF() do
    local str = self:scan(pattern)
    if str then
      table.insert(result, str)
    else
      break
    end
  end

  for _, _ in pairs(result) do
    return table.concat(result)
  end
  return nil
end

function ic:skip(pattern)
  local i, j = self:find("^" .. pattern)
  if i then
    self.m_cursor = j + 1
    return true
  else
    return false
  end
end

function ic:skip_until(pattern)
  local i, j = self:find(pattern)
  if i then
    self.m_cursor = j + 1
    return true
  else
    return false
  end
end

function ic:calc_read_length(len)
  assert(self.m_mode == "r" or self.m_mode == "rw", "expected read mode")
  local remaining_len = #self.m_data - self.m_cursor + 1
  local len = math.min(len or remaining_len, remaining_len)
  return len
end

function ic:peek_bytes(len)
  local len = self:calc_read_length(len)
  return string.byte(self.m_data, self.m_cursor, self.m_cursor + len - 1), len
end

function ic:read_bytes(len)
  local len = self:calc_read_length(len)
  local pos = self.m_cursor
  self.m_cursor = self.m_cursor + len
  return string.byte(self.m_data, pos, pos + len - 1), len
end

function ic:peek(len)
  local len = self:calc_read_length(len)
  return string.sub(self.m_data, self.m_cursor, self.m_cursor + len - 1), len
end

function ic:read(len)
  local len = self:calc_read_length(len)
  local pos = self.m_cursor
  self.m_cursor = self.m_cursor + len
  return string.sub(self.m_data, pos, pos + len - 1), len
end

function ic:write(data)
  assert(self.m_mode == "w" or self.m_mode == "rw", "expected write mode")
  data = tostring(data)
  local current_len = #self.m_data
  local len = #data
  local final_cursor = self.m_cursor + len
  if final_cursor < current_len then
    -- the final cursor is still inside the string
    local head = string.sub(self.m_data, 1, self.m_cursor)
    local tail = string.sub(self.m_data, final_cursor, current_len)
    self.m_data = head .. data .. tail
  else
    -- the data will overwrite a section of the existing data and add new data
    self.m_data = string.sub(self.m_data, 1, self.m_cursor)
    self.m_data = self.m_data .. data
  end
  self.m_cursor = final_cursor
  return true, nil
end

yatm_core.StringBuf = StringBuf
