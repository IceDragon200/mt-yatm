# YATM Security API

__Version__ 1.0.0

## What is a security definition

A security definition is a table that contains a handful of properties and functions (as with any of the definition formats).

__Defining security information on object__

```lua
security = {
  -- Slots tell the security system what meta reference keys to look at to find the
  -- information needed for the system, it may just be a prefix
  -- if a MetaSchema is used to represent it
  slots = {"yatmsec_primary", "yatmsec_secondary"}, -- would default to just "yatmsec" if not specified
  slots = function (pos, node) -- a function could be used instead as well
    return {"yatmsec_primary", "yatmsec_secondary"}
  end,

  on_install_feature = function (pos, node, slot, data)
    -- called before a feature is installed
    -- developers can modify the data here
    -- or outright reject the installation by returning false
    -- if not defined, it will default to returning true
    -- this can be used to deny use of some features in an object
    return true
  end,

  on_feature_installed = function (pos, node, slot, data)
    -- a callback function when security feature is installed on the object
    -- slot is the name of the slot that the feature was installed in
    -- data contains any additional information, possibly what type of
    -- security feature was installed, and additional parameters
    -- this callback can be used to provide some user feedback, such as a sound effect or particle effect
  end,
}
```

__Defining security types__

```lua
-- An example of registering a security type for mechanical locks
-- Mechanical locks would include the default carbon steel lock and keys as the unlocking mechanism
yatm.security.register_security_feature("yatm:mechanical_lock", {
  description = "Mechanical Lock",

  -- This function can report different states
  -- First, it can report that a lock can be bypassed (i.e. it's okay)
  -- Second, it can report that a lock cannot be bypassed (e.g. it's locked, or simply denying access)
  -- Thirdly, it can report a delayed, or 'needs' action state (e.g. the player needs to complete a prompt)
  -- yatm_security will provide all these return options as constants in it's API module for ease
  -- yatm.security.OK, yatm.security.REJECT, yatm.security.NEEDS_ACTION
  check_node_lock = function (self, pos, node, player, slot_id, slot_data, data)
    -- player is the player entity that is triggering the lock check, it could also be a different entity, but it likely will be a player for the most part.
    -- slot_id is the name of the slot on the node
    -- slot_data is the table pulled from the meta, containing all the stored information for the lock
    -- data is any additional data that yatm security would provide, such as a password from the user when a NEEDS_ACTION was sent before
    return yatm.security.OK
  end,

  check_object_lock = function (self, object, player, slot_id, slot_data, data)
    -- same as above, but triggered for objects
    return yatm.security.OK
  end,
})

-- An example of a feature that would prompt the user for a password
local function prompt_for_password(pos, node, player, slot_id, slot_data, data, callback)
  -- see above for what each of the parameters are for
  -- callback should be executed when finished, this will let
  -- yatm security know it can take the security request off ice and resume checks
  local formspec_name = "yatm:password_lock_form"
  local assigns = {
    callback = callback,
    data = data,
  }

  -- normally you wouldn't define the function here, instead you would define it
  -- outside this scope as a generic resuable function and then set data on the
  -- assigns as needed.
  local on_receive_fields =
    function (player, form_name, fields, assigns)
      -- the formspec in question should be configured to quit by itself
      -- otherwise you can close it here if you'd like
      assigns.data.password = fields.password
      callback() -- let yatm security know it can resume checks now
      return true -- this is just the receive_fields propogation flag
    end

  nokore.formspec_bindings:show_formspec(
    player:get_player_name(),
    formspec_name,
    formspec
  )
end

yatm.security.register_security_feature("yatm:password_lock", {
  description = "Password Lock",

  _check_password = function (self, data, slot_data)
    if data.password then
      if data.password == slot_data.secret then
        -- the player provided the correct password, authorize them
        return yatm.security.OK
      else
        -- the player did not provide the correct password, reject access
        return yatm.security.REJECT, 'password incorrect'
      end
    else
      -- no password was provided, prompt the player for a password
      return yatm.security.NEEDS_ACTION, prompt_for_password
    end
  end,

  check_node_lock = function (self, pos, node, player, slot_id, slot_data, data)
    return self:_check_password(data, slot_data)
  end,

  check_object_lock = function (self, object, player, slot_id, slot_data, data)
    return self:_check_password(data, slot_data)
  end,
})
```

__API mockup__

