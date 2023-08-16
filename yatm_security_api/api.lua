--- @namespace yatm.security
local string_empty = assert(foundation.com.string_empty)
local is_table_empty = assert(foundation.com.is_table_empty)
local MetaSchema = assert(foundation.com.MetaSchema)

yatm.security = yatm.security or {}

local SecuritySlotSchema = MetaSchema:new("SecuritySlotSchema", "", {
  version = {
    type = "integer",
  },
  feature_name = {
    type = "string"
  },
  -- Any optional parameters that can be used by the security slot
  param1 = {
    type = "string"
  },
  param2 = {
    type = "string"
  },
})

--- @const SecuritySlotSchema: MetaSchema
yatm.security.SecuritySlotSchema = SecuritySlotSchema

---
--- @type AccessFlag: Any

--- Error codes returned by various action functions
--- @type ErrorCode: Any

--- @type SecurityFeatureDefinition: {
---   install_node_slot_feature: function (
---     self: SecurityFeatureDefinition,
---     pos: Vector3,
---     node: NodeRef,
---     slot_id: String,
---     params: Table
---   ) => (success: Boolean, ErrorCode?),
---
---   get_node_slot_data: function (
---     self: SecurityFeatureDefinition,
---     pos: Vector3,
---     node: NodeRef,
---     slot_data: Table
---   ) => (slot_data: Table),
---
---   check_node_lock: function (
---     self: SecurityFeatureDefinition,
---     pos: Vector3,
---     node: NodeRef,
---     player: ObjectRef,
---     slot_id: String,
---     slot_data: Table,
---     data: Table
---   ) => (AccessFlag, Function | nil | String),
---
---   get_object_slot_data: function (
---     self: SecurityFeatureDefinition,
---     object: ObjectRef,
---     slot_data: Table
---   ) => (slot_data: Table),
---
---   check_object_lock: function (
---     self: SecurityFeatureDefinition,
---     object: ObjectRef,
---     player: ObjectRef,
---     slot_id: String,
---     slot_data: Table,
---     data: Table
---   ) => (AccessFlag, Function | nil | String),
--- }

--- @type RegisteredSecurityFeatures: { [name: String]: SecurityFeatureDefinition }

--- @const registered_security_features: RegisteredSecurityFeatures
yatm.security.registered_security_features = {}

--- Register new security features with register_security_feature
---
--- @spec register_security_feature(name: String, definition: Table): void
function yatm.security:register_security_feature(name, definition)
  assert(type(name) == "string", "expected a name for security feature")
  assert(type(definition) == "table", "expected a table defining security feature properties")

  if self.registered_security_features[name] then
    error("security feature name='" .. name .. "' is already registered")
  end

  assert(type(definition.check_node_lock) == "function", "expected #check_node_lock/6 function for name="..name)
  assert(type(definition.check_object_lock) == "function", "expected #check_object_lock/5 function for name="..name)
  assert(type(definition.install_node_slot_feature) == "function", "expected #install_node_slot_feature/4 function for name="..name)

  definition.name = name

  self.registered_security_features[name] = definition
end

--- Remove existing features with unregister_security_feature
---
--- @spec unregister_security_feature(name: String): void
function yatm.security:unregister_security_feature(name)
  self.registered_security_features[name] = nil
end

--- Retrieve a feature by it's name
---
--- @spec get_security_feature(name: String): Table | nil
function yatm.security:get_security_feature(name)
  assert(name, "expected a name")
  return self.registered_security_features[name]
end

--- NOTHING to be done
--- @const NOTHING: AccessFlag
yatm.security.NOTHING = 'NOTHING'
--- It is OK to use
--- @const OK: AccessFlag
yatm.security.OK = 'OK'
--- Permission was REJECTed
--- @const REJECT: AccessFlag
yatm.security.REJECT = 'REJECT'
--- The object requires additional action from the caller
--- @const NEEDS_ACTION: AccessFlag
yatm.security.NEEDS_ACTION = 'NEEDS_ACTION'
--- The object requests that the caller continue calling the transaction
--- @const CONTINUE: AccessFlag
yatm.security.CONTINUE = 'CONTINUE'
--- @const COMPLETED: AccessFlag
yatm.security.COMPLETED = 'COMPLETED'
--- The node's corresponding definition does not exist
--- @const ERR_NODE_NOT_FOUND: ErrorCode
yatm.security.ERR_NODE_NOT_FOUND = 'ERR_NODE_NOT_FOUND'
--- The node does not support security features
--- @const ERR_NOT_A_SECURABLE_NODE: ErrorCode
yatm.security.ERR_NOT_A_SECURABLE_NODE = 'ERR_NOT_A_SECURABLE_NODE'
---
--- @const ERR_INSTALL_FEATURE_NOT_FOUND: ErrorCode
yatm.security.ERR_INSTALL_FEATURE_NOT_FOUND = 'ERR_INSTALL_FEATURE_NOT_FOUND'
--- The auth process has failed, booting the player from the device usually
--- @const ERR_AUTH_FAILED: ErrorCode
yatm.security.ERR_AUTH_FAILED = 'ERR_AUTH_FAILED'

