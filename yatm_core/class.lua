--[[
A minimal object class system.

Please don't use the Classes for any performance critical code.
I will not make an effort to optimize it, unless it's god awful slow.
]]

local Class = {}

function Class.extends()
  local klass = {
    instance_class = {},
  }

  function klass.new(...)
    local instance = {}
    setmetatable(instance, { __index = klass.instance_class })
    instance:initialize(...)
    return instance
  end

  return klass
end

yatm_core.Class = Class
