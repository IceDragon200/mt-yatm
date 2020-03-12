yatm.security = yatm.security or {}

local SecuritySlotSchema = yatm.MetaSchema:new("SecuritySlotSchema", "", {
  version = {
    type = "integer",
  },
  feature_name = {
    type = "string"
  },
})

-- @type SecurityFeatureDefinition :: {
--   get_node_slot_data = function (self: SecurityFeatureDefinition,
--                                  pos: Vector,
--                                  node: NodeRef,
--                                  slot_data: Table) :: (slot_data :: Table),
--   check_node_lock = function (self: SecurityFeatureDefinition,
--                               pos: Vector,
--                               node: NodeRef,
--                               player: ObjectRef,
--                               slot_id: String,
--                               slot_data: Table,
--                               data: Table) :: (yatm.security.AccessFlag, Function | nil | String),
--   get_object_slot_data = function (self: SecurityFeatureDefinition,
--                                    object: ObjectRef,
--                                    slot_data: Table) :: (slot_data :: Table),
--   check_object_lock = function (self: SecurityFeatureDefinition,
--                                 object: ObjectRef,
--                                 player: ObjectRef,
--                                 slot_id: String,
--                                 slot_data: Table,
--                                 data: Table) :: (yatm.security.AccessFlag, Function | nil | String),
-- }
-- @spec { [name :: String] = SecurityFeatureDefinition }
yatm.security.registered_security_features = {}

-- Register new security features with register_security_feature
-- @spec register_security_feature(name: String, definition: Table) :: void
function yatm.security.register_security_feature(name, definition)
  assert(type(name) == "string", "expected a name for security feature")
  assert(type(definition) == "table", "expected a table defining security feature properties")

  if yatm.security.registered_security_features[name] then
    error("security feature name='" .. name .. "' is already registered")
  end

  assert(type(definition.check_node_lock) == "function", "expected check_node_lock/7 function")
  assert(type(definition.check_object_lock) == "function", "expected check_object_lock/6 function")

  yatm.security.registered_security_features[name] = definition
end

-- Remove existing features with unregister_security_feature
-- @spec unregister_security_feature(name: String) :: void
function yatm.security.unregister_security_feature(name)
  yatm.security.registered_security_features[name] = nil
end

-- Retrieve a feature by it's name
-- @spec get_security_feature(name: String) :: Table | nil
function yatm.security.get_security_feature(name)
  return yatm.security.registered_security_features[name]
end

-- NOTHING to be done
yatm.security.NOTHING = 0
-- It is OK to use
yatm.security.OK = 1
-- Permission was REJECTed
yatm.security.REJECT = 2
-- The object requires additional action from the caller
yatm.security.NEEDS_ACTION = 4
-- The object requests that the caller continue calling the transaction
yatm.security.CONTINUE = 8

local SecurityTransaction = yatm_core.Class:extends()
local ic = SecurityTransaction.instance_class

function ic:initialize(id, info, callback)
  self.id = id
  self.info = info
  self.slot_index = 0
  self.assigns = {}
  self.held = false
  self.callback = callback

  minetest.log("action", "New SecurityTransaction id=" .. id)
end

