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

yatm_oku.autotest_suite.utils = {
  set_node_to_air = set_node_to_air,
  random_pos = random_pos,
  wait_for_next_tick_on_clusters = assert(yatm_machines.autotest_suite.utils.wait_for_next_tick_on_clusters),
}

--- @test_property is_computer
yatm_oku.autotest_suite:define_property("is_computer", {
  description = "Is Computer",
  detail = [[
  The device should behave like a computer
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
    ["Will register itself as a computer"] = function (suite, state)
      local computer = yatm_oku.computers:get_computer_at_pos(state.pos)

      assert(computer, "expected a computer to be registered")
    end,
  },

  teardown = function (suite, state)
    suite:clear_test_area(state.pos)

    local computer = yatm_oku.computers:get_computer_at_pos(state.pos)
    assert(not computer, "expected computer to be destroyed")

    if state.old_list then
      local inv = state.player:get_inventory()
      inv:set_list("main", state.old_list)
      state.old_list = nil
    end
  end,
})

yatm_oku.autotest_suite:import_property(yatm_machines.autotest_suite, "is_machine_like")
