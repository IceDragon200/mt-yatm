--
-- Mechanical Locks are security locks that require a physical key to access.
-- Think Carbon Steel locks/key pairs.
--
yatm.security.register_security_feature("yatm_security:mechanical_lock", {
  get_node_slot_data = function (self, pos, node, slot_data)
    return slot_data
  end,

  check_node_lock = function (self, pos, node, player, slot_id, slot_data, data)
  end,

  get_object_slot_data = function (self, object, slot_data)
    return slot_data
  end,

  check_object_lock = function (self, object, player, slot_id, slot_data, data)
  end,
})

--
-- The Keypad lock is form of electrical lock, players input their passcode
-- on a numpad to unlock the node/object at that point.
--
yatm.security.register_security_feature("yatm_security:keypad_lock", {
  get_node_slot_data = function (self, pos, node, slot_data)
    return slot_data
  end,

  check_node_lock = function (self, pos, node, player, slot_id, slot_data, data)
  end,

  get_object_slot_data = function (self, object, slot_data)
    return slot_data
  end,

  check_object_lock = function (self, object, player, slot_id, slot_data, data)
  end,
})

--
-- The password lock is similar to the keypad lock, but allows arbitary characters
--
yatm.security.register_security_feature("yatm_security:password_lock", {
  get_node_slot_data = function (self, pos, node, slot_data)
    return slot_data
  end,

  check_node_lock = function (self, pos, node, player, slot_id, slot_data, data)
  end,

  get_object_slot_data = function (self, object, slot_data)
    return slot_data
  end,

  check_object_lock = function (self, object, player, slot_id, slot_data, data)
  end,
})

--
-- The player lock is a form of biometric lock
-- (well sorta, it just needs to check the accessing player)
--
yatm.security.register_security_feature("yatm_security:player_lock", {
  get_node_slot_data = function (self, pos, node, slot_data)
    return slot_data
  end,

  check_node_lock = function (self, pos, node, player, slot_id, slot_data, data)
  end,

  get_object_slot_data = function (self, object, slot_data)
    return slot_data
  end,

  check_object_lock = function (self, object, player, slot_id, slot_data, data)
  end,
})
