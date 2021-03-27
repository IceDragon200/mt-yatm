local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

minetest.register_entity("yatm_overhead_rails:docking_crate", {
  initial_properties = {
    physical = true,
    collide_with_objects = true,
    wield_image = "yatm_overhead_rails:docking_crate_empty",
    visual = "wielditem",
    visual_size = {x = 1, y = 1},
    collisionbox = ng(0, 0, 0, 12, 12, 12),
  },

  on_activate = function(self, static_data)

  end,
})