--- @class SecurityTransaction
local SecurityTransaction = foundation.com.Class:extends("yatm.security.SecurityTransaction")
do
  local ic = SecurityTransaction.instance_class

  --- @spec #initialize(Integer, Table, Function): void
  function ic:initialize(id, info, callback)
    self.id = id
    self.info = info
    self.slot_index = 0
    self.assigns = {
      slots = {},
    }
    self.slot_statuses = {}
    self.last_status = yatm.security.NOTHING
    self.held = false
    self.callback = callback

    minetest.log("action", "New SecurityTransaction id=" .. id)

    for idx, slot_id in ipairs(self.info.slot_ids) do
      self.assigns.slots[slot_id] = {}
      self.slot_statuses[slot_id] = yatm.security.NOTHING
    end
  end

  --- @spec #continue(): (AccessFlag, extra: Any, self: SecurityTransaction)
  function ic:continue()
    local result
    local extra

    while true do
      result, extra = self:step()

      if result == yatm.security.CONTINUE then
        -- just continue the loop
      elseif result == yatm.security.OK then
        return result, nil, self
      elseif result == yatm.security.REJECT or
             result == yatm.security.NEEDS_ACTION then
        return result, extra, self
      else
        error("unxepected response: " .. result)
      end
    end
  end

  function ic:step()
    -- TODO: this entire function should likely be rewritten as a coroutine
    if not self.held then
      self.slot_index = self.slot_index + 1
    end
    self.held = false

    local slot_id = self.info.slot_ids[self.slot_index]
    if slot_id then
      local slot_data
      local is_node = self.info.kind == "node"

      if is_node then
        slot_data = yatm.security:get_node_lock(self.info.pos, self.info.node, slot_id)
      elseif self.info.kind == "object" then
        error("TODO: get security slot data for object")
      end

      print(dump(slot_data))

      if string_empty(slot_data.feature_name) then
        return yatm.security.CONTINUE
      else
        local security_feature = yatm.security:get_security_feature(slot_data.feature_name)

        if security_feature then
          local player = minetest.get_player_by_name(self.info.player_name)

          if is_node then
            local pos = self.info.pos
            local node = self.info.node

            if security_feature.get_node_slot_data then
              -- (maybe) Retrieve additional slot data
              slot_data = security_feature:get_node_slot_data(pos, node, slot_data)
            end

            local result, extra =
              security_feature:check_node_lock(
                pos,
                node,
                player,
                slot_id,
                slot_data,
                self.assigns
              )

            self.slot_statuses[slot_id] = result
            self.last_status = result

            if result == yatm.security.OK then
              -- continue like normal
              return yatm.security.CONTINUE
            elseif result == yatm.security.REJECT then
              -- extra is the reason
              self.held = true
              return yatm.security.REJECT, extra
            elseif result == yatm.security.NEEDS_ACTION then
              --
              extra(
                security_feature,
                pos,
                node,
                player,
                slot_id,
                slot_data,
                self.assigns,
                self:method("continue")
              )
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

            local result, extra =
              security_feature:check_object_lock(object, player, slot_id, slot_data, self.assigns)

            self.slot_statuses[slot_id] = result
            self.last_status = result

            if result == yatm.security.OK then
              -- continue like normal
              return yatm.security.CONTINUE
            elseif result == yatm.security.REJECT then
              -- extra is the reason
              self.held = true
              return yatm.security.REJECT, extra
            elseif result == yatm.security.NEEDS_ACTION then
              --
              extra(
                security_feature,
                object,
                slot_id,
                slot_data,
                self.assigns,
                self:method("continue")
              )
              self.held = true
              return yatm.security.NEEDS_ACTION
            else
              error("unxepected result from check_object_lock/5 object=" .. object.name)
            end
          end
        else
          minetest.log("warning", "missing security_feature name=" .. slot_data.feature_name)
          self.last_status = yatm.security.ERR_INSTALL_FEATURE_NOT_FOUND
          return yatm.security.CONTINUE, yatm.security.ERR_INSTALL_FEATURE_NOT_FOUND
        end
      end
    else
      minetest.log("action", "Security Transaction completed id=" .. self.id)
      self.callback(self.last_status)
      return yatm.security.OK, yatm.security.COMPLETED
    end
  end
