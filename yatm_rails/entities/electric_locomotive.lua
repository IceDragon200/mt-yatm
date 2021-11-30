--
-- Uses either internal batteries or a connected battery cart to move
--
if not yatm_cluster_energy then
  return
end

local mod = yatm_rails

minetest.register_entity(mod:make_name("electric_locomotive"), {
  initial_properties = {
    physical = false,
  },
})
