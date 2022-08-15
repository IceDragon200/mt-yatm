local mod = yatm_fluids

yatm.fluids.fluid_registry.register("yatm_fluids", "steam", {
  description = mod.S("Steam"),

  color = "#FFFFFF",

  aliases = {
    "yatm_core:steam"
  },

  groups = {
    gas = 1,
    steam = 1,
    water_based = 1,
  },

  tiles = {
    source = "yatm_steam_source.png",
    flowing = "yatm_steam_source.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
