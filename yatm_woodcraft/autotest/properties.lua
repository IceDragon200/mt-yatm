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

yatm_woodcraft.autotest_suite.utils = {
  set_node_to_air = set_node_to_air,
  random_pos = random_pos,
}

yatm_woodcraft.autotest_suite:define_property("is_sawmill", {
  description = "Is Sawmill",
  detail = [[
  The device should behave like a sawmill
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

    return state
  end,

  tests = {
    ["Will do nothing if given nothing"] = function (suite, state)
      assert(trigger_rightclick_on_pos(state.pos, state.player))

      local inv = state.player:get_inventory()
      -- print(inv:inspect())
      assert_inventory_is_empty(inv, "main")
    end,

    ["Will convert logs to cores"] = function (suite, state)
      local item_stack = ItemStack("nokore_world_tree_oak:oak_log")
      state.player:get_inventory():set_stack("main", state.player.hotbar_index, item_stack)
      assert(trigger_rightclick_on_pos(state.pos, state.player))

      local inv = state.player:get_inventory()
      assert(not inv:is_empty("main"))

      assert_and_remove_item_stack_in_inventory(
        inv,
        "main",
        ItemStack("yatm_woodcraft:oak_log_core 1")
      )
      assert_and_remove_item_stack_in_inventory(
        inv,
        "main",
        ItemStack("yatm_woodcraft:oak_log_bark 4")
      )

      assert_inventory_is_empty(inv, "main")
    end,

    ["Will convert cores to planks"] = function (suite, state)
      local item_stack = ItemStack("yatm_woodcraft:oak_log_core")
      state.player:get_inventory():set_stack("main", state.player.hotbar_index, item_stack)
      assert(trigger_rightclick_on_pos(state.pos, state.player))

      local inv = state.player:get_inventory()
      assert(not inv:is_empty("main"))

      assert_and_remove_item_stack_in_inventory(
        inv,
        "main",
        ItemStack("nokore_world_tree_oak:oak_planks 6")
      )

      assert_inventory_is_empty(inv, "main")
    end,

    ["Will convert planks to slabs"] = function (suite, state)
      local item_stack = ItemStack("nokore_world_tree_oak:oak_planks")
      state.player:get_inventory():set_stack("main", state.player.hotbar_index, item_stack)
      assert(trigger_rightclick_on_pos(state.pos, state.player))

      local inv = state.player:get_inventory()
      assert(not inv:is_empty("main"))

      assert_and_remove_item_stack_in_inventory(
        inv,
        "main",
        ItemStack("nokore_world_tree_oak:oak_planks_slab 2")
      )

      assert_inventory_is_empty(inv, "main")
    end,

    ["Will convert slabs to panels"] = function (suite, state)
      local item_stack = ItemStack("nokore_world_tree_oak:oak_planks_slab")
      state.player:get_inventory():set_stack("main", state.player.hotbar_index, item_stack)
      assert(trigger_rightclick_on_pos(state.pos, state.player))

      local inv = state.player:get_inventory()
      assert(not inv:is_empty("main"))

      assert_and_remove_item_stack_in_inventory(
        inv,
        "main",
        ItemStack("nokore_world_tree_oak:oak_planks_panel 4")
      )

      assert_inventory_is_empty(inv, "main")
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
