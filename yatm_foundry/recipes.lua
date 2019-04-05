local tns = assert(yatm_core.time_network_seconds)
local FluidStack = assert(yatm.fluids.FluidStack)

--
-- Smelting Recipes
--
local SmeltingRegistry = assert(yatm.smelting.SmeltingRegistry)
local r = SmeltingRegistry:method("register_smelting_recipe")

r("Iron Ore to Molten Iron", ItemStack("default:stone_with_iron"), {FluidStack.new("yatm_foundry:molten_iron", 500)}, tns(2))
r("Copper Ore to Molten Copper", ItemStack("default:stone_with_copper"), {FluidStack.new("yatm_foundry:molten_copper", 500)}, tns(2))
r("Tin Ore to Molten Tin", ItemStack("default:stone_with_tin"), {FluidStack.new("yatm_foundry:molten_tin", 500)}, tns(2))
r("Gold Ore to Molten Gold", ItemStack("default:stone_with_gold"), {FluidStack.new("yatm_foundry:molten_gold", 500)}, tns(2))

r("Steel Block to Molten Steel", ItemStack("default:steelblock"), {FluidStack.new("yatm_foundry:molten_carbon_steel", 4250)}, tns(4))
r("Copper Block to Molten Copper", ItemStack("default:copperblock"), {FluidStack.new("yatm_foundry:molten_copper", 4250)}, tns(4))
r("Iron Block to Molten Iron", ItemStack("default:ironblock"), {FluidStack.new("yatm_foundry:molten_iron", 4250)}, tns(4))
r("Tin Block to Molten Tin", ItemStack("default:tinblock"), {FluidStack.new("yatm_foundry:molten_tin", 4250)}, tns(4))
r("Bronze Block to Molten Bronze", ItemStack("default:bronzeblock"), {FluidStack.new("yatm_foundry:molten_bronze", 4250)}, tns(4))

r("Iron Lump to Molten Iron", ItemStack("default:iron_lump"), {FluidStack.new("yatm_foundry:molten_iron", 250)}, tns(1))
r("Tin Lump to Molten Tin", ItemStack("default:tin_lump"), {FluidStack.new("yatm_foundry:molten_tin", 250)}, tns(1))
r("Copper Lump to Molten Copper", ItemStack("default:copper_lump"), {FluidStack.new("yatm_foundry:molten_copper", 250)}, tns(1))
r("Gold Lump to Molten Gold", ItemStack("default:gold_lump"), {FluidStack.new("yatm_foundry:molten_gold", 250)}, tns(1))

r("(Default) Steel Ingot to Molten Carbon Steel", ItemStack("default:steel_ingot"), {FluidStack.new("yatm_foundry:molten_carbon_steel", 250)}, tns(1))
r("(Default) Bronze Ingot to Molten Bronze", ItemStack("default:bronze_ingot"), {FluidStack.new("yatm_foundry:molten_bronze", 250)}, tns(1))
r("(Default) Iron Ingot to Molten Iron", ItemStack("default:iron_ingot"), {FluidStack.new("yatm_foundry:molten_iron", 250)}, tns(1))
r("(Default) Tin Ingot to Molten Tin", ItemStack("default:tin_ingot"), {FluidStack.new("yatm_foundry:molten_tin", 250)}, tns(1))
r("(Default) Copper Ingot to Molten Copper", ItemStack("default:copper_ingot"), {FluidStack.new("yatm_foundry:molten_copper", 250)}, tns(1))
r("(Default) Gold Ingot to Molten Gold", ItemStack("default:gold_ingot"), {FluidStack.new("yatm_foundry:molten_gold", 250)}, tns(1))

r("(YATM) Iron Ingot to Molten Iron", ItemStack("yatm_core:ingot_iron"), {FluidStack.new("yatm_foundry:molten_iron", 250)}, tns(1))
r("(YATM) Copper Ingot to Molten Copper", ItemStack("yatm_core:ingot_copper"), {FluidStack.new("yatm_foundry:molten_copper", 250)}, tns(1))
r("(YATM) Steel Ingot to Molten Carbon Steel", ItemStack("yatm_core:ingot_carbon_steel"), {FluidStack.new("yatm_foundry:molten_carbon_steel", 250)}, tns(1))
r("(YATM) Gold Ingot to Molten Gold", ItemStack("yatm_core:ingot_gold"), {FluidStack.new("yatm_foundry:molten_gold", 250)}, tns(1))
r("(YATM) Bronze Ingot to Molten Bronze", ItemStack("yatm_core:ingot_bronze"), {FluidStack.new("yatm_foundry:molten_bronze", 250)}, tns(1))

