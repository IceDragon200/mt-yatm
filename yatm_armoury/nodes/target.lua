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

  on_projectile_hit = function (pos, node, hit_data)
    print("HIT!", dump(hit_data))

    --
    hit_data.stop = true
  end,
})
