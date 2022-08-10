local source
local flowing

if rawget(_G, "default") then
  source = "default:water_source"
  flowing = "default:water_flowing"
end

if rawget(_G, "nokore_world_water") then
  source = "nokore_world_water:fresh_water_source"
  flowing = "nokore_world_water:fresh_water_flowing"
end

yatm.fluids.fluid_registry.register("default", "water", {
  description = yatm_fluids.S("Water"),

  groups = {
    water = 1,
  },

  fluid_tank = {
    modname = "yatm_fluids"
  },

  nodes = {
    dont_register = true,
    names = {
      source = source,
      flowing = flowing,
    },
  },
})
