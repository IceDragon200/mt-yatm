local sawing_registry = assert(yatm.sawing.sawing_registry)

local wood_types = {}

-- First check for the default stairs mod
local has_stairs = rawget(_G, "stairs") ~= nil
-- And check if we have nokore_stairs
local has_nokore_stairs = foundation.is_module_present("nokore_stairs")
-- If we have any stairs that will work as well
local has_any_stairs = has_stairs or has_nokore_stairs

if foundation.is_module_present("nokore_world_tree_acacia") then
  wood_types.acacia = true
end

if foundation.is_module_present("nokore_world_tree_big_oak") then
  wood_types.big_oak = true
end

if foundation.is_module_present("nokore_world_tree_birch") then
  wood_types.birch = true
end

if foundation.is_module_present("nokore_world_tree_fir") then
  wood_types.fir = true
end

if foundation.is_module_present("nokore_world_tree_jungle") then
  wood_types.jungle = true
end

if foundation.is_module_present("nokore_world_tree_oak") then
  wood_types.oak = true
end

if foundation.is_module_present("nokore_world_tree_sakura") then
  wood_types.sakura = true
end

if foundation.is_module_present("nokore_world_tree_spruce") then
  wood_types.spruce = true
end

if foundation.is_module_present("nokore_world_tree_willow") then
  wood_types.willow = true
end

--
-- Sawing Recipes
--
local reg = sawing_registry:method("register_sawing_recipe")

for wood_type,_ in pairs(wood_types) do
  local log_name = "nokore_world_tree_"..wood_type..":"..wood_type.."_log"
  local core_name = "yatm_woodcraft:"..wood_type.."_log_core"
  local bark_name = "yatm_woodcraft:"..wood_type.."_log_bark"
  local planks_name = "nokore_world_tree_"..wood_type..":"..wood_type.."_planks"
  local slab_name = "nokore_world_tree_"..wood_type..":"..wood_type.."_planks_slab"
  local panel_name = "nokore_world_tree_"..wood_type..":"..wood_type.."_planks_panel"

  -- Log to Core & Bark
  reg("yatm_woodcraft:"..wood_type.."_log_to_core_and_barks",
      ItemStack(log_name),
      {
        ItemStack(core_name),
        ItemStack(bark_name .. " 4"),
      },
      0.25)

  -- Core to Planks
  reg("yatm_woodcraft:"..wood_type.."log_core_to_planks",
      ItemStack(core_name),
      {
        ItemStack(planks_name .. " 6"),
      },
      0.25)

  --
  -- Planks to Slabs
  --
  if has_any_stairs then
    reg("yatm_woodcraft:"..wood_type.."_planks_to_slabs",
        ItemStack(planks_name),
        {
          ItemStack(slab_name.." 2"),
        },
        0.25)
  end

  --
  -- Slabs to Panels
  --
  -- Slabs are half of a plank, which doing the math, is 8px tall
  -- Panels or Plates are 2px tall, so `slab > panel` should produce 4 panels.
  if has_any_stairs then
    reg("yatm_woodcraft:"..wood_type.."_slabs_to_panels",
        ItemStack(slab_name),
        {
          ItemStack(panel_name.." 4"),
        },
        0.25)
  else
    --
    -- Fallback Plank to Panels
    --
    -- If no stairs mod is present, skip the slabs and go straight to panels
    yatm.info("Falling back to plank to panel recipes")

    reg("yatm_woodcraft:"..wood_type.."_planks_to_panels",
        ItemStack(planks_name),
        {
          ItemStack(panel_name.." 8"),
        },
        0.25)
  end
end
