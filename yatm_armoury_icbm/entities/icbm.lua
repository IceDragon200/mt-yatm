minetest.register_entity("yatm_armoury_icbm:icbm", {
  physical = true,
  collide_with_objects = true,
  --glow = 1,
  visual = "mesh",
  visual_size = {x = 10, y = 10},
  collisionbox = yatm_core.Cuboid:new(2, -4, 2, 12, 68, 12):fast_node_box(),
  selectionbox = yatm_core.Cuboid:new(1, -4, 1, 14, 68, 14):fast_node_box(),
  mesh = "yatm_icbm.obj",
  textures = {"yatm_icbm_empty_warhead.png"},
})
