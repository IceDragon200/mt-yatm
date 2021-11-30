--
-- Fluid Carts can be used to transport fluids in a cart
--
if not yatm_fluids then
  return
end

local mod = yatm_rails

minetest.register_entity(mod:make_name("fluid_cart"), {
  initial_properties = {
    physical = false,
  },
})
