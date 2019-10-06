local ByteBuf = assert(yatm_core.ByteBuf)

local Bytes = yatm_core.Class:extends("Bytes")
local ic = Bytes.instance_class

function ic:initialize(length)
  self.length = length
end

function ic:write(file, data)
  data = data or ""
  local payload = string.sub(data, 1, self.length)
  local actual_length = #payload
  local padding_needed = self.length - actual_length
  assert(padding_needed >= 0, "length error")
  local bytes_written, err = ByteBuf.write(file, payload)
  if err then
    return bytes_written, err
  end
  for _ = 1,padding_needed do
    ByteBuf.w_u8(file, 0)
  end
  return self.length, nil
end

function ic:read(file)
  return ByteBuf.read(file, self.length)
end

return Bytes
