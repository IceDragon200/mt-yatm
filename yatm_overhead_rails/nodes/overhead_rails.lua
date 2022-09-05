local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

minetest.register_node("yatm_overhead_rails:overhead_rail_stop", {
  description = "Overhead Straight Stop",

  groups = {
    cracky = nokore.dig_class("copper"),
    overhead_rail = 1,
    overhead_rail_track = 1,
    overhead_rail_stop = 1,
  },

  tiles = {
    "yatm_overhead_rails_stop.face.png",
    "yatm_overhead_rails_stop.face.png^[transformFY",
    "yatm_overhead_rails_stop.side.png",
    "yatm_overhead_rails_stop.side.png^[transformFX",
    "yatm_overhead_rails_stop.back.png",
    "yatm_overhead_rails_straight.front.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(5, 12, 0, 6, 4, 11),
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_overhead_rails:overhead_rail_straight", {
  description = "Overhead Straight Rail",

  groups = {
    cracky = nokore.dig_class("copper"),
    overhead_rail = 1,
    overhead_rail_track = 1,
    overhead_rail_straight = 1,
  },

  tiles = {
    "yatm_overhead_rails_straight.face.png",
    "yatm_overhead_rails_straight.face.png",
    "yatm_overhead_rails_straight.side.png",
    "yatm_overhead_rails_straight.side.png^[transformFX",
    "yatm_overhead_rails_straight.front.png",
    "yatm_overhead_rails_straight.front.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(5, 12, 0, 6, 4, 16),
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_overhead_rails:overhead_rail_bend90", {
  description = "Overhead Bend 90' Rail",

  groups = {
    cracky = nokore.dig_class("copper"),
    overhead_rail = 1,
    overhead_rail_track = 1,
    overhead_rail_bend90 = 1,
  },

  tiles = {
    "yatm_overhead_rails_bend.face.png",
    "yatm_overhead_rails_bend.face.png^[transformFY",
    "yatm_overhead_rails_bend.side.png",
    "yatm_overhead_rails_stop.side.png",
    "yatm_overhead_rails_bend.side.png^[transformFX",
    "yatm_overhead_rails_stop.side.png^[transformFX",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(5, 12, 5, 6, 4, 11),
      ng(11, 12, 5, 5, 4, 6),
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_overhead_rails:overhead_rail_tee", {
  description = "Overhead Tee Rail",

  groups = {
    cracky = nokore.dig_class("copper"),
    overhead_rail = 1,
    overhead_rail_track = 1,
    overhead_rail_tee = 1,
  },

  tiles = {
    "yatm_overhead_rails_tee.face.png",
    "yatm_overhead_rails_tee.face.png^[transformFY",
    "yatm_overhead_rails_tee.side.png",
    "yatm_overhead_rails_straight.side.png",
    "yatm_overhead_rails_bend.side.png^[transformFX",
    "yatm_overhead_rails_bend.side.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(5, 12, 0, 6, 4, 16),
      ng(11, 12, 5, 5, 4, 6),
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_overhead_rails:overhead_rail_cross", {
  description = "Overhead Cross Rail",

  groups = {
    cracky = nokore.dig_class("copper"),
    overhead_rail = 1,
    overhead_rail_track = 1,
    overhead_rail_cross = 1,
  },

  tiles = {
    "yatm_overhead_rails_cross.face.png",
    "yatm_overhead_rails_cross.face.png^[transformFX",
    "yatm_overhead_rails_tee.side.png",
    "yatm_overhead_rails_tee.side.png",
    "yatm_overhead_rails_tee.side.png",
    "yatm_overhead_rails_tee.side.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(5, 12, 0, 6, 4, 16),
      ng(0, 12, 5, 16, 4, 6),
    },
  },

  paramtype = "light",
})
