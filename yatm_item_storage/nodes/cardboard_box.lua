minetest.register_node("yatm_item_storage:cardboard_box", {
  description = "Cardboard Box",

  groups = {cracky = 1, cardboard = 1, cardboard_box = 1},

  stack_max = 1,

  tiles = {
    "yatm_cardboard_box_top.png",
    "yatm_cardboard_box_bottom.png",
    "yatm_cardboard_box_side.png",
    "yatm_cardboard_box_side.png",
    "yatm_cardboard_box_side.png",
    "yatm_cardboard_box_side.png",
  },

  is_ground_content = false,

  sounds = default.node_sound_wood_defaults(), -- do we have paper default?

  paramtype = "light",
  paramtype2 = "facedir",
  place_param2 = 0,

  after_place_node = function (pos, placer, item_stack, pointed_thing)
    -- TODO: copy inventory from stack
  end,

  preserve_metadata = function (pos, old_node, old_meta_table, drops)
    local stack = drops[1]

    local old_meta = yatm_core.FakeMetaRef:new(old_meta_table)
    local new_meta = stack:get_meta()

    -- TODO: copy inventory
  end
})
