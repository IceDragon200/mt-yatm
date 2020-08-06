local MetaSchema = assert(foundation.com.MetaSchema)
local Groups = assert(foundation.com.Groups)
local random_string62 = assert(foundation.com.random_string62)
local set_itemstack_meta_description = assert(foundation.com.set_itemstack_meta_description)
local get_itemstack_description = assert(foundation.com.get_itemstack_description)
local get_itemstack_item_description = assert(foundation.com.get_itemstack_item_description)
local is_blank = assert(foundation.com.is_blank)
local itemstack_inspect = assert(foundation.com.itemstack_inspect)

--
-- `lockable` is used for any item or node that can be locked using a key, the locked item is created
-- using the locksmith's table.
--
local lockable_object_schema = MetaSchema:new("lockable_object", "", {
  -- Lockable objects have a public key, this ensures that the private key
  -- (attached to the key itself) is never exposed, now since I don't actually have
  -- a crypto library, it's just the same string copied around for now.
  pubkey = {
    type = "string",
  },
})

local lockable_key_schema = MetaSchema:new("lockable_key", "", {
  -- Lockable Key objects have a private key, this will be used to generate the public key upon request
  -- for matching.
  prvkey = {
    type = "string",
  },
})

local chipped_object_schema = MetaSchema:new("chipped_object", "", {
  chip_item = {
    type = "string",
  },
  pubkey = {
    type = "string",
  },
})

local access_chip_schema = MetaSchema:new("access_chip", "", {
  pubkey = {
    type = "string",
  },
})

local access_card_schema = MetaSchema:new("access_card", "", {
  prvkey = {
    type = "string",
  },
})

local LOCKABLE_BASENAME = "lk" -- please don't tamper with this
local ACCESS_BASENAME = "aclk" -- please don't tamper with this

yatm_security.lockable_object_schema = lockable_object_schema:compile(LOCKABLE_BASENAME)
yatm_security.lockable_key_schema = lockable_key_schema:compile(LOCKABLE_BASENAME)

yatm_security.chipped_object_schema = chipped_object_schema:compile(ACCESS_BASENAME)
yatm_security.access_chip_schema = access_chip_schema:compile(ACCESS_BASENAME)
yatm_security.access_card_schema = access_card_schema:compile(ACCESS_BASENAME)

-- Determines if the given item is a lock, locks are just boring single use items for the locksmith table.
function yatm_security.item_is_lock(item)
  if item then
    return Groups.has_group(item, "lockable_lock")
  end
  return false
end

function yatm_security.item_is_access_card(item)
  if item then
    return Groups.has_group(item, "access_card")
  end
  return false
end

-- Determines if the given item is a access chip, access chips are paired before hand using a programmer's table
function yatm_security.item_is_access_chip(item)
  if item then
    return Groups.has_group(item, "access_chip")
  end
  -- it was null, it's not a access chip then.
  return false
end

function yatm_security.item_is_key(item)
  if item then
    return Groups.has_group(item, "lockable_key")
  end
  return false
end

function yatm_security.item_is_blank_key(item)
  if item then
    return Groups.has_group(item, "blank_key")
  end
  return false
end

function yatm_security.item_is_toothed_key(item)
  if item then
    return Groups.has_group(item, "toothed_key")
  end
  return false
end

function yatm_security.item_is_chippable_object(item)
  if item then
    return Groups.has_group(item, "chippable_object")
  end
  return false
end

function yatm_security.item_is_lockable_object(item)
  if item then
    return Groups.has_group(item, "lockable_object")
  end
  return false
end

function yatm_security.is_stack_lockable_lock(stack)
  if stack then
    return yatm_security.item_is_lock(stack:get_definition())
  end
  return false
end

function yatm_security.is_stack_access_card(stack)
  if stack then
    return yatm_security.item_is_access_card(stack:get_definition())
  end
  return false
end

function yatm_security.is_stack_access_chip(stack)
  if stack then
    return yatm_security.item_is_access_chip(stack:get_definition())
  end
  return false
end

function yatm_security.is_stack_chippable_object(stack)
  if stack then
    return yatm_security.item_is_chippable_object(stack:get_definition())
  end
  return false
end

