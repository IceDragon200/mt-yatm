local mod = assert(yatm_security_api)
local fspec = assert(foundation.com.formspec.api)
local Rect = assert(foundation.com.Rect)
local string_starts_with = foundation.com.string_starts_with
local string_trim_leading = foundation.com.string_trim_leading

local KEYPAD = {
  {"1", "1"}, {"2", "2"}, {"3", "3"},
  {"4", "4"}, {"5", "5"}, {"6", "6"},
  {"7", "7"}, {"8", "8"}, {"9", "9"},
  {"S", "*"}, {"0", "0"}, {"P", "#"}
}

local KEYPAD_VALUES = {}
for _,pair in ipairs(KEYPAD) do
  KEYPAD_VALUES[pair[1]] = pair[2]
end

local function render_keypad(prefix, rect)
  local formspec = ""
  local cio = fspec.calc_inventory_offset

  for i1, pair in ipairs(KEYPAD) do
    local i = i1 - 1
    local x = cio(i % 3)
    local y = cio(math.floor(i / 3))

    formspec =
      formspec
      .. fspec.button(rect.x + x, rect.y + y, 1, 1, prefix .. "_keypad_"..pair[1], pair[2])
  end

  return formspec
end

local function handle_keypad_input(prefix, fields, assigns)
  local keypad_prefix = prefix.."_keypad_"

  local slot = assigns.security_assigns.slots[assigns.slot_id]
  local code = slot.code or ""
  for key, value in pairs(fields) do
    if string_starts_with(key, keypad_prefix) then
      local key_id = string_trim_leading(key, keypad_prefix)

      local key_value = KEYPAD_VALUES[key_id]

      if key_value then
        code = code .. key_value
      end
    end
  end

  slot.code = code
end

--
-- Mechanical Locks are security locks that require a physical key to access.
-- Think Carbon Steel locks/key pairs.
--
yatm.security:register_security_feature("yatm_security:mechanical_lock", {
  install_node_slot_feature = function (self, pos, node, slot_id, params)
    yatm.security:put_node_lock(pos, node, slot_id, {
      version = 1,
      feature_name = self.name,
      param1 = assert(params.secret, "expected a secret"),
      param2 = "",
    })

    return true, yatm.security.OK
  end,

  get_node_slot_data = function (self, pos, node, slot_data)
    return slot_data
  end,

  check_node_lock = function (self, pos, node, player, slot_id, slot_data, data)
    return yatm.security.OK
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
yatm.security:register_security_feature("yatm_security:keypad_lock", {
  install_node_slot_feature = function (self, pos, node, slot_id, params)
    yatm.security:put_node_lock(pos, node, slot_id, {
      version = 1,
      feature_name = self.name,
      param1 = assert(params.secret, "expected a secret"),
      param2 = "",
    })

    return true, yatm.security.OK
  end,

  get_node_slot_data = function (self, pos, node, slot_data)
    return slot_data
  end,

  check_node_lock = function (self, pos, node, player, slot_id, slot_data, assigns)
    local slot_assigns = assigns.slots[slot_id]
    local user_code = slot_assigns.code

    if user_code == slot_data.param1 then
      slot_assigns.error = false
      return yatm.security.OK, yatm.security.OK
    elseif user_code ~= nil and user_code ~= "" then
      slot_assigns.error = true
      return yatm.security.REJECT, yatm.security.ERR_AUTH_FAILED
    else
      return yatm.security.NEEDS_ACTION, self._show_challenge
    end
  end,

  get_object_slot_data = function (self, object, slot_data)
    return slot_data
  end,

  check_object_lock = function (self, object, player, slot_id, slot_data, data)
  end,

  _on_receive_fields = function (player, form_name, fields, state)
    if fields["code"] then
      state.security_assigns.slots[state.slot_id].code = fields["code"]
    end

    handle_keypad_input("ky", fields, state)

    if fields["confirm"] then
      state.continue()
    end

    return true, nil
  end,

  _render_formspec = function (self, player, assigns)
    local cio = fspec.calc_inventory_offset

    local code = assigns.security_assigns.slots[assigns.slot_id].code

    return yatm.formspec_render_split_inv_panel(player, 4, 6, { bg = "metal" }, function (loc, rect)
      local formspec = ""
      if loc == "main_body" then
        formspec =
          formspec
          .. fspec.field_area(rect.x, rect.y, rect.w, 1, "code", "Code", code or "")
          .. render_keypad("ky", Rect.translate(Rect.copy(rect), 0, cio(1)))
          .. fspec.button(rect.x, rect.y + cio(5), rect.w, 1, "confirm", "Confirm")
      end
      return formspec
    end)
  end,

  _show_challenge = function (self, pos, node, player, slot_id, slot_data, assigns, continue)
    local options = {
      on_receive_fields = self._on_receive_fields,
      state = {
        feature = self,
        pos = pos,
        node = node,
        slot_id = slot_id,
        slot_data = slot_data,
        continue = continue,
        security_assigns = assigns,
      }
    }

    nokore.formspec_bindings:show_formspec(
      player:get_player_name(),
      mod:make_name(self.name),
      self:_render_formspec(player, options.state),
      options
    )
  end,
})

--
-- The password lock is similar to the keypad lock, but allows arbitrary characters
--
yatm.security:register_security_feature("yatm_security:password_lock", {
  install_node_slot_feature = function (self, pos, node, slot_id, params)
    yatm.security:put_node_lock(pos, node, slot_id, {
      version = 1,
      feature_name = self.name,
      param1 = assert(params.secret, "expected a secret"),
      param2 = "",
    })

    return true, yatm.security.OK
  end,

  get_node_slot_data = function (self, pos, node, slot_data)
    return slot_data
  end,

  check_node_lock = function (self, pos, node, player, slot_id, slot_data, data)
    return yatm.security.OK
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
yatm.security:register_security_feature("yatm_security:player_lock", {
  install_node_slot_feature = function (self, pos, node, slot_id, params)
    yatm.security:put_node_lock(pos, node, slot_id, {
      version = 1,
      feature_name = self.name,
      param1 = assert(params.player_name, "expected a player name"),
      param2 = "",
    })

    return true, yatm.security.OK
  end,

  get_node_slot_data = function (self, pos, node, slot_data)
    return slot_data
  end,

  check_node_lock = function (self, pos, node, player, slot_id, slot_data, data)
    return yatm.security.OK
  end,

  get_object_slot_data = function (self, object, slot_data)
    return slot_data
  end,

  check_object_lock = function (self, object, player, slot_id, slot_data, data)
  end,
})
