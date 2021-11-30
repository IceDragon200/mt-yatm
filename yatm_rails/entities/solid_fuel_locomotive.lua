--
-- Solid Fuel locomotives consume solid fuel items to power itself
--
local mod = yatm_rails

minetest.register_entity(mod:make_name("solid_fuel_locomotive"), {
  initial_properties = {
    physical = false,
  },
})
