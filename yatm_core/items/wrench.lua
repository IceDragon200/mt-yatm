local mod = yatm_core

local wrench = yatm.wrench

yatm_core:register_tool("wrench", {
  codex_entry_id = "yatm_core:wrench",

  description = "Wrench",

  inventory_image = "yatm_wrench.png",

  -- left
  on_use = function (item_stack, user, pointed_thing)
    if pointed_thing.type == "node" then
      if wrench.user_rotate_node_at_pos(user, wrench.ROTATE_FACE, pointed_thing.under, false) then
        -- was rotated
      end
    end

    return item_stack
  end,

  -- right
  on_place = function (item_stack, user, pointed_thing)
    if pointed_thing.type == "node" then
      if wrench.user_rotate_node_at_pos(user, wrench.ROTATE_AXIS, pointed_thing.under, false) then
        -- was rotated
      end
    end

    return item_stack
  end,
})
