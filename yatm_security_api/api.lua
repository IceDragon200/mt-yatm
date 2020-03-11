yatm.security = yatm.security or {}

-- Register new security features with register_security_feature
-- @spec yatm.security.register_security_feature(name: String, definition: Table) :: void
function yatm.security.register_security_feature(name, definition)

end

-- Remove existing features with unregister_security_feature
-- @spec yatm.security.unregister_security_feature(name: String) :: void
function yatm.security.unregister_security_feature(name)
end

-- Retrieve a feature by it's name
-- @spec yatm.security.get_security_feature(name: String) :: Table
function yatm.security.get_security_feature(name)
end

-- Trigger check_node_lock for a specific feature
-- @spec yatm.security.security_feature_check_node_lock(feature_name: String, pos: Vector, node: NodeRef, player: PlayerRef, slot_id: String, slot_data: Table, data: Table) :: AccessFlag, Function | nil | String
function yatm.security.security_feature_check_node_lock(feature_name, pos, node, player, slot_id, slot_data, data)
end

-- @spec yatm.security.security_feature_check_object_lock(feature_name: String, object: ObjectRef, player: PlayerRef, slot_id: String, slot_data: Table, data: Table) :: AccessFlag, Function | nil | String
function yatm.security.security_feature_check_object_lock(feature_name, object, player, slot_id, slot_data, data)
end

-- The execute_* functions will take a callback function which should perform the normal
-- action.
-- check_* functions will return the result from check_lock on the feature, it's up to the caller to deal with it

-- Check all locks on a specific node
-- Use this when all locks need to be checked at once
-- @spec yatm.security.execute_check_node_locks(pos: Vector, callback: Function) :: void
function yatm.security.execute_check_node_locks(pos, callback)
end

-- @spec yatm.security.check_node_locks(pos: Vector) :: yatm.security.AccessFlag, Function | nil | String
function yatm.security.check_node_locks(pos)
end

-- Check all locks on given object
-- Use this when all locks need to be checked at once
-- @spec yatm.security.execute_check_object_locks(object: ObjectRef, callback: Function) :: void
function yatm.security.execute_check_object_locks(object, callback)
end

-- @spec yatm.security.check_object_locks(object: ObjectRef) :: yatm.security.AccessFlag, Function | nil | String
function yatm.security.check_object_locks(object)
end

-- Check a specific lock on a specific node
-- @spec yatm.security.execute_check_node_lock(pos: Vector, slot_id: String, callback: Function) :: void
function yatm.security.execute_check_node_lock(pos, slot_id, callback)
end

-- @spec yatm.security.check_node_lock(pos: Vector, slot_id: String) :: yatm.security.AccessFlag, Function | nil | String
function yatm.security.check_node_lock(pos, slot_id)
end

-- Check a specific lock on given object
-- @spec yatm.security.execute_check_object_lock(object: ObjectRef, slot_id: String, callback: Function) :: void
function yatm.security.execute_check_object_lock(object, slot_id, callback)
end

-- @spec yatm.security.check_object_lock(object: ObjectRef, slot_id: String) :: yatm.security.AccessFlag, Function | nil | String
function yatm.security.check_object_lock(object, slot_id)
end

-- Check for presence of locks with:
-- @spec yatm.security.has_node_locks(pos: Vector) :: Boolean
function yatm.security.has_node_locks(pos)
end

-- @spec yatm.security.has_node_lock(pos: Vector, slot_id: String) :: Boolean
function yatm.security.has_node_lock(pos, slot_id)
end

-- @spec yatm.security.has_object_locks(object: ObjectRef) :: Boolean
function yatm.security.has_object_locks(object)
end

-- @spec yatm.security.has_object_lock(object: ObjectRef, slot_id: String) :: Boolean
function yatm.security.has_object_lock(object, slot_id)
end

-- Retrieve information on a node's locks with the functions below:
-- This retrieves ALL locks on the specific node, the table is indexed by the slot_id
-- @spec yatm.security.get_node_locks(pos: Vector) :: Table<String, Table> | nil
function yatm.security.get_node_locks(pos)
end

-- Retrieves the data for the specific lock
-- @spec yatm.security.get_node_lock(pos: Vector, slot_id: String) :: Table | nil
function yatm.security.get_node_lock(pos, slot_id)
end

-- @spec yatm.security.get_object_locks(object: ObjectRef) :: Table<String, Table> | nil
function yatm.security.get_object_locks(object)
end

-- @spec yatm.security.get_object_lock(object: ObjectRef, slot_id: String) :: Table | nil
function yatm.security.get_object_lock(object, slot_id)
end