function ic:continue()
  if not self.held then
    self.slot_index = self.slot_index + 1
  end
  self.held = false

  local slot_id = self.info.slots[self.slot_index]
  if slot_id then
    local slot_data
    local is_node = self.info.kind == "node"

    if is_node then
      local meta = minetest.get_meta(self.info.pos)
      slot_data = SecuritySlotSchema:get(meta, slot_id)
    elseif self.info.kind == "object" then
      error("TODO: get security slot data for object")
    end

    if yatm_core.string_empty(slot_data.feature_name) then
      return yatm.security.CONTINUE
    else
      local security_feature = yatm.security.get_security_feature(slot_data.feature_name)

      if security_feature then
        local player = minetest.get_player_by_name(self.info.player_name)

        if is_node then
          local pos = self.info.pos
          local node = self.info.node
          if security_feature.get_node_slot_data then
            -- (maybe) Retrieve additional slot data
            slot_data = security_feature:get_node_slot_data(pos, node, slot_data)
          end
          local result, extra = security_feature:check_node_lock(pos, node, player, slot_id, slot_data, self.assigns)
          if result == yatm.security.OK then
            -- continue like normal
            return yatm.security.CONTINUE
          elseif result == yatm.security.REJECT then
            -- extra is the reason
            return yatm.security.REJECT, extra
          elseif result == yatm.security.NEEDS_ACTION then
            --
            extra(pos, node, player, slot_id, slot_data, self.assigns, self:method("continue"))
            self.held = true
            return yatm.security.NEEDS_ACTION
          else
            error("unxepected result from check_node_lock/6 node_name=" .. node.name)
          end
        else
          local object = self.info.object
          if security_feature.get_object_slot_data then
            -- (maybe) Retrieve additional slot data
            slot_data = security_feature:get_object_slot_data(object, slot_data)
          end
          local result, extra = security_feature:check_object_lock(object, player, slot_id, slot_data, self.assigns)
          if result == yatm.security.OK then
            -- continue like normal
            return yatm.security.CONTINUE
          elseif result == yatm.security.REJECT then
            -- extra is the reason
            return yatm.security.REJECT, extra
          elseif result == yatm.security.NEEDS_ACTION then
            --
            extra(object, slot_id, slot_data, self.assigns, self:method("continue"))
            self.held = true
            return yatm.security.NEEDS_ACTION
          else
            error("unxepected result from check_object_lock/5 object=" .. object.name)
          end
        end
      else
        minetest.log("warning", "missing security_feature name=" .. slot_data.feature_name)
        return yatm.security.CONTINUE
      end
    end
  else
    minetest.log("action", "Security Transaction completed id=" .. self.id)
    self.callback()
    return yatm.security.OK
  end
end

yatm.security.SecurityContext = yatm_core.Class:extends()
local ic = yatm.security.SecurityContext.instance_class

function ic:initialize()
  self.g_transaction_id = 0
end

function ic:create_transaction(info, callback)
  self.g_transaction_id = self.g_transaction_id + 1
  local transaction_id = self.g_transaction_id
  local transaction = SecurityTransaction:new(transaction_id, info, callback)
  return transaction
end

yatm.security.context = SecurityContext:new()

-- Trigger check_node_lock for a specific feature
-- @spec security_feature_check_node_lock(feature_name: String,
--                                        pos: Vector,
--                                        node: NodeRef,
--                                        player: ObjectRef,
--                                        slot_id: String,
--                                        slot_data: Table,
--                                        data: Table) :: (AccessFlag, Function | nil | String)
function yatm.security.security_feature_check_node_lock(feature_name, pos, node, player, slot_id, slot_data, data)
  local security_feature = yatm.security.registered_security_features[feature_name]
  assert(security_feature, "expected security_feature to exist")
  return security_feature:check_node_lock(pos, node, player, slot_id, slot_data, data)
end

-- @spec security_feature_check_object_lock(feature_name: String,
--                                          object: ObjectRef,
--                                          player: ObjectRef,
--                                          slot_id: String,
--                                          slot_data: Table,
--                                          data: Table) :: (AccessFlag, Function | nil | String)
function yatm.security.security_feature_check_object_lock(feature_name, object, player, slot_id, slot_data, data)
  local security_feature = yatm.security.registered_security_features[feature_name]
  assert(security_feature, "expected security_feature to exist")
  return security_feature:check_object_lock(object, player, slot_id, slot_data, data)
end

-- @spec get_node_slots(pos: Vector, node: NodeRef) :: Table | nil
function yatm.security.get_node_slots(pos, node)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef then
    if nodedef.security then
      local slots = nodedef.security.slots
      if type(slots) == "table" then
        return slots
      elseif type(slots) == "function" then
        return slots(pos, node)
      else
        error("expected slots to be a table or function")
      end
    end
  end
  return nil
end

