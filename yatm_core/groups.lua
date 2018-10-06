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

yatm_core.groups = groups