function yatm_security.is_stack_lockable_blank_key(stack)
  if stack then
    return yatm_security.item_is_blank_key(stack:get_definition())
  end
  return false
end

function yatm_security.is_stack_lockable_toothed_key(stack)
  if stack then
    return yatm_security.item_is_toothed_key(stack:get_definition())
  end
  return false
end

function yatm_security.is_stack_lockable_object(stack)
  if stack then
    return yatm_security.item_is_lockable_object(stack:get_definition())
  end
  return false
end

--
-- Lockable Key (meta)
--
function yatm_security.get_lockable_key_prvkey(meta)
  assert(meta, "expected a meta")
  return yatm_security.lockable_key_schema:get_prvkey(meta)
end

function yatm_security.set_lockable_key_prvkey(meta, prvkey)
  assert(meta, "expected a meta")
  yatm_security.lockable_key_schema:set_prvkey(meta, prvkey)
end

function yatm_security.copy_lockable_key_prvkey(src_meta, dest_meta)
  assert(src_meta, "expected a source meta")
  assert(dest_meta, "expected a destination meta")
  local key = yatm_security.get_lockable_key_prvkey(src_meta)
  yatm_security.set_lockable_key_prvkey(dest_meta, key)
  return dest_meta
end

--
-- Lockable Object (meta)
--
function yatm_security.get_lockable_object_pubkey(meta)
  assert(meta, "expected a meta")
  return yatm_security.lockable_object_schema:get_pubkey(meta)
end

function yatm_security.set_lockable_object_pubkey(meta, pubkey)
  yatm_security.lockable_object_schema:set_pubkey(meta, pubkey)
  return meta
end

function yatm_security.copy_lockable_object_pubkey(src_meta, dest_meta)
  assert(src_meta, "expected a source meta")
  assert(dest_meta, "expected a destination meta")
  local key = yatm_security.get_lockable_object_pubkey(src_meta)
  yatm_security.set_lockable_object_pubkey(dest_meta, key)
end

--
-- Chipped Object (meta)
--
function yatm_security.get_chipped_object_chip_item(meta)
  return yatm_security.chipped_object_schema:get_chip_item(meta)
end

function yatm_security.set_chipped_object_chip_item(meta, chip_item)
  yatm_security.chipped_object_schema:set_chip_item(meta, chip_item)
  return meta
end

function yatm_security.copy_chipped_object_chip_item(src_meta, dest_meta)
  assert(src_meta, "expected a source meta")
  assert(dest_meta, "expected a destination meta")
  local chip_item = yatm_security.get_chipped_object_chip_item(src_meta)
  yatm_security.set_chipped_object_chip_item(dest_meta, chip_item)
end

function yatm_security.get_chipped_object_pubkey(meta)
  return yatm_security.chipped_object_schema:get_pubkey(meta)
end

function yatm_security.set_chipped_object_pubkey(meta, pubkey)
  yatm_security.chipped_object_schema:set_pubkey(meta, pubkey)
  return meta
end

function yatm_security.copy_chipped_object_pubkey(src_meta, dest_meta)
  assert(src_meta, "expected a source meta")
  assert(dest_meta, "expected a destination meta")
  local pubkey = yatm_security.get_chipped_object_pubkey(src_meta)
  yatm_security.set_chipped_object_pubkey(dest_meta, pubkey)
end

function yatm_security.copy_chipped_object(src_meta, dest_meta)
  yatm_security.copy_chipped_object_chip_item(src_meta, dest_meta)
  yatm_security.copy_chipped_object_pubkey(src_meta, dest_meta)
end

--
-- Access Card (meta)
--
function yatm_security.get_access_card_prvkey(meta)
  return yatm_security.access_card_schema:get_prvkey(meta)
end

function yatm_security.set_access_card_prvkey(meta, prvkey)
  yatm_security.access_card_schema:set_prvkey(meta, prvkey)
  return meta
end

--
-- Access Chip (meta)
--
function yatm_security.get_access_chip_pubkey(meta)
  return yatm_security.access_chip_schema:get_pubkey(meta)
end

function yatm_security.set_access_chip_pubkey(meta, pubkey)
  yatm_security.access_chip_schema:set_pubkey(meta, pubkey)
  return meta
end

