--
-- Can be used to transport energy, or can be used to power an electric locomotive.
--
if not yatm_cluster_energy then
  return
end

local Cuboid = assert(foundation.com.Cuboid)
local ng = assert(Cuboid.new_fast_node_box)

local mod = yatm_rails

minetest.register_entity(mod:make_name("battery_cart"), {
  initial_properties = {
    physical = false,
    --collide_with_objects = true,
    visual = "mesh",
    visual_size = {x = 1, y = 1},
    collisionbox = ng(0, 0, 0, 16, 12, 16),
    mesh = "yatm_battery_cart.b3d",
    textures = {"yatm_battery_cart_model.png"},
  },
})
