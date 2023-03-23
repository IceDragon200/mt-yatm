local mod = assert(yatm_woodcraft)

mod:register_node("packed_sawdust_block", {
  description = mod.S("Packed Sawdust Block"),

  groups = {
    -- Packed Sawdust is slight more difficult to chop through
    choppy = nokore.dig_class("copper"),
    packed_sawdust = 1,
  },

  tiles = {
    "yatm_sawdust_packed.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",
  place_param2 = 0,

  sounds = nokore.node_sounds:build("wood"),
})

if foundation.is_module_present("nokore_stairs") then
  nokore_stairs.build_and_register_nodes(mod:make_name("packed_sawdust_block"), {
    -- base
    _ = {
      groups = {
        choppy = nokore.dig_class("copper"),
        packed_sawdust = 1,
      },
      use_texture_alpha = "opaque",
      tiles = "yatm_sawdust_packed.png",
      sounds = nokore.node_sounds:build("wood"),
    },
    column = {
      description = mod.S("Packed Sawdust Column"),
    },
    plate = {
      description = mod.S("Packed Sawdust Plate"),
    },
    slab = {
      description = mod.S("Packed Sawdust Slab"),
    },
    stair = {
      description = mod.S("Packed Sawdust Stair"),
    },
    stair_inner = {
      description = mod.S("Packed Sawdust Stair Inner"),
    },
    stair_outer = {
      description = mod.S("Packed Sawdust Stair Outer"),
    },
  })
end
