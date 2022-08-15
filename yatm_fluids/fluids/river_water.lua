local source
local flowing

if rawget(_G, "default") then
  source = "default:river_water_source"
  flowing = "default:river_water_flowing"
end

if rawget(_G, "nokore_world_water") then
  source = "nokore_world_water:river_water_source"
  flowing = "nokore_world_water:river_water_flowing"
end

yatm.fluids.fluid_registry.register("default", "river_water", {
  description = yatm_fluids.S("River Water"),

  color = "#235c7c",

  groups = {
    liquid = 1,
    water = 1,
    river_water = 1,
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
