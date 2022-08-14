--
-- Fluid Box are small fluid carrying items, they are made from waxed cardboard.
--
-- Please don't carry lava in them.
--
local mod = assert(yatm_papercraft)

local function pickup_fluid_box(item_stack, user, pointed_thing)
  -- FIXME: pickup fluid
  return item_stack
end

local function place_fluid_box_contents(item_stack, user, pointed_thing)
  -- FIXME: drop fluid
  return item_stack
end

minetest.register_tool("yatm_papercraft:fluid_box", {
  description = mod.S("Fluid Box"),

  groups = {
    fluid_container = 1,
  },

  inventory_image = "yatm_fluid_box.png",

  on_use = pickup_fluid_box,
  on_place = place_fluid_box_contents,

  fluid_container = {
    key = "fluid",
    capacity = 1000,
  },
})
