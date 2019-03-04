yatm_core.fluids.register("default:water", {
  groups = {
    water = 1,
  },
  node = {
    source = "default:water_source",
    flowing = "default:water_flowing",
  },
})

yatm_core.fluids.register("default:river_water", {
  groups = {
    water = 1,
  },
  node = {
    source = "default:river_water_source",
    flowing = "default:river_water_flowing",
  },
})

yatm_core.fluids.register("default:lava", {
  groups = {
    lava = 1,
  },
  node = {
    source = "default:lava_source",
    flowing = "default:lava_flowing",
  },
})

yatm_core.fluids.register("yatm_core:steam", {
  groups = {
    steam = 1,
  },
  tiles = {
    source = "steam_source.png",
    flowing = "steam_source.png",
  },
})
