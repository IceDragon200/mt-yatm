local wait_for_next_tick_on_clusters = yatm_machines.autotest_suite.utils.wait_for_next_tick_on_clusters
local fparser = assert(foundation.com.formspec.parser)

local function random_pos()
  return {
    x = math.random(0xFFFF) - 0x8000,
    y = math.random(0xFFFF) - 0x8000,
    z = math.random(0xFFFF) - 0x8000,
  }
end

--
-- Void Chest
--
yatm_dscs.autotest_suite:define_property("is_void_chest", {
  description = "Is Void Chest",
  detail = [[
  The device is a void chest, and behaves like one
  ]],

  setup = function (suite, state)
    local player = assert(minetest.get_player_by_name("singleplayer"))

    state.pos = random_pos()
    suite:clear_test_area(state.pos)

    state.player = player

    return state
  end,

  tests = {
    ["Will show a formspec when right-clicked"] = function (suite, state)
      minetest.set_node(state.pos, assert(state.node))

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local triggered, reason = trigger_rightclick_on_pos(state.pos, state.player)

      assert(triggered, "expected rightclick to trigger error="..reason)

      suite:yield()

      local form = get_player_current_formspec(state.player:get_player_name())

      assert(form, "the player is not currently viewing a formspec trigger_reason="..reason)

      local _items = fparser.parse(assert(form.spec, "there is no formspec currently active"))
    end,

    ["Can install a fluid drive"] = function (suite, state)
      minetest.set_node(state.pos, assert(state.node))

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local triggered, reason = trigger_rightclick_on_pos(state.pos, state.player)

      assert(triggered, "expected rightclick to trigger error="..reason)

      suite:yield()

      local form = get_player_current_formspec(state.player:get_player_name())
      assert(form, "the player is not currently viewing a formspec trigger_reason="..reason)
      if not foundation.com.string_starts_with(form.name, "yatm_dscs:void_chest:") then
        error("expected form to be void_chest got=" .. form.name)
      end

      local _items = fparser.parse(assert(form.spec, "there is no formspec currently active"))

      local stack = ItemStack("yatm_dscs:item_drive_t1")

      local leftover = trigger_metadata_inventory_put(state.pos, "drive_slot_input", 1, stack, state.player)
      assert(leftover:is_empty())

      trigger_on_player_receive_fields(
        state.player,
        assert(form.name),
        {
          --- Trigger the swap_drives action
          ["swap_drives"] = true,
        }
      )

      suite:yield()

      local meta = minetest.get_meta(state.pos)
      local inv = meta:get_inventory()
      assert(inv:get_stack("drive_slot_input", 1):is_empty(), "expected input slot to be empty")
      assert(not inv:get_stack("drive_slot", 1):is_empty(), "expected drive_slot to contain drive")
    end
  },

  teardown = function (suite, state)
    minetest.close_formspec(state.player:get_player_name(), "")
    suite:clear_test_area(state.pos)
    wait_for_next_tick_on_clusters(suite, state, 1.0)
  end,
})

--
-- Void Crate
--
yatm_dscs.autotest_suite:define_property("is_void_crate", {
  description = "Is Void Crate",
  detail = [[
  The device is a void crate, and behaves like one
  ]],

  setup = function (suite, state)
    local player = assert(minetest.get_player_by_name("singleplayer"))

    state.pos = random_pos()
    suite:clear_test_area(state.pos)

    state.player = player

    return state
  end,

  tests = {
    ["Will show a formspec when right-clicked"] = function (suite, state)
      minetest.set_node(state.pos, assert(state.node))

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local triggered, reason = trigger_rightclick_on_pos(state.pos, state.player)

      assert(triggered, "expected rightclick to trigger error="..reason)

      suite:yield()

      local form = get_player_current_formspec(state.player:get_player_name())

      assert(form, "the player is not currently viewing a formspec trigger_reason="..reason)

      local _items = fparser.parse(assert(form.spec, "there is no formspec currently active"))
    end,

    ["Can install a fluid drive"] = function (suite, state)
      minetest.set_node(state.pos, assert(state.node))

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local triggered, reason = trigger_rightclick_on_pos(state.pos, state.player)

      assert(triggered, "expected rightclick to trigger error="..reason)

      suite:yield()

      local form = get_player_current_formspec(state.player:get_player_name())
      assert(form, "the player is not currently viewing a formspec trigger_reason="..reason)
      if not foundation.com.string_starts_with(form.name, "yatm_dscs:void_crate:") then
        error("expected form to be void_crate got=" .. form.name)
      end

      local _items = fparser.parse(assert(form.spec, "there is no formspec currently active"))

      local stack = ItemStack("yatm_dscs:fluid_drive_t1")

      local leftover = trigger_metadata_inventory_put(state.pos, "drive_slot_input", 1, stack, state.player)
      assert(leftover:is_empty())

      trigger_on_player_receive_fields(
        state.player,
        assert(form.name),
        {
          --- Trigger the swap_drives action
          ["swap_drives"] = true,
        }
      )

      suite:yield()

      local meta = minetest.get_meta(state.pos)
      local inv = meta:get_inventory()
      assert(inv:get_stack("drive_slot_input", 1):is_empty(), "expected input slot to be empty")
      assert(not inv:get_stack("drive_slot", 1):is_empty(), "expected drive_slot to contain drive")
    end
  },

  teardown = function (suite, state)
    minetest.close_formspec(state.player:get_player_name(), "")
    suite:clear_test_area(state.pos)
    wait_for_next_tick_on_clusters(suite, state, 1.0)
  end,
})
