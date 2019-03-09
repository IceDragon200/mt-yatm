--[[
`lockable` is used for any item or node that can be locked using a key, the locked item is created
using the locksmith's table.
]]
yatm_mail.lockable_object_schema = yatm_core.MetaSchema.new("lockable_object", "", {
  -- Lockable objects have a public key, this ensures that the private key
  -- (attached to the key itself) is never exposed, now since I don't actually have
  -- a crypto library, it's just the same string copied around for now.
  pubkey = {
    type = "string",
  },
})

yatm_mail.lockable_key_schema = yatm_core.MetaSchema.new("lockable_key", "", {
  -- Lockable Key objects have a private key, this will be used to generate the public key upon request
  -- for matching.
  prvkey = {
    type = "string",
  },
})

-- Determines if the given item is a lock, locks are just boring single use items for the locksmith table.
function yatm_mail.item_is_lock(item)
  if item then
    return item.groups.lockable_lock or 0 > 0
  else
    -- it was null, it's not a lock then.
    return false
  end
end

function yatm_mail.item_is_key(item)
  if item then
    return (item.groups.lockable_key or 0) > 0
  else
    return false
  end
end

function yatm_mail.item_is_blank_key(item)
  if item then
    return (item.groups.blank_key or 0) > 0
  else
    return false
  end
end

function yatm_mail.item_is_toothed_key(item)
  if item then
    return (item.groups.toothed_key or 0) > 0
  else
    return false
  end
end

function yatm_mail.item_is_lockable_object(item)
  if item then
    return (item.groups.lockable_object or 0) > 0
  else
    return false
  end
end

function yatm_mail.is_stack_lockable_lock(stack)
  if stack then
    local item = minetest.registered_items[stack:get_name()]
    return yatm_mail.item_is_lock(item)
  else
    return false
  end
end

function yatm_mail.is_stack_lockable_blank_key(stack)
  if stack then
    local item = minetest.registered_items[stack:get_name()]
    return yatm_mail.item_is_blank_key(item)
  else
    return false
  end
end

function yatm_mail.is_stack_lockable_toothed_key(stack)
  if stack then
    local item = minetest.registered_items[stack:get_name()]
    return yatm_mail.item_is_toothed_key(item)
  else
    return false
  end
end

function yatm_mail.is_stack_lockable_object(stack)
  if stack then
    local item = minetest.registered_items[stack:get_name()]
    return yatm_mail.item_is_lockable_object(item)
  else
    return false
  end
end

local LOCKABLE_BASENAME = "lk" -- please don't tamper with this

function yatm_mail.get_lockable_key_key(meta)
  assert(meta, "expected a meta")
  return yatm_mail.lockable_key_schema:get_field(meta, LOCKABLE_BASENAME, "prvkey")
end

function yatm_mail.set_lockable_key_key(meta, prvkey)
  assert(meta, "expected a meta")
  yatm_mail.lockable_key_schema:set_field(meta, LOCKABLE_BASENAME, "prvkey", prvkey)
end

function yatm_mail.copy_lockable_key_key(src_meta, dest_meta)
  assert(src_meta, "expected a source meta")
  assert(dest_meta, "expected a destination meta")
  local key = yatm_mail.get_lockable_key_key(src_meta)
  yatm_mail.set_lockable_key_key(dest_meta, key)
end

function yatm_mail.get_lockable_object_key(meta)
  assert(meta, "expected a meta")
  return yatm_mail.lockable_object_schema:get_field(meta, LOCKABLE_BASENAME, "pubkey")
end

function yatm_mail.set_lockable_object_key(meta, pubkey)
  yatm_mail.lockable_object_schema:set_field(meta, LOCKABLE_BASENAME, "pubkey", pubkey)
end

function yatm_mail.copy_lockable_object_key(src_meta, dest_meta)
  assert(src_meta, "expected a source meta")
  assert(dest_meta, "expected a destination meta")
  local key = yatm_mail.get_lockable_object_key(src_meta)
  yatm_mail.set_lockable_object_key(dest_meta, key)