r("Iron Dust to Molten Iron", ItemStack("yatm_core:dust_iron"), {FluidStack.new("yatm_foundry:molten_iron", 250)}, tns(1))
r("Copper Dust to Molten Copper", ItemStack("yatm_core:dust_copper"), {FluidStack.new("yatm_foundry:molten_copper", 250)}, tns(1))
r("Tin Dust to Molten Tin", ItemStack("yatm_core:dust_tin"), {FluidStack.new("yatm_foundry:molten_tin", 250)}, tns(1))
r("Gold Dust to Molten Gold", ItemStack("yatm_core:dust_gold"), {FluidStack.new("yatm_foundry:molten_gold", 250)}, tns(1))
r("Bronze Dust to Molten Bronze", ItemStack("yatm_core:dust_bronze"), {FluidStack.new("yatm_foundry:molten_bronze", 250)}, tns(1))
r("Carbon Steel Dust to Molten Carbon Steel", ItemStack("yatm_core:dust_carbon_steel"), {FluidStack.new("yatm_foundry:molten_carbon_steel", 250)}, tns(1))

--
-- Molding Recipes
--
local MoldingRegistry = assert(yatm.smelting.MoldingRegistry)
local r = MoldingRegistry:method("register_molding_recipe")

local materials = {
  tin = "Tin",
  copper = "Copper",
  bronze = "Bronze",
  iron = "Iron",
  gold = "Gold",
  carbon_steel = "Carbon Steel",
}

for material_basename,material_name in pairs(materials) do
  r("Molten " .. material_name " to " .. material_name .. " Plate", ItemStack("yatm_foundry:mold_plate"), FluidStack.new("yatm_foundry:molten_" .. material_basename, 250), ItemStack("yatm_core:plate_" .. material_basename), tns(1))
  r("Molten " .. material_name " to " .. material_name .. " Ingot", ItemStack("yatm_foundry:mold_ingot"), FluidStack.new("yatm_foundry:molten_" .. material_basename, 250), ItemStack("yatm_core:ingot_" .. material_basename), tns(1))
  r("Molten " .. material_name " to " .. material_name .. " Gear",  ItemStack("yatm_foundry:mold_gear"),  FluidStack.new("yatm_foundry:molten_" .. material_basename, 500), ItemStack("yatm_core:gear_" .. material_basename), tns(1))
end

r("Molten Copper to Copper Block", ItemStack("yatm_foundry:mold_block"), FluidStack.new("yatm_foundry:molten_copper", 4250), ItemStack("default:copperblock"), tns(1))
r("Molten Tin to Tin Block", ItemStack("yatm_foundry:mold_block"), FluidStack.new("yatm_foundry:molten_tin", 4250), ItemStack("default:tinblock"), tns(1))
r("Molten Iron to Iron Block", ItemStack("yatm_foundry:mold_block"), FluidStack.new("yatm_foundry:molten_iron", 4250), ItemStack("default:ironblock"), tns(1))
r("Molten Gold to Gold Block", ItemStack("yatm_foundry:mold_block"), FluidStack.new("yatm_foundry:molten_gold", 4250), ItemStack("default:goldblock"), tns(1))
r("Molten Carbon Steel to Carbon Steel Block", ItemStack("yatm_foundry:mold_block"), FluidStack.new("yatm_foundry:molten_carbon_steel", 4250), ItemStack("yatm_core:carbon_stele_block"), tns(1))

--
-- Kiln Recipes
--
local KilnRegistry = assert(yatm.smelting.KilnRegistry)
local r = KilnRegistry:method("register_drying_recipe")
--r()

--
-- Blasting Recipes
--
local BlastingRegistry = assert(yatm.smelting.BlastingRegistry)
local r = BlastingRegistry:method("register_blasting_recipe")
r()