--
-- Lockable Key Stack
--
function yatm_security.get_lockable_key_stack_prvkey(stack)
  local meta = stack:get_meta()
  return yatm_security.get_lockable_key_prvkey(meta)
end

function yatm_security.set_lockable_key_stack_prvkey(stack, prvkey)
  local meta = stack:get_meta()
  yatm_security.set_lockable_key_prvkey(meta, prvkey)
  return stack
end

function yatm_security.copy_lockable_key_stack_prvkey(src, dest)
  local key = yatm_security.get_lockable_key_stack_prvkey(src)
  yatm_security.set_lockable_key_stack_prvkey(dest, key)
end

--
-- Lockable Object Stack
--
function yatm_security.get_lockable_object_stack_pubkey(stack)
  return yatm_security.get_lockable_object_pubkey(stack:get_meta())
end

function yatm_security.set_lockable_object_stack_pubkey(stack, pubkey)
  yatm_security.set_lockable_object_pubkey(stack:get_meta(), pubkey)
  return stack
end

--
-- Chippable Object Stack
--
function yatm_security.get_chipped_object_stack_pubkey(stack)
  return yatm_security.get_chipped_object_pubkey(stack:get_meta())
end

function yatm_security.set_chipped_object_stack_pubkey(stack, pubkey)
  yatm_security.set_chipped_object_pubkey(stack:get_meta(), pubkey)
  return stack
end

function yatm_security.get_chipped_object_stack_chip_item(stack)
  return yatm_security.get_chipped_object_chip_item(stack:get_meta())
end

function yatm_security.set_chipped_object_stack_chip_item(stack, chip_item)
  yatm_security.set_chipped_object_chip_item(stack:get_meta(), chip_item)
  return stack
end

--
-- Access Card Stack
--
function yatm_security.get_access_card_stack_prvkey(stack)
  return yatm_security.get_access_card_prvkey(stack:get_meta())
end

function yatm_security.set_access_card_stack_prvkey(stack, prvkey)
  yatm_security.set_access_card_prvkey(stack:get_meta(), prvkey)
  return stack
end

--
-- Access Chip Stack
--
function yatm_security.get_access_chip_stack_pubkey(stack)
  return yatm_security.get_access_chip_pubkey(stack:get_meta())
end

function yatm_security.set_access_chip_stack_pubkey(stack, pubkey)
  yatm_security.set_access_chip_pubkey(stack:get_meta(), pubkey)
  return stack
end

--
-- Chip Installation
--
function yatm_security.install_chip(chippable_stack, chip_stack)
  local pubkey = yatm_security.get_access_chip_stack_pubkey(chip_stack)

  yatm_security.set_chipped_object_stack_pubkey(chippable_stack, pubkey)
  yatm_security.set_chipped_object_stack_chip_item(chippable_stack, chip_stack:to_string())

  set_itemstack_meta_description(
    chippable_stack,
    get_itemstack_description(chippable_stack) .. " [Chip Locked]")

  return chippable_stack
end

--
-- Lock Installation
--
function yatm_security.pair_lockables(key_stack, object_stack, prvkey)
  assert(key_stack, "expected a key stack")
  assert(object_stack, "expected an object stack")
  local prvkey = prvkey or yatm_security.gen_prvkey()
  local pubkey = yatm_security.prvkey_to_pubkey(prvkey)
  yatm_security.set_lockable_key_stack_prvkey(key_stack, prvkey)
  yatm_security.set_lockable_object_stack_pubkey(object_stack, pubkey)

  -- TODO: move this stuff elsewhere
  set_itemstack_meta_description(object_stack, get_itemstack_description(object_stack) .. " [Locked]")
  local key_description =
    get_itemstack_item_description(key_stack) ..
    "\nPaired with " ..
    get_itemstack_description(object_stack)
  set_itemstack_meta_description(key_stack, key_description)
end

--
--
--
function yatm_security.prvkey_to_pubkey(prvkey)
  return prvkey -- yeah... nothing fancy here
end

function yatm_security.gen_prvkey()
  return random_string62(64)
end

function yatm_security.compare_keys(prvkey, pubkey)
  if pubkey and prvkey then
    -- both keys are present, we can match
    return pubkey == prvkey
  else
    -- one or more of the keys were nil, we can't match that
    return false
  end
