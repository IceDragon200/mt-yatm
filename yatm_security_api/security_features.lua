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
