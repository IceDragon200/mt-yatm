minetest.register_node("yatm_item_ducts:inserter_item_duct", {
  description = "Inserter Item Duct",

  groups = { cracky = 1 },

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    {
      name = "yatm_item_duct_inserter.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
  },

  item_transport_device = {
    type = "inserter",
  },
})
