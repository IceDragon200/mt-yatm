local canvas_after_place_node = yatm_core.facedir_wallmount_after_place_node

minetest.register_node("yatm_papercraft:painting_canvas", {
  basename = "yatm_papercraft:painting_canvas",

  description = "Painting Canvas",

  groups = {
    snappy = 3,
    flammable = 3,
    blank_canvas = 1,
    painting_canvas = 1
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      -0.5, -0.5, -0.5,  0.5, (1.0 / 16.0) - 0.5,  0.5
    }
  },

  tiles = {
    "yatm_painting_canvas_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  is_ground_content = false,

  after_place_node = canvas_after_place_node,
})
