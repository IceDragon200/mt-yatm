local Cuboid = yatm_core.Class:extends()
local ic = Cuboid.instance_class

-- Or just sixteenth
Cuboid.PX16 = 1 / 16.0

function ic:initialize(x, y, z, w, h, d)
  self.x = x
  self.y = y
  self.z = z
  self.w = w
  self.h = h
  self.d = d
end

function ic:scale(x, y, z)
  y = y or x
  z = z or y
  self.x = self.x * x
  self.y = self.y * y
  self.z = self.z * z
  self.w = self.w * x
  self.h = self.h * y
  self.d = self.d * z
  return self
end

function ic:translate(x, y, z)
  self.x = self.x + x
  self.y = self.y + y
  self.z = self.z + z
  return self
end

function ic:to_extents()
  return vector.new(self.x, self.y, self.z), vector.new(self.x + self.w, self.y + self.h, self.z + self.d)
end

function ic:fast_node_box()
  return self:scale(Cuboid.PX16):translate(-0.5, -0.5, -0.5):to_node_box()
end

function ic:to_node_box()
  return {self.x, self.y, self.z, self.x + self.w, self.y + self.h, self.z + self.d}
end

yatm_core.Cuboid = Cuboid