end

---
--- The SecurityContext is a factory for security transactions
--- It doesn't keep track of the transactions, as they don't really need to be kept track of
--- instead it handles assigning incrementing ids to them.
---
--- @class SecurityContext
yatm.security.SecurityContext = foundation.com.Class:extends("yatm.security.SecurityContext")
do
  local ic = yatm.security.SecurityContext.instance_class

  --- @spec #initialize(): void
  function ic:initialize()
    self.g_transaction_id = 0
  end

  --- Creates a new security transaction
  --- The execution of the transaction will not be started automatically
  ---
  --- Args:
  --- * `info` - the security transaction data
  --- * `callback` - the final callback that should be executed when the
  ---                transaction is successful
  ---
  --- @spec #create_transaction(info: Table, callback: Function): SecurityTransaction
  function ic:create_transaction(info, callback)
    self.g_transaction_id = self.g_transaction_id + 1
    local transaction_id = self.g_transaction_id
    local transaction = SecurityTransaction:new(transaction_id, info, callback)
    return transaction
  end
end

--- @const context: SecurityContext
yatm.security.context = yatm.security.SecurityContext:new()

--- Trigger check_node_lock for a specific feature
---
--- @spec &security_feature_check_node_lock(
---   feature_name: String,
---   pos: Vector,
---   node: NodeRef,
---   player: ObjectRef,
---   slot_id: String,
---   slot_data: Table,
---   data: Table
--- ): (AccessFlag, Function | nil | String)
function yatm.security:security_feature_check_node_lock(
      feature_name,
      pos,
      node,
      player,
      slot_id,
      slot_data,
      data
    )
  local security_feature = self.registered_security_features[feature_name]
  assert(security_feature, "expected security_feature to exist")
  return security_feature:check_node_lock(pos, node, player, slot_id, slot_data, data)
end

---
--- @spec &security_feature_check_object_lock(
---   feature_name: String,
---   object: ObjectRef,
---   player: ObjectRef,
---   slot_id: String,
---   slot_data: Table,
---   data: Table
--- ): (AccessFlag, Function | nil | String)
function yatm.security:security_feature_check_object_lock(
      feature_name,
      object,
      player,
      slot_id,
      slot_data,
      data
    )
  local security_feature = self.registered_security_features[feature_name]
  assert(security_feature, "expected security_feature to exist")
  return security_feature:check_object_lock(object, player, slot_id, slot_data, data)
end

--- Attempts to install a security feature in the specified slot, the security
--- feature is denoted by the `feature_name`.
---
--- @spec &install_node_slot_feature(
---   pos: Vector3,
---   node: NodeRef,
---   slot_id: String
---   feature_name: String,
---   params: String,
--- ): (Boolean, ErrorCode)
function yatm.security:install_node_slot_feature(pos, node, slot_id, feature_name, params)
  local feature = self.registered_security_features[feature_name]

  if feature then
    return feature:install_node_slot_feature(pos, node, slot_id, params)
  end

  return false, yatm.security.ERR_INSTALL_FEATURE_NOT_FOUND
end

--- Retrieve the slot ids from a registered node at given position.
---
--- @spec &get_node_slot_ids(pos: Vector3, node: NodeRef): Table<String> | nil
function yatm.security:get_node_slot_ids(pos, node)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef then
    if nodedef.security then
      local slot_ids = nodedef.security.slot_ids

      if type(slot_ids) == "table" then
        return slot_ids, yatm.security.OK
      elseif type(slot_ids) == "function" then
        return slot_ids(pos, node), yatm.security.OK
      else
        error("expected slot_ids to be a table or function name=" .. node.name)
      end
    end

    return nil, yatm.security.ERR_NOT_A_SECURABLE_NODE
  end

  return nil, yatm.security.ERR_NODE_NOT_FOUND
end

--- Retrieve security slot ids from an object
---
--- @spec &get_object_slot_ids(object: ObjectRef): Table | nil
function yatm.security:get_object_slot_ids(object)
  local lua_entity = object:get_luaentity()

  if lua_entity and lua_entity.security then
    local slot_ids = lua_entity.security.slot_ids
    if type(slot_ids) == "table" then
      return slot_ids
    elseif type(slot_ids) == "function" then
      return slot_ids(object)
    else
      error("expected slot_ids to be a table or function")
    end
  end

  return nil
end