-- @spec get_object_slots(object: ObjectRef) :: Table | nil
function yatm.security.get_object_slots(object)
  local lua_entity = object:get_luaentity()
  if lua_entity and lua_entity.security then
    local slots = lua_entity.security.slots
    if type(slots) == "table" then
      return slots
    elseif type(slots) == "function" then
      return slots(pos, node)
    else
      error("expected slots to be a table or function")
    end
  end
  return nil
end

-- The execute_* functions will take a callback function which should perform the
-- normal action.
-- check_* functions will return the result from check_lock function on the feature,
-- it's up to the caller to deal with the result

--
-- @spec check_node_locks(pos: Vector, callback: Function) :: (AccessFlag, Function | nil | String, SecurityTransaction)
function yatm.security.check_node_locks(pos, callback)
  local node = minetest.get_node_or_nil(pos)
  if node then
    local slots = yatm.security.get_node_slots(pos, node)

    if slots and not yatm_core.is_table_empty(slots) then
      local security_transaction =
        yatm.security.context:create_transaction({
          kind = "node",
          slots = slots,
          pos = pos,
          node = node,
          player_name = player:get_player_name(),
        }, callback)

      while true do
        local result, extra = security_transaction:continue()

        if result == yatm.security.CONTINUE then
          --
        elseif result == yatm.security.OK then
          return result, nil, security_transaction
        elseif result == yatm.security.REJECT or result == yatm.security.NEEDS_ACTION then
          return result, extra, security_transaction
        else
          error("unxepected response")
        end
      end
    end
  end
  return yatm.security.NOTHING, nil, nil
end

-- Check all locks on given object
-- Use this when all locks need to be checked at once
-- @spec execute_check_object_locks(object: ObjectRef, callback: Function) :: void
function yatm.security.execute_check_object_locks(object, callback)
end

-- @spec check_object_locks(object: ObjectRef) :: (AccessFlag, Function | nil | String)
function yatm.security.check_object_locks(object)
end

-- Check a specific lock on a specific node
-- @spec execute_check_node_lock(pos: Vector, slot_id: String, callback: Function) :: void
function yatm.security.execute_check_node_lock(pos, slot_id, callback)
end

-- @spec check_node_lock(pos: Vector, slot_id: String) :: (AccessFlag, Function | nil | String)
function yatm.security.check_node_lock(pos, slot_id)
end

-- Check a specific lock on given object
-- @spec execute_check_object_lock(object: ObjectRef, slot_id: String, callback: Function) :: void
function yatm.security.execute_check_object_lock(object, slot_id, callback)
end

-- @spec check_object_lock(object: ObjectRef, slot_id: String) :: (AccessFlag, Function | nil | String)
function yatm.security.check_object_lock(object, slot_id)
end

-- Check for presence of locks with:
-- @spec has_node_locks(pos: Vector) :: Boolean
function yatm.security.has_node_locks(pos)
end

-- @spec has_node_lock(pos: Vector, slot_id: String) :: Boolean
function yatm.security.has_node_lock(pos, slot_id)
end

-- @spec has_object_locks(object: ObjectRef) :: Boolean
function yatm.security.has_object_locks(object)
end

-- @spec has_object_lock(object: ObjectRef, slot_id: String) :: Boolean
function yatm.security.has_object_lock(object, slot_id)
end

-- Retrieve information on a node's locks with the functions below:
-- This retrieves ALL locks on the specific node, the table is indexed by the slot_id
-- @spec get_node_locks(pos: Vector) :: Table<String, Table> | nil
function yatm.security.get_node_locks(pos)
end

-- Retrieves the data for the specific lock
-- @spec get_node_lock(pos: Vector, slot_id: String) :: Table | nil
function yatm.security.get_node_lock(pos, slot_id)
end

-- @spec get_object_locks(object: ObjectRef) :: Table<String, Table> | nil
function yatm.security.get_object_locks(object)
end

-- @spec get_object_lock(object: ObjectRef, slot_id: String) :: Table | nil
function yatm.security.get_object_lock(object, slot_id)
end
