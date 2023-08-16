local hash_node_position = assert(minetest.hash_node_position)

local function set_node_to_air(pos)
  minetest.set_node(pos, { name = "air" })
end

local function random_pos()
  return {
    x = math.random(0xFFFF) - 0x8000,
    y = math.random(0xFFFF) - 0x8000,
    z = math.random(0xFFFF) - 0x8000,
  }
end

yatm_security.autotest_suite.utils = {
  set_node_to_air = set_node_to_air,
  random_pos = random_pos,
  wait_for_next_tick_on_clusters = assert(yatm_machines.autotest_suite.utils.wait_for_next_tick_on_clusters),
}

yatm_security.autotest_suite:define_property("is_secure_box", {
  description = "Is Secure Box",
  detail = [[
  The device should behave like a secure box
  ]],

  setup = function (suite, state)
    local player = assert(minetest.get_player_by_name("singleplayer"))

    state.player = player

    local inv = state.player:get_inventory()
    state.player.hotbar_index = 1
    state.old_list = stash_inventory_list(inv, "main")

    state.pos = random_pos()
    suite:clear_test_area(state.pos)
    state.node_id = hash_node_position(state.pos)
    minetest.set_node(state.pos, assert(state.node))

    suite.utils.wait_for_next_tick_on_clusters(suite, state, 2.0)

    return state
  end,

  tests = {
    ["Can install security features on it"] = function (suite, state)
      local status
      local transaction
      local slot_ids, err = yatm.security:get_node_slot_ids(state.pos, state.node)

      assert(err == yatm.security.OK)

      assert(yatm.security:get_security_feature("yatm_security:keypad_lock"), "expected keypad_lock security feature")

      local secret = "122355"

      status, err = yatm.security:install_node_slot_feature(
        state.pos,
        state.node,
        slot_ids[1],
        "yatm_security:keypad_lock",
        {
          secret = secret
        }
      )

      assert(status == true)
      assert(err == yatm.security.OK)

      local completed = false
      status, err, transaction =
        yatm.security:check_node_locks(state.pos, state.player, {slot_ids[1]}, function ()
          completed = true
        end)

      local form_name = "yatm_security_api:yatm_security:keypad_lock"
      trigger_on_player_receive_fields(
        state.player,
        form_name,
        {
          --- Confirm the code which should close the formspec
          ["confirm"] = true,
        }
      )

      assert(not completed, "expected security context to not be completed")

      status, err, transaction =
        yatm.security:check_node_locks(state.pos, state.player, {slot_ids[1]}, function ()
          completed = true
        end)

      foundation.com.string_each_char(secret, function (char)
        trigger_on_player_receive_fields(
          state.player,
          form_name,
          {
            ["ky_keypad_"..char] = true,
          }
        )
      end)

      trigger_on_player_receive_fields(
        state.player,
        form_name,
        {
          --- Confirm the code which should close the formspec
          ["confirm"] = true,
        }
      )

      print(dump(slot_ids))

      assert(completed, "expected security challenge to be completed")
    end,
  },

  teardown = function (suite, state)
    suite:clear_test_area(state.pos)

    if state.old_list then
      local inv = state.player:get_inventory()
      inv:set_list("main", state.old_list)
      state.old_list = nil
    end
  end,
})

yatm_security.autotest_suite:import_property(yatm_machines.autotest_suite, "is_machine_like")