---
--- @spec &check_node_locks(
---   pos: Vector,
---   player: ObjectRef,
---   slot_ids: nil | [String],
---   callback: Function
--- ): (result: AccessFlag, extra: Function | nil | String, transaction: SecurityTransaction)
function yatm.security:check_node_locks(pos, player, slot_ids, callback)
  local node = minetest.get_node_or_nil(pos)
  if node then
    slot_ids = slot_ids or self:get_node_slot_ids(pos, node)

    if slot_ids and not is_table_empty(slot_ids) then
      local security_transaction =
        yatm.security.context:create_transaction({
          kind = "node",
          slot_ids = slot_ids,
          pos = pos,
          node = node,
          player_name = player:get_player_name(),
        }, callback)

      return security_transaction:continue()
    end
  end
  return yatm.security.NOTHING, nil, nil
end

--- @spec &check_object_locks(
---   object: ObjectRef,
---   player: ObjectRef,
---   slot_ids: nil | [String],
---   callback: Function
--- ): (AccessFlag, Function | nil | String, SecurityTransaction)
function yatm.security:check_object_locks(object, player, slot_ids, callback)
  slot_ids = slot_ids or yatm.security.get_object_slot_ids(object)

  if slot_ids and not is_table_empty(slot_ids) then
    local security_transaction =
      yatm.security.context:create_transaction({
        kind = "object",
        slot_ids = slot_ids,
        object = object,
        player_name = player:get_player_name(),
      }, callback)

    return security_transaction:continue()
  end

  return yatm.security.NOTHING, nil, nil
end

-- Retrieve information on a node's locks with the functions below:

--- Update or set the data for the specific lock
---
--- @spec &put_node_lock(
---   pos: Vector,
---   node: NodeRef,
---   slot_id: String,
---   params: Table
--- ): void
function yatm.security:put_node_lock(pos, _node, slot_id, params)
  assert(slot_id, "expected a slot_id")
  local meta = minetest.get_meta(pos)
  SecuritySlotSchema:set(meta, slot_id, params)
end

--- Retrieves the data for the specific lock
---
--- @spec &get_node_lock(
---   pos: Vector,
---   node: NodeRef,
---   slot_id: String
--- ): Table | nil
function yatm.security:get_node_lock(pos, _node, slot_id)
  assert(slot_id, "expected a slot_id")
  local meta = minetest.get_meta(pos)
  local slot_data = SecuritySlotSchema:get(meta, slot_id)
  return slot_data
end

--- This retrieves ALL locks on the specific node, the table is indexed by the slot_id
---
--- @spec &get_node_locks(
---   pos: Vector,
---   node: NodeRef
--- ): Table<String, Table> | nil
function yatm.security:get_node_locks(pos, node)
  local slot_ids = self:get_node_slot_ids(pos, node)

  local result = {}
  for _, slot_id in ipairs(slot_ids) do
    result[slot_id] = self:get_node_lock(pos, node, slot_id)
  end
  return result
end

--- @spec &get_object_lock(
---   object: ObjectRef,
---   slot_id: String
--- ): Table | nil
function yatm.security:get_object_lock(object, slot_id)
  error("TODO: get_object_lock/2")
end

--- @spec &get_object_locks(
---   object: ObjectRef
--- ): Table<String, Table> | nil
function yatm.security:get_object_locks(object)
  local slot_ids = self:get_object_slot_ids(object)

  local result = {}
  for _, slot_id in ipairs(slot_ids) do
    result[slot_id] = self:get_object_lock(object, slot_id)
  end
  return result
end

--- Check for presence of locks in a specified node.
--- This function will return true if there is even 1 lock present, false otherwise.
---
--- @spec &has_node_locks(
---   pos: Vector,
---   node: NodeRef
--- ): Boolean
function yatm.security:has_node_locks(pos, node)
  local slot_ids = self:get_node_slot_ids(pos, node)
  for _, slot_id in ipairs(slot_ids) do
    if self:get_node_lock(pos, node, slot_id) then
      return true
    end
  end
  return false
end

--- @spec &has_node_lock(
---   pos: Vector,
---   node: NodeRef,
---   slot_id: String
--- ): Boolean
function yatm.security:has_node_lock(pos, node, slot_id)
  if self:get_node_lock(pos, node, slot_id) then
    return true
  end
  return false
end

--- @spec &has_object_locks(object: ObjectRef): Boolean
function yatm.security:has_object_locks(object)
  local slot_ids = self:get_object_slot_ids(object)
  for _, slot_id in ipairs(slot_ids) do
    if self:get_object_lock(object, slot_id) then
      return true
    end
  end
  return false
end

--- @spec &has_object_lock(object: ObjectRef, slot_id: String): Boolean
function yatm.security:has_object_lock(object, slot_id)
  if self:get_object_lock(object, slot_id) then
    return true
  end
  return false
end
