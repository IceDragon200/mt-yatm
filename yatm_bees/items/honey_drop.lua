local mod = yatm_bees

mod:register_craftitem("honey_drop", {
  description = "Honey Drop",

  groups = {
    honey_drop = 1,
    bee_bait = 1,
  },

  inventory_image = "yatm_honey_drop.png",
})
