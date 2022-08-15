local mod = yatm_fluids

local source
local flowing

if rawget(_G, "default") then
  source = "default:lava_source"
  flowing = "default:lava_flowing"
end

if rawget(_G, "nokore_world_lava") then
  source = "nokore_world_lava:lava_source"
  flowing = "nokore_world_lava:lava_flowing"
end

yatm.fluids.fluid_registry.register("default", "lava", {
  description = mod.S("Lava"),

  color = "#8b1408",

  groups = {
    liquid = 1,
    lava = 1,
  },

  nodes = {
    dont_register = true,
    names = {
      source = source,
      flowing = flowing,
    },
  },

  fluid_tank = {
    modname = "yatm_fluids",
    light_source = 12,
  },
})
