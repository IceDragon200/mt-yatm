minetest.register_node("yatm_armoury:turret_base", {
  codex_entry_id = "yatm_armoury:turret_base",

  basename = "yatm_armoury:turret_base",

  description = "Turret Base",

  groups = {
    cracky = 1,
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-8/16,-8/16,-8/16,8/16,-7/16,8/16},
    }
  },

  tiles = {
    "yatm_turret_base.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  is_ground_content = false,

  on_construct = function (pos)
    local entity = minetest.add_entity(pos, "yatm_armoury:turret")
  end,

  on_destruct = function (pos)
    for _, object in ipairs(minetest.get_objects_inside_radius(pos, 0.75)) do
      if not object:is_player() then
        local lua_entity = object:get_luaentity()
        if lua_entity then
          -- TODO: this should scope for turrets
          object:remove()
        end
      end
    end
  end,
})
