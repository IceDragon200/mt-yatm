--[[
A minimal object class system.

Please don't use the Classes for any performance critical code.
I will not make an effort to optimize it, unless it's god awful slow.
]]
local Class = {
  instance_class = {}
}

function Class.instance_class:method(name)
  local func = assert(self[name], "function not found")
  if type(func) == "function" then
    local target = self
    return function (...)
      func(target, ...)
    end
  else
    error("expected a function")
  end
end

function Class:extends(name)
  local klass = {
    _super = self,
    name = name,
    instance_class = {},
  }
  klass.instance_class._super = klass._super.instance_class
  klass.instance_class._class = klass
  setmetatable(klass, { __index = self })
  setmetatable(klass.instance_class, { __index = self.instance_class })
  return klass
end

function Class:alloc()
  local instance = {}
  setmetatable(instance, { __index = self.instance_class })
  return instance
end

function Class:new(...)
  local instance = self:alloc()
  if instance.initialize then
    instance:initialize(...)
  end
  return instance
end

yatm_core.Class = Class
