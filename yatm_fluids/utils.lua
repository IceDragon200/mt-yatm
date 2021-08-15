local string_starts_with = assert(foundation.com.string_starts_with)
local fluid_registry = assert(yatm_fluids.fluid_registry)

local Utils = {}

function Utils.is_valid_name(name)
  -- A fluid name must not be nil, empty or is a group name
  return name ~= nil and name ~= "" and not string_starts_with(name, "group:")
end

function Utils.can_replace(dest_name, src_name, amount)
  return (dest_name == nil or dest_name == "" or amount == 0) and
    Utils.is_valid_name(src_name)
end

--[[
Determines if fluid name A matches fluid name B, or if they are in a particular group

Usage:

```lua
yatm_fluids.fluids.matches(fluid_name_or_group_name, fluid_name_or_group_name2) # => fluid_name :: String.t | nil
yatm_fluids.fluids.matches("group:water", "default:water") # => "default:water"
yatm_fluids.fluids.matches("group:steam", "yatm_fluids:steam") # => "yatm_fluids:steam"
yatm_fluids.fluids.matches("group:lava", "yatm_fluids:steam") # => nil
yatm_fluids.fluids.matches("group:lava", "group:lava") # => nil # you can't match groups, only fluid names with groups
```

Args:
* `a :: String.t` - a fluid name or group name
* `b :: String.t` - a fluid name or group name

Returns:
* `fluid_name :: String.t | nil` - the correct fluid name OR nil if no match was performed
]]
function Utils.matches(a, b)
  a = fluid_registry.normalize_fluid_name(a)
  b = fluid_registry.normalize_fluid_name(b)
  if string_starts_with(a, "group:") then
    -- We can't match group to group, since it has to return a valid name
    if b ~= "*" and not string_starts_with(b, "group:") then
      local group = string.sub(a, #"group:" + 1)
      local members = yatm.Measurable.members_of(fluid_registry, group)
      if members and members[b] then
        return b
      end
    end
    return nil
  elseif string_starts_with(b, "group:") then
    if a == "*" then
      return nil
    end
    local group = string.sub(b, #"group:" + 1)
    local members = yatm.Measurable.members_of(fluid_registry, group)
    if members and members[a] then
      return a
    end
    return nil
  elseif a == "*" and b == "*" then
    return nil
  elseif a == "*" then
    return b
  elseif b == "*" then
    return a
  elseif a == b then
    return a
  else
    return nil
  end
end

yatm_fluids.Utils = Utils
