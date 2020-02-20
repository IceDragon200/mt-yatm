minetest.register_node("yatm_armoury:turret_base", {
  codex_entry_id = "yatm_armoury:turret_base",

  basename = "yatm_armoury:turret_base",

  description = "Turret Base",

  groups = {
    cracky = 1,
  },

  drawtype = "mesh",
  visual = "mesh",
  mesh = "mortar.obj",
  visual_scale = 1/16,

  paramtype = "light",
  paramtype2 = "facedir",

  is_ground_content = false,
})
