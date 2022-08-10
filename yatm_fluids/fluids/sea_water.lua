local source
local flowing

if rawget(_G, "nokore_world_water") then
  source = "nokore_world_water:sea_water_source"
  flowing = "nokore_world_water:sea_water_flowing"
end

yatm.fluids.fluid_registry.register("default", "sea_water", {
  description = yatm_fluids.S("Sea Water"),

  groups = {
    water = 1,
    sea_water = 1,
  },

  nodes = {
    dont_register = true,
    names = {
      source = source,
      flowing = flowing,
    },
  },

  fluid_tank = {
    modname = "yatm_fluids"
  },
})
