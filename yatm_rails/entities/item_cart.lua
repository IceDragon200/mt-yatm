--
-- Item Carts have a fixed storage for transporting items
--
if not yatm_item_storage then
  return
end

local mod = yatm_rails

minetest.register_entity(mod:make_name("item_cart"), {
  initial_properties = {
    physical = false,
  },
})