end

function yatm_mail.get_lockable_key_stack_key(stack)
  local meta = stack:get_meta()
  return yatm_mail.get_lockable_key_key(meta)
end

function yatm_mail.get_lockable_object_stack_key(stack)
  local meta = stack:get_meta()
  return yatm_mail.get_lockable_object_key(meta)
end

function yatm_mail.set_lockable_key_stack_key(stack, prvkey)
  local meta = stack:get_meta()
  yatm_mail.set_lockable_key_key(meta, prvkey)
  return stack
end

function yatm_mail.set_lockable_object_stack_key(stack, pubkey)
  local meta = stack:get_meta()
  yatm_mail.set_lockable_object_key(meta, pubkey)
  return stack
end

function yatm_mail.copy_lockable_key_stack_key(src, dest)
  local key = yatm_mail.get_lockable_key_stack_key(src)
  yatm_mail.set_lockable_key_stack_key(dest, key)
end

function yatm_mail.prvkey_to_pubkey(prvkey)
  return prvkey -- yeah... nothing fancy here
end

function yatm_mail.gen_private_key()
  return yatm_core.random_string(64)
end

function yatm_mail.pair_lockables(key_stack, object_stack, prvkey)
  assert(key_stack, "expected a key stack")
  assert(object_stack, "expected an object stack")
  local prvkey = prvkey or yatm_mail.gen_private_key()
  local pubkey = yatm_mail.prvkey_to_pubkey(prvkey)
  yatm_mail.set_lockable_key_stack_key(key_stack, prvkey)
  yatm_mail.set_lockable_object_stack_key(object_stack, pubkey)

  -- TODO: move this stuff elsewhere
  yatm_core.set_itemstack_meta_description(object_stack, yatm_core.get_itemstack_description(object_stack) .. " [Locked]")
  local key_description =
    yatm_core.get_itemstack_description(key_stack) ..
    " paired with " ..
    yatm_core.get_itemstack_description(object_stack)
  yatm_core.set_itemstack_meta_description(key_stack, key_description)
end

function yatm_mail.is_stack_a_key_for_locked_stack(key_stack, lockable_stack)
  -- Only toothed keys can be used to unlock something
  if yatm_mail.is_stack_lockable_toothed_key(key_stack) then
    -- And only lockable_objects can be unlocked
    if yatm_mail.is_stack_lockable_object(lockable_stack) then
      local prvkey = yatm_mail.get_lockable_key_stack_key(key_stack)
      local pubkey = yatm_mail.get_lockable_object_stack_key(key_stack)

      if pubkey and prvkey then
        -- both keys are present, we can match
        return pubkey == prvkey
      else
        -- one or more of the keys were nil, we can't match that
        return false
      end
    end
  end
  return false
end

function yatm_mail.is_stack_a_key_for_locked_node(stack, pos)
  -- Only toothed keys can be used to unlock something
  if yatm_mail.is_stack_lockable_toothed_key(stack) then
    -- And only lockable_objects can be unlocked
    local lockable_node = minetest.get_node(pos)
    local lockable_nodedef = minetest.registered_nodes[lockable_node.name]
    if yatm_mail.item_is_lockable_object(lockable_nodedef) then
      local prvkey = yatm_mail.get_lockable_key_stack_key(stack)

      local lockable_meta = minetest.get_meta(pos)
      local pubkey = yatm_mail.get_lockable_object_key(lockable_meta)

      if pubkey and prvkey then
        -- both keys are present, we can match
        return pubkey == prvkey
      else
        -- one or more of the keys were nil, we can't match that
        return false
      end
    else
      print("node was not a lockable object", yatm_core.vec3_to_string(pos), lockable_node.name)
    end
  else
    print("stack was not a toothed key: ", yatm_core.inspect_itemstack(stack))
  end
  return false
end
