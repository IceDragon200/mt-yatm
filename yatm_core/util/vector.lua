-- Minetest has pos_to_string, but I believe that floor rounds the vector and adds bracket around it
function yatm_core.vector_to_string(vec)
  return vec.x .. "," .. vec.y .. "," .. vec.z
end

yatm_core.vector3 = {}

function yatm_core.vector3.new(x, y, z)
  return { x = x, y = y, z = z }
end

function yatm_core.vector3.to_string(v1, seperator)
  seperator = seperator or ","
  return v1.x .. seperator .. v1.y .. seperator .. v1.z
end

function yatm_core.vector3.floor(dest, v1)
  dest.x = math.floor(v1.x)
  dest.y = math.floor(v1.y)
  dest.z = math.floor(v1.z)
  return dest
end

function yatm_core.vector3.round(dest, v1)
  dest.x = math.floor(v1.x + 0.5)
  dest.y = math.floor(v1.y + 0.5)
  dest.z = math.floor(v1.z + 0.5)
  return dest
end

function yatm_core.vector3.dot(v1, v2)
  return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end

function yatm_core.vector3.add(dest, v1, v2)
  dest.x = v1.x + v2.x
  dest.y = v1.y + v2.y
  dest.z = v1.z + v2.z
  return dest
end

function yatm_core.vector3.subtract(dest, v1, v2)
  dest.x = v1.x + v2.x
  dest.y = v1.y + v2.y
  dest.z = v1.z + v2.z
  return dest
end

function yatm_core.vector3.multiply(dest, v1, v2)
  dest.x = v1.x * v2.x
  dest.y = v1.y * v2.y
  dest.z = v1.z * v2.z
  return dest
end

function yatm_core.vector3.divide(dest, v1, v2)
  dest.x = v1.x / v2.x
  dest.y = v1.y / v2.y
  dest.z = v1.z / v2.z
  return dest
end

function yatm_core.vector3.idivide(dest, v1, v2)
  dest.x = math.floor(v1.x / v2.x)
  dest.y = math.floor(v1.y / v2.y)
  dest.z = math.floor(v1.z / v2.z)
  return dest
end

yatm_core.vector3.sub = yatm_core.vector3.subtract
yatm_core.vector3.mul = yatm_core.vector3.multiply
yatm_core.vector3.div = yatm_core.vector3.divide
yatm_core.vector3.idiv = yatm_core.vector3.idivide

yatm_core.vector4 = {}

function yatm_core.vector4.new(x, y, z, w)
  return { x = x, y = y, z = z, w = w }
end

function yatm_core.vector4.to_string(v1)
  return v1.x .. "," .. v1.y .. "," .. v1.z .. "," .. v1.w
end

function yatm_core.vector4.floor(dest, v1)
  dest.x = math.floor(v1.x)
  dest.y = math.floor(v1.y)
  dest.z = math.floor(v1.z)
  dest.w = math.floor(v1.w)
  return dest
end

function yatm_core.vector4.round(dest, v1)
  dest.x = math.floor(v1.x + 0.5)
  dest.y = math.floor(v1.y + 0.5)
  dest.z = math.floor(v1.z + 0.5)
  dest.w = math.floor(v1.w + 0.5)
  return dest
end

function yatm_core.vector4.dot(v1, v2)
  return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z + v1.w * v2.w
end

function yatm_core.vector4.add(dest, v1, v2)
  dest.x = v1.x + v2.x
  dest.y = v1.y + v2.y
  dest.z = v1.z + v2.z
  dest.w = v1.w + v2.w
  return dest
end

function yatm_core.vector4.subtract(dest, v1, v2)
  dest.x = v1.x + v2.x
  dest.y = v1.y + v2.y
  dest.z = v1.z + v2.z
  dest.w = v1.w + v2.w
  return dest
end

function yatm_core.vector4.multiply(dest, v1, v2)
  dest.x = v1.x * v2.x
  dest.y = v1.y * v2.y
  dest.z = v1.z * v2.z
  dest.w = v1.w * v2.w
  return dest
end

function yatm_core.vector4.divide(dest, v1, v2)
  dest.x = v1.x / v2.x
  dest.y = v1.y / v2.y
  dest.z = v1.z / v2.z
  dest.w = v1.w / v2.w
  return dest
end

yatm_core.vector4.sub = yatm_core.vector4.subtract
yatm_core.vector4.mul = yatm_core.vector4.multiply
yatm_core.vector4.div = yatm_core.vector4.divide