```lua
-- Register new security features with register_security_feature
yatm.security.register_security_feature(name: String, definition: Table) :: void

-- Remove existing features with unregister_security_feature
yatm.security.unregister_security_feature(name: String) :: void

-- Retrieve a feature by it's name
yatm.security.get_security_feature(name: String) :: Table

-- Trigger check_node_lock for a specific feature
yatm.security.security_feature_check_node_lock(feature_name: String, pos: Vector, node: NodeRef, player: PlayerRef, slot_id: String, slot_data: Table, data: Table) :: AccessFlag, Function | nil | String
yatm.security.security_feature_check_object_lock(feature_name: String, object: ObjectRef, player: PlayerRef, slot_id: String, slot_data: Table, data: Table) :: AccessFlag, Function | nil | String

-- The execute_* functions will take a callback function which should perform the normal
-- action.
-- check_* functions will return the result from check_lock on the feature, it's up to the caller to deal with it

-- Check all locks on a specific node
-- Use this when all locks need to be checked at once
yatm.security.execute_check_node_locks(pos: Vector, callback: Function) :: void
yatm.security.check_node_locks(pos: Vector) :: yatm.security.AccessFlag, Function | nil | String

-- Check all locks on given object
-- Use this when all locks need to be checked at once
yatm.security.execute_check_object_locks(object: ObjectRef, callback: Function) :: void
yatm.security.check_object_locks(object: ObjectRef) :: yatm.security.AccessFlag, Function | nil | String

-- Check a specific lock on a specific node
yatm.security.execute_check_node_lock(pos: Vector, slot_id: String, callback: Function) :: void
yatm.security.check_node_lock(pos: Vector, slot_id: String) :: yatm.security.AccessFlag, Function | nil | String

-- Check a specific lock on given object
yatm.security.execute_check_object_lock(object: ObjectRef, slot_id: String, callback: Function) :: void
yatm.security.check_object_lock(object: ObjectRef, slot_id: String) :: yatm.security.AccessFlag, Function | nil | String

-- Check for presence of locks with:
yatm.security.has_node_locks(pos: Vector) :: Boolean
yatm.security.has_node_lock(pos: Vector, slot_id: String) :: Boolean
yatm.security.has_object_locks(object: ObjectRef) :: Boolean
yatm.security.has_object_lock(object: ObjectRef, slot_id: String) :: Boolean

-- Retrieve information on a node's locks with the functions below:
-- This retrieves ALL locks on the specific node, the table is indexed by the slot_id
yatm.security.get_node_locks(pos: Vector) :: Table<String, Table> | nil

-- Retrieves the data for the specific lock
yatm.security.get_node_lock(pos: Vector, slot_id: String) :: Table | nil

yatm.security.get_object_locks(object: ObjectRef) :: Table<String, Table> | nil
yatm.security.get_object_lock(object: ObjectRef, slot_id: String) :: Table | nil

```

__Example of security checks__

```lua
-- Below is an example of performing security checks on DATA style node
-- The node requires that both it's security slots grant access
minetest.register_node("my_mod:my_node", {
  description = "DATA My Node",

  groups = {
    cracky = 1,
    data_programmable = 1, -- needed for the DATA Programmer item
    yatm_data_device = 1, -- just let YATM know this is a DATA device that needs to be re-loaded
  },

  -- boring YATM data boiler plate
  data_network_device = {
    type = "device",
  },
  data_interface = {
    ... -- omitted information for brevity

    -- A function that will be added to data programmer
    check_formspec_access = function (self, pos, user, pointed_thing, assigns, callback)
      -- this node will just check all of it's security features before allowing itself to be programmed
      yatm.security.execute_check_node_locks(pos, callback)
    end,
  },

  security = {
    slots = {"yatmsec_primary", "yatmsec_secondary"}
  }
})

-- Below is an example of performing security checks on another DATA style node
-- This node however split's it's slots for different access checks
minetest.register_node("my_mod:my_node", {
  description = "DATA My Node",

  groups = {
    cracky = 1,
    data_programmable = 1, -- needed for the DATA Programmer item
    yatm_data_device = 1, -- just let YATM know this is a DATA device that needs to be re-loaded
  },

  -- boring YATM data boiler plate
  data_network_device = {
    type = "device",
  },
  data_interface = {
    ... -- omitted information for brevity

    -- A function that will be added to data programmer
    check_formspec_access = function (self, pos, user, pointed_thing, assigns, callback)
      -- this node will only check it's yatmsec_dataprog feature on programming
      yatm.security.execute_check_nod_locks(pos, "yatmsec_dataprog", callback)
    end,
  },

  on_rightclick = function (pos, node, user, itemstack, pointed_thing)
    -- this node will only check it's yatmsec_operation feature on right click
    yatm.security.execute_check_nod_locks(pos, "yatmsec_operation", function ()
      -- display default formspec here, or perform some modification to the node
    end)
  end,

  security = {
    slots = {"yatmsec_dataprog", "yatmsec_operation"}
  }
})
```

## Questions

__Q.__ Would I need to include the security mod to add the definition to the node/entity

__A.__ It should not, the definition will be designed as much as possible to only provide needed information to the system and shouldn't need the mod to exist to be defined, if the mod isn't present, the data will just sit there, quietly.

__Q.__ Would I need the security mod to perform access checks?

__A.__ Yes, since the mod would be needed to handle all the different security types
