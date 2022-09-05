minetest.register_node("yatm_decor:mesh_dense", {
  description = "Dense Mesh",

  groups = {
    cracky = nokore.dig_class("copper"),
  },

  sounds = yatm.node_sounds:build("metal"),

  tiles = {
    "yatm_meshes_border.png",
    "yatm_meshes_dense_mesh.png",
  },
  drawtype = "glasslike_framed",
  place_param2 = 0,
  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_decor:mesh_wide", {
  description = "Wide Mesh",

  groups = {
    cracky = nokore.dig_class("copper"),
  },

  sounds = yatm.node_sounds:build("metal"),

  tiles = {
    "yatm_meshes_border.png",
    "yatm_meshes_wide_mesh.png",
  },
  drawtype = "glasslike_framed",
  place_param2 = 0,
  paramtype = "light",
  paramtype2 = "facedir",
})
