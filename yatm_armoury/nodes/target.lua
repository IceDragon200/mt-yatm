local mod = yatm_armoury

mod:register_node("target", {
  basename = "yatm_armoury:target",

  base_description = "Target",
  description = "Target",

  groups = {
    cracky = 1,
  },

  tiles = {
    "yatm_target.png",
  },
})
