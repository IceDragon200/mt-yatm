local mod = yatm_armoury

mod:register_node("target", {
  basename = "yatm_armoury:target",

  base_description = "Target",
  description = "Target",

  groups = {
    cracky = nokore.dig_class("wme"),
    oddly_breakable_by_hand = nokore.dig_class("hand"),
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
