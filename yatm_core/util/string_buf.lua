--[[
StringBuf is an in-memory equivalent of love's File interface
]]
local StringBuf = yatm_core.Class:extends()
local ic = StringBuf.instance_class

function ic:initialize(data, mode)
  ic._super.initialize(self)
  self.data = data
  self:open(mode)
end

function ic:open(mode)
  self.cursor = 1
  self.mode = mode or "r"
  -- append
  if self.mode == "a" then
    self.cursor = 1 + #self.data
  end
end

function ic:isEOF()
  return self.cursor > #self.data
end

function ic:rewind()
  self.cursor = 1
  return self
end

function ic:tell()
  return self.cursor
end

function ic:seek(pos)
  self.cursor = pos
  return self
end

-- Because of lua's annoying 1 index
function ic:cseek(pos)
  return self:seek(pos + 1)
end

function ic:walk(distance)
  self.cursor = self.cursor + 1
  return self
end

function ic:find(pattern)
  return string.find(self.data, pattern, self.cursor)
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

function ic:scan_while(pattern)
  local k = self:tell()
  local result = {}
  while not self:isEOF() do
    local i, j = self:find(pattern)
    if i then
      local str = self:read(j - k + 1)
      local k = self:tell()
      table.insert(result, str)
    else
      return table.concat(result)
    end
  end
  return nil
end

function ic:skip(pattern)
  local i, j = self:find("^" .. pattern)
  if i then
    self.cursor = j + 1
    return true
  else
    return false
  end
end

function ic:skip_until(pattern)
  local i, j = self:find(pattern)
  if i then
    self.cursor = j + 1
    return true
  else
    return false
  end
end

function ic:calc_read_length(len)
  assert(self.mode == "r" or self.mode == "rw", "expected read mode")
  local remaining_len = #self.data - self.cursor + 1
  local len = math.min(len or remaining_len, remaining_len)
  return len
end

function ic:peek_bytes(len)
  local len = self:calc_read_length(len)
  return string.byte(self.data, self.cursor, self.cursor + len - 1), len
end

function ic:read_bytes(len)
  local len = self:calc_read_length(len)
  local pos = self.cursor
  self.cursor = self.cursor + len
  return string.byte(self.data, pos, pos + len - 1), len
end

function ic:peek(len)
  local len = self:calc_read_length(len)
  return string.sub(self.data, self.cursor, self.cursor + len - 1), len
end

function ic:read(len)
  local len = self:calc_read_length(len)
  local pos = self.cursor
  self.cursor = self.cursor + len
  return string.sub(self.data, pos, pos + len - 1), len
end

function ic:write(data)
  assert(self.mode == "w" or self.mode == "rw", "expected write mode")
  data = tostring(data)
  local current_len = #self.data
  local len = #data
  local final_cursor = self.cursor + len
  if final_cursor < current_len then
    -- the final cursor is still inside the string
    local head = string.sub(self.data, 1, self.cursor)
    local tail = string.sub(self.data, final_cursor, current_len)
    self.data = head .. data .. tail
  else
    -- the data will overwrite a section of the existing data and add new data
    self.data = string.sub(self.data, 1, self.cursor)
    self.data = self.data .. data
  end
  self.cursor = final_cursor
  return true, nil
end

yatm_core.StringBuf = StringBuf
