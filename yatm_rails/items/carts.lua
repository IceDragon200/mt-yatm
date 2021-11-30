--
-- The linker tool is used to build cart chains
--
local mod = yatm_rails

-- @private.spec place_cart(ItemStack, Player, PointedThing, name: String): ItemStack
local function place_cart(item_stack, user, pointed_thing, name)
  local cart = minetest.add_entity(pointed_thing.above, name)
  --cart:get_luaentity():set_owner_name(user:get_player_name())

  itemstack:take_item(1)
  return itemstack
end

mod:register_tool("battery_cart", {
  description = mod.S("Battery Cart"),

  inventory_image = "yatm_cart.battery.png"

  stack_max = 1,

  on_place = function (item_stack, user, pointed_thing)
    if pointed_thing.above ~= nil then
      return place_cart(item_stack, user, pointed_thing, "yatm_rails:battery_cart")
    end

    return nil
  end,
})

mod:register_tool("fluid_cart", {
  description = mod.S("Fluid Cart"),

  inventory_image = "yatm_cart.fluid.png"

  stack_max = 1,

  on_place = function (item_stack, user, pointed_thing)
    if pointed_thing.above ~= nil then
      return place_cart(item_stack, user, pointed_thing, "yatm_rails:fluid_cart")
    end

    return nil
  end,
})

mod:register_tool("item_cart", {
  description = mod.S("Item Cart"),

  inventory_image = "yatm_cart.item.png"

  stack_max = 1,

  on_place = function (item_stack, user, pointed_thing)
    if pointed_thing.above ~= nil then
      return place_cart(item_stack, user, pointed_thing, "yatm_rails:item_cart")
    end

    return nil
  end,
})

mod:register_tool("solid_fuel_locomotive", {
  description = mod.S("Solid Fuel Locomotive"),

  inventory_image = "yatm_locomotive.solid_fuel.png"

  stack_max = 1,

  on_place = function (item_stack, user, pointed_thing)
    if pointed_thing.above ~= nil then
      return place_cart(item_stack, user, pointed_thing, "yatm_rails:solid_fueld_locomotive")
    end

    return nil
  end,
})

mod:register_tool("electric_locomotive", {
  description = mod.S("Electric Locomotive"),

  inventory_image = "yatm_locomotive.electric.png"

  stack_max = 1,

  on_place = function (item_stack, user, pointed_thing)
    if pointed_thing.above ~= nil then
      return place_cart(item_stack, user, pointed_thing, "yatm_rails:electric_locomotive")
    end

    return nil
  end,
})