end

--
-- Lockable Lock Check
--
function yatm_security.is_stack_a_key_for_locked_stack(key_stack, lockable_stack)
  -- Only toothed keys can be used to unlock a locked thing
  if yatm_security.is_stack_lockable_toothed_key(key_stack) then
    -- And only lockable_objects can be unlocked
    if yatm_security.is_stack_lockable_object(lockable_stack) then
      local prvkey = yatm_security.get_lockable_key_stack_prvkey(key_stack)
      local pubkey = yatm_security.get_lockable_object_stack_pubkey(key_stack)

      return yatm_security.compare_keys(prvkey, pubkey)
    end
  end
  return false
end

function yatm_security.is_lockable_node(pos)
  local lockable_node = minetest.get_node(pos)
  local lockable_nodedef = minetest.registered_nodes[lockable_node.name]

  if yatm_security.item_is_lockable_object(lockable_nodedef) then
    local lockable_meta = minetest.get_meta(pos)
    local pubkey = yatm_security.get_lockable_object_pubkey(lockable_meta)

    return not is_blank(pubkey)
  end

  return false
end

function yatm_security.is_stack_a_key_for_locked_node(stack, pos)
  -- Only toothed keys can be used to unlock something
  if yatm_security.is_stack_lockable_toothed_key(stack) then
    -- And only lockable_objects can be unlocked
    local lockable_node = minetest.get_node(pos)
    local lockable_nodedef = minetest.registered_nodes[lockable_node.name]
    if yatm_security.item_is_lockable_object(lockable_nodedef) then
      local prvkey = yatm_security.get_lockable_key_stack_prvkey(stack)

      local lockable_meta = minetest.get_meta(pos)
      local pubkey = yatm_security.get_lockable_object_pubkey(lockable_meta)

      return yatm_security.compare_keys(prvkey, pubkey)
    else
      print("node was not a lockable object", minetest.pos_to_string(pos), lockable_node.name)
    end
  else
    print("stack was not a toothed key: ", itemstack_inspect(stack))
  end
  return false
end

--
-- Chippable Access Card Check
--
function yatm_security.is_access_card_for_chipped_stack(access_card_stack, chipped_stack)
  assert(access_card_stack, "expected an access_card_stack")

  -- And only access cards can be used to access something with an access chip installed
  if yatm_security.is_stack_access_card(key_stack) then
    if yatm_security.is_stack_chippable_object(lockable_stack) then
      local prvkey = yatm_security.get_access_card_stack_prvkey(access_card_stack)
      local pubkey = yatm_security.get_chipped_object_stack_pubkey(chipped_stack)

      return yatm_security.compare_keys(prvkey, pubkey)
    end
  end
  return false
end

function yatm_security.is_chipped_node(pos)
  local chipped_node = minetest.get_node(pos)
  local chipped_nodedef = minetest.registered_nodes[chipped_node.name]

  if yatm_security.item_is_chippable_object(chipped_nodedef) then
    local chipped_meta = minetest.get_meta(pos)
    local pubkey = yatm_security.get_chipped_object_pubkey(chipped_meta)

    return not is_blank(pubkey)
  end

  return false
end

function yatm_security.is_stack_an_access_card_for_chipped_node(access_card_stack, pos)
  assert(access_card_stack, "expected an access_card_stack")
  -- Only toothed keys can be used to unlock something
  if yatm_security.is_stack_access_card(access_card_stack) then
    -- And only chipped_objects can be unlocked
    local chipped_node = minetest.get_node(pos)
    local chipped_nodedef = minetest.registered_nodes[chipped_node.name]
    if yatm_security.item_is_chippable_object(chipped_nodedef) then
      local prvkey = yatm_security.get_access_card_stack_prvkey(access_card_stack)

      local chipped_meta = minetest.get_meta(pos)
      local pubkey = yatm_security.get_chipped_object_pubkey(chipped_meta)

      return yatm_security.compare_keys(prvkey, pubkey)
    else
      print("node was not a chipped object", minetest.pos_to_string(pos), chipped_node.name)
    end
  else
    print("stack was not an access card: ", itemstack_inspect(access_card_stack))
  end
  return false
end
