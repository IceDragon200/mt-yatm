local sawing_registry = assert(yatm.sawing.sawing_registry)

--
-- Sawing Recipes
--
local reg = sawing_registry:method("register_sawing_recipe")

-- Wood to Core & Bark
reg("yatm_woodcraft:oak_wood_to_core_and_bark",
    ItemStack("default:tree"),
    {
      ItemStack("yatm_woodcraft:oak_wood_core"),
      ItemStack("yatm_woodcraft:oak_wood_bark 4"),
    },
    0.25)

reg("yatm_woodcraft:jungle_wood_to_core_and_bark",
    ItemStack("default:jungletree"),
    {
      ItemStack("yatm_woodcraft:jungle_wood_core"),
      ItemStack("yatm_woodcraft:jungle_wood_bark 4"),
    },
    0.25)

reg("yatm_woodcraft:pine_wood_to_core_and_bark",
    ItemStack("default:pine_tree"),
    {
      ItemStack("yatm_woodcraft:pine_wood_core"),
      ItemStack("yatm_woodcraft:pine_wood_bark 4"),
    },
    0.25)

reg("yatm_woodcraft:acacia_wood_to_core_and_bark",
    ItemStack("default:acacia_tree"),
    {
      ItemStack("yatm_woodcraft:acacia_wood_core"),
      ItemStack("yatm_woodcraft:acacia_wood_bark 4"),
    },
    0.25)

reg("yatm_woodcraft:aspen_wood_to_core_and_bark",
    ItemStack("default:aspen_tree"),
    {
      ItemStack("yatm_woodcraft:aspen_wood_core"),
      ItemStack("yatm_woodcraft:aspen_wood_bark 4"),
    },
    0.25)

-- Core to Planks
reg("yatm_woodcraft:oak_core_to_planks",
    ItemStack("yatm_woodcraft:oak_wood_core"),
    {
      ItemStack("default:wood 6"),
    },
    0.25)

reg("yatm_woodcraft:jungle_core_to_planks",
    ItemStack("yatm_woodcraft:jungle_wood_core"),
    {
      ItemStack("default:junglewood 6"),
    },
    0.25)

reg("yatm_woodcraft:pine_core_to_planks",
    ItemStack("yatm_woodcraft:pine_wood_core"),
    {
      ItemStack("default:pine_wood 6"),
    },
    0.25)

reg("yatm_woodcraft:acacia_core_to_planks",
    ItemStack("yatm_woodcraft:acacia_wood_core"),
    {
      ItemStack("default:acacia_wood 6"),
    },
    0.25)

reg("yatm_woodcraft:aspen_core_to_planks",
    ItemStack("yatm_woodcraft:aspen_wood_core"),
    {
      ItemStack("default:aspen_wood 6"),
    },
    0.25)

-- Planks to Slabs
if stairs then
  reg("yatm_woodcraft:oak_planks_to_slabs",
      ItemStack("default:wood"),
      {
        ItemStack("stairs:slab_wood 2"),
      },
      0.25)

  reg("yatm_woodcraft:jungle_planks_to_slabs",
      ItemStack("default:junglewood"),
      {
        ItemStack("stairs:slab_junglewood 2"),
      },
      0.25)

  reg("yatm_woodcraft:pine_planks_to_slabs",
      ItemStack("default:pine_wood"),
      {
        ItemStack("stairs:slab_pine_wood 2"),
      },
      0.25)

  reg("yatm_woodcraft:acacia_planks_to_slabs",
      ItemStack("default:acacia_wood"),
      {
        ItemStack("stairs:slab_acacia_wood 2"),
      },
      0.25)

  reg("yatm_woodcraft:aspen_planks_to_slabs",
      ItemStack("default:aspen_wood"),
      {
        ItemStack("stairs:slab_aspen_wood 2"),
      },
      0.25)
end

-- Slabs to Panels
-- Slabs are half of a plank, which doing the math, is 8px tall
-- Panels or Plates are 2px tall, so `slab > panel` should produce 4 panels.
if stairs then
  reg("yatm_woodcraft:oak_slabs_to_panels",
      ItemStack("stairs:slab_wood"),
      {
        ItemStack("yatm_woodcraft:oak_wood_panel 4"),
      },
      0.25)

  reg("yatm_woodcraft:jungle_slabs_to_panels",
      ItemStack("stairs:slab_junglewood"),
      {
        ItemStack("yatm_woodcraft:jungle_wood_panel 4"),
      },
      0.25)

  reg("yatm_woodcraft:pine_slabs_to_panels",
      ItemStack("stairs:slab_pine_wood"),
      {
        ItemStack("yatm_woodcraft:pine_wood_panel 4"),
      },
      0.25)

  reg("yatm_woodcraft:acacia_slabs_to_panels",
      ItemStack("stairs:slab_acacia_wood"),
      {
        ItemStack("yatm_woodcraft:acacia_wood_panel 4"),
      },
      0.25)

  reg("yatm_woodcraft:aspen_slabs_to_panels",
      ItemStack("stairs:slab_aspen_wood"),
      {
        ItemStack("yatm_woodcraft:aspen_wood_panel 4"),
      },
      0.25)
end

-- Fallback Plank to Panels
if not stairs then
  yatm.info("Falling back to plank to panel recipes")

  reg("yatm_woodcraft:oak_planks_to_panels",
      ItemStack("default:wood"),
      {
        ItemStack("yatm_woodcraft:oak_wood_panel 8"),
      },
      0.25)

  reg("yatm_woodcraft:jungle_planks_to_panels",
      ItemStack("default:junglewood"),
      {
        ItemStack("yatm_woodcraft:jungle_wood_panel 8"),
      },
      0.25)

  reg("yatm_woodcraft:pine_planks_to_panels",
      ItemStack("default:pine_wood"),
      {
        ItemStack("yatm_woodcraft:pine_wood_panel 8"),
      },
      0.25)

  reg("yatm_woodcraft:acacia_planks_to_panels",
      ItemStack("default:acacia_wood"),
      {
        ItemStack("yatm_woodcraft:acacia_wood_panel 8"),
      },
      0.25)

  reg("yatm_woodcraft:aspen_planks_to_panels",
      ItemStack("default:aspen_wood"),
      {
        ItemStack("yatm_woodcraft:aspen_wood_panel 8"),
      },
      0.25)
end

if yatm_machines then
  local compacting_registry = assert(yatm.compacting.compacting_registry)
  local reg = compacting_registry:method("register_compacting_recipe")

  reg("yatm_woodcraft:compact_saw_dust",
      -- It requires 4x more sawdust to make a packed sawdust block
      ItemStack("yatm_woodcraft:sawdust 36"),
      ItemStack("yatm_woodcraft:packed_sawdust_block 1"),
      5.0)
end