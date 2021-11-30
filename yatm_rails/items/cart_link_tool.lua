--
-- The linker tool is used to build cart chains
--
local mod = yatm_rails

mod:register_tool("cart_link_tool", {
  description = mod.S("Cart Link Tool"),

  inventory_image = "yatm_cart_link_tool.png",

  stack_max = 1,

  on_place = function (_itemstack, _user, _pointed_thing)
    return nil
  end,
})
