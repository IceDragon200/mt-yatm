local mod = assert(yatm_armoury)

mod:register_node("turret_base", {
  codex_entry_id = mod.S("turret_base"),
  basename = mod.S("turret_base"),

  short_description = mod.S("Turret Base"),
  description = mod.S("Turret Base"),

  groups = {
    cracky = nokore.dig_class("copper"),
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
    local entity = core.add_entity(pos, "yatm_armoury:turret")
  end,

  on_destruct = function (pos)
    for _, object in ipairs(core.get_objects_inside_radius(pos, 0.75)) do
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
