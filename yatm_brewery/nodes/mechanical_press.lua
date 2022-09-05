--
-- Mechanical Presses work with basins to complete PressingRecipes
-- This is normally used to change items into some kind of fluid or other
-- items that will be stored in the basin
--
-- The press is operated by right clicking on it with an empty hand (for now)
local mod = yatm_brewery

local function on_construct(pos)
end

local function on_destruct(pos)
end

mod:register_node("mechanical_press", {
  description = "Mechanical Press",

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    machine = 1,
    mechcanical_press = 1,
  },

  tiles = {},
})
