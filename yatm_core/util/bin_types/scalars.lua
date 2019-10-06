local ByteBuf = assert(yatm_core.ByteBuf)

local Scalars = {
  i8 = {},
  i16 = {},
  i24 = {},
  i32 = {},
  i64 = {},
  u8 = {},
  u16 = {},
  u24 = {},
  u32 = {},
  u64 = {},
  f16 = {},
  f24 = {},
  f32 = {},
  f64 = {},
  u8bool = {},
  u8string = {},
  u16string = {},
  u24string = {},
  u32string = {},
}

function Scalars.i8:write(file, data)
  return ByteBuf.w_i8(file, data)
end
function Scalars.i16:write(file, data)
  return ByteBuf.w_i16(file, data)
end
function Scalars.i24:write(file, data)
  return ByteBuf.w_i24(file, data)
end
function Scalars.i32:write(file, data)
  return ByteBuf.w_i32(file, data)
end
function Scalars.i64:write(file, data)
  return ByteBuf.w_i64(file, data)
end

function Scalars.u8:write(file, data)
  return ByteBuf.w_u8(file, data)
end
function Scalars.u16:write(file, data)
  return ByteBuf.w_u16(file, data)
end
function Scalars.u24:write(file, data)
  return ByteBuf.w_u24(file, data)
end
function Scalars.u32:write(file, data)
  return ByteBuf.w_u32(file, data)
end
function Scalars.u64:write(file, data)
  return ByteBuf.w_u64(file, data)
end

function Scalars.f16:write(file, data)
  return ByteBuf.w_f16(file, data)
end
function Scalars.f24:write(file, data)
  return ByteBuf.w_f24(file, data)
end
function Scalars.f32:write(file, data)
  return ByteBuf.w_f32(file, data)
end
function Scalars.f64:write(file, data)
  return ByteBuf.w_f64(file, data)
end

function Scalars.u8bool:write(file, data)
  return ByteBuf.w_u8bool(file, data)
end

function Scalars.u8string:write(file, data)
  return ByteBuf.w_u8string(file, data)
end
function Scalars.u16string:write(file, data)
  return ByteBuf.w_u16string(file, data)
end
function Scalars.u24string:write(file, data)
  return ByteBuf.w_u24string(file, data)
end
function Scalars.u32string:write(file, data)
  return ByteBuf.w_u32string(file, data)
end

function Scalars.i8:read(file)
  return ByteBuf.r_i8(file)
end
function Scalars.i16:read(file)
  return ByteBuf.r_i16(file)
end
function Scalars.i24:read(file)
  return ByteBuf.r_i24(file)
end
function Scalars.i32:read(file)
  return ByteBuf.r_i32(file)
end
function Scalars.i64:read(file)
  return ByteBuf.r_i64(file)
end

function Scalars.u8:read(file)
  return ByteBuf.r_u8(file)
end
function Scalars.u16:read(file)
  return ByteBuf.r_u16(file)
end
function Scalars.u24:read(file)
  return ByteBuf.r_u24(file)
end
function Scalars.u32:read(file)
  return ByteBuf.r_u32(file)
end
function Scalars.u64:read(file)
  return ByteBuf.r_u64(file)
end

function Scalars.f16:read(file)
  return ByteBuf.r_f16(file)
end
function Scalars.f24:read(file)
  return ByteBuf.r_f24(file)
end
function Scalars.f32:read(file)
  return ByteBuf.r_f32(file)
end
function Scalars.f64:read(file)
  return ByteBuf.r_f64(file)
end

function Scalars.u8bool:read(file)
  return ByteBuf.r_u8bool(file)
end

function Scalars.u8string:read(file)
  return ByteBuf.r_u8string(file)
end
function Scalars.u16string:read(file)
  return ByteBuf.r_u16string(file)
end
function Scalars.u24string:read(file)
  return ByteBuf.r_u24string(file)
end
function Scalars.u32string:read(file)
  return ByteBuf.r_u32string(file)
end

function Scalars.normalize_type(t)
  if type(t) == "string" then
    local scalar_type = Scalars[t]
    assert(scalar_type, "expected a scalar type")
    return scalar_type
  elseif type(t) == "table" then
    assert(t.write, "expected write/3")
    assert(t.read, "expected read/2")
    return t
  else
    error("unexpected type " .. type(t))
  end
end

yatm_core.binary_types.Scalars = Scalars
