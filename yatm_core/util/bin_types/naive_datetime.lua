local ByteBuf = require("app/util/byte_buf")
local BinSchema = require("app/util/bin_schema")

local NaiveDateTimeSchema0 = BinSchema:new({
  {"year", "u16"},
  {"month", "u8"},
  {"day", "u8"},
  {"hour", "u8"},
  {"minute", "u8"},
  {"second", "u8"},
})

local NaiveDateTime = LilyObject:extends("NaiveDateTimeBinType")
local ic = NaiveDateTime.instance_class

function ic:write(file, datetime)
  local all_bytes_written = 0
  -- Datetime Version, in case the format needs to change
  local bytes_written, err = ByteBuf.w_u32(file, 0)
  all_bytes_written = all_bytes_written + bytes_written
  if err then
    return all_bytes_written, err
  end
  local bytes_written, err = NaiveDateTimeSchema0:write(file, datetime)
  all_bytes_written = all_bytes_written + bytes_written
  return all_bytes_written, err
end

function ic:read(file)
  local value, read_bytes = ByteBuf.r_u32(file)
  if value == 0 then
    return NaiveDateTimeSchema0:read(file)
  else
    error("invalid naive_datetimme version")
  end
end

return NaiveDateTime
