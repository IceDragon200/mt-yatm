minetest.register_entity("yatm_armoury:turret", {
  initial_properties = {
    --drawtype = "mesh",
    visual = "mesh",
    mesh = "yatm_turret_machine_gun.obj",
    visual_scale = 1/24,

    textures = {
      "yatm_turret.png"
    },

    is_turret = true,
  }
})
