minetest.log("info", "yatm is running in a nokore environment, checking this isn't a false positive")

if nokore.VERSION then
  minetest.log("info", "appears to be a legit nokore environment version=" .. nokore.VERSION)
  local node_sounds = assert(yatm.node_sounds)
  -- do stuff
  node_sounds:register("base", {
    sounds = {
      footstep = {name = "", gain = 1.0},
      dug = {name = "default_dug_node", gain = 0.25},
      place = {name = "default_place_node_hard", gain = 1.0},
    }
  })
  node_sounds:register("glass", {
    extends = { "base" },
    sounds = {
      footstep = {name = "default_glass_footstep", gain = 0.3},
      dig = {name = "default_glass_footstep", gain = 0.5},
      dug = {name = "default_break_glass", gain = 1.0},
    }
  })
  node_sounds:register("wood", {
    extends = { "base" },
    sounds = {
      footstep = {name = "default_wood_footstep", gain = 0.3},
      dug = {name = "default_wood_footstep", gain = 1.0},
    },
  })
  node_sounds:register("leaves", {
    extends = { "base" },
    sounds = {
      footstep = {name = "default_grass_footstep", gain = 0.45},
      dug = {name = "default_grass_footstep", gain = 0.7},
      place = {name = "default_place_node", gain = 1.0},
    }
  })
  node_sounds:register("metal", {
    extends = { "base" },
    sounds = {
      footstep = {name = "default_metal_footstep", gain = 0.4},
      dig = {name = "default_dig_metal", gain = 0.5},
      dug = {name = "default_dug_metal", gain = 0.5},
      place = {name = "default_place_node_metal", gain = 0.5},
    },
  })
  node_sounds:register("stone", {
    extends = { "base" },
    sounds = {
      footstep = {name = "default_hard_footstep", gain = 0.3},
      dug = {name = "default_hard_footstep", gain = 1.0},
    },
  })
  node_sounds:register("water", {
    extends = { "base" },
    sounds = {
      foostep = {name = "default_water_footstep", gain = 0.2},
    }
  })
  node_sounds:register("cardboard", {
    extends = { "base" },
    sounds = {

    }
  })
else
  minetest.log("error", "false positive nokore environment bailing, just to be safe")
  return
end
