function yatm_core.register_fluid_nodes(basename, def)
  minetest.register_node(basename .. "_source", {
    description = def.description_base .. " Source",
    drawtype = "liquid",
    tiles = {
      {
        name = def.texture_basename .. "_source_animated.png",
        backface_culling = false,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0,
        },
      },
      {
        name = def.texture_basename .. "_source_animated.png",
        backface_culling = true,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0,
        },
      },
    },
    alpha = def.alpha or 255,
    paramtype = "light",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    is_ground_content = false,
    drop = "",
    drowning = 1,
    liquidtype = "source",
    liquid_alternative_flowing = basename .. "_flowing",
    liquid_alternative_source = basename .. "_source",
    liquid_viscosity = 1,
    post_effect_color = {a = 103, r = 216, g = 127, b = 51},
    groups = def.groups,
    sounds = default.node_sound_water_defaults(),
  })

  minetest.register_node(basename .. "_flowing", {
    description = "Flowing " .. def.description_base,
    drawtype = "flowingliquid",
    tiles = {def.texture_basename .. "_source.png"},
    special_tiles = {
      {
        name = def.texture_basename .. "_flowing_animated.png",
        backface_culling = false,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.8,
        },
      },
      {
        name = def.texture_basename .. "_flowing_animated.png",
        backface_culling = true,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.8,
        },
      },
    },
    alpha = def.alpha or 255,
    paramtype = "light",
    paramtype2 = "flowingliquid",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    is_ground_content = false,
    drop = "",
    drowning = 1,
    liquidtype = "flowing",
    liquid_alternative_flowing = basename .. "_flowing",
    liquid_alternative_source = basename .. "_source",
    liquid_viscosity = 1,
    post_effect_color = {a = 103, r = 216, g = 127, b = 51},
    groups = yatm_core.table_merge(def.groups, {not_in_creative_inventory = 1}),
    sounds = default.node_sound_water_defaults(),
  })
end

dofile(yatm_core.modpath .. "/fluids/oil.lua")
dofile(yatm_core.modpath .. "/fluids/light_oil.lua")
dofile(yatm_core.modpath .. "/fluids/heavy_oil.lua")
dofile(yatm_core.modpath .. "/fluids/petroleum_gas.lua")
dofile(yatm_core.modpath .. "/fluids/steam.lua")
dofile(yatm_core.modpath .. "/fluids/garfielium.lua")

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
