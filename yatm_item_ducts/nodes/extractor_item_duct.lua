minetest.register_node("yatm_item_ducts:extractor_item_duct", {
  description = "Extractor Item Duct",

  groups = { cracky = 1 },

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    {
      name = "yatm_item_duct_extractor.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
  },

  item_transport_device = {
    type = "extractor",
  },
})
