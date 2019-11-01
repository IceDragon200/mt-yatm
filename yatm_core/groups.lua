local groups = {}

function groups.get(object)
  return object.groups or {}
end

function groups.patch_get(object)
  if not object.groups then
    object.groups = {}
  end
  return object.groups
end

function groups.get_item(object, key)
  return groups.get(object)[key]
end

function groups.put_item(object, key, value)
  groups.patch_get(object)[key] = value
  return object
end

function groups.has_group(object, name, optional_rank)
  if object.groups then
    local value = object.groups[name]
    if value then
      if optional_rank then
        return value >= optional_rank
      else
        return value > 0
      end
    end
  end
  return false
end

function groups.item_has_group(name, group_name, optional_rank)
  local rank = minetest.get_item_group(name, group_name)
  if rank and rank > 0 then
    if optional_rank then
      return value >= optional_rank
    else
      return true
    end
  end
  return false
end

yatm_core.groups = groups
