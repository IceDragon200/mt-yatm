minetest.register_tool("yatm_packs:health_pack_pouch", {
  description = "Health Pack Pouch",

  groups = {
    pack_pouch = 1,
    health_pack_pouch = 1,
  },

  inventory_image = "yatm_health_pack_pouch.png",

  charges_added = 1,
})
