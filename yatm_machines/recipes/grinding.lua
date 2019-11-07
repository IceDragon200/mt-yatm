local grinding_registry = assert(yatm.grinding.grinding_registry)

local rgr = grinding_registry:method("register_grinding_recipe")

--
-- Iron
--
rgr("Iron Ore to Iron Dust",
    ItemStack("default:stone_with_iron"),
    {ItemStack("yatm_core:dust_iron 3"), ItemStack("default:gravel")},
    2)

rgr("Iron Ingot to Iron Dust",
    ItemStack("yatm_core:ingot_iron"),
    {ItemStack("yatm_core:dust_iron")},
    1)

rgr("Iron Block to Iron Dust",
    ItemStack("yatm_core:iron_block"),
    {ItemStack("yatm_core:dust_iron 9")},
    5)

--
-- Carbon Steel
--
rgr("Carbon Steel Ingot to Carbon Steel Dust",
    ItemStack("yatm_core:ingot_carbon_steel"),
    {ItemStack("yatm_core:dust_carbon_steel")},
    1)

rgr("Carbon Steel Block to Carbon Steel Dust",
    ItemStack("yatm_foundry:carbon_steel_block"),
    {ItemStack("yatm_core:dust_carbon_steel 9")},
    5)

--
-- Default Steel
--
rgr("Steel Ingot (default) to Carbon Steel Dust",
    ItemStack("default:steel_ingot"),
    {ItemStack("yatm_core:dust_carbon_steel")},
    1)

rgr("Steel Block (default) to Carbon Steel Dust",
    ItemStack("default:steelblock"),
    {ItemStack("yatm_core:dust_carbon_steel 9")},
    5)

--
-- Copper
--
rgr("Copper Ore to Copper Dust",
    ItemStack("default:stone_with_copper"),
    {ItemStack("yatm_core:dust_copper 3"), ItemStack("default:gravel")},
    2)

rgr("Copper Ingot (default) to Copper Dust",
    ItemStack("default:copper_ingot"),
    {ItemStack("yatm_core:dust_copper 1")},
    1)

rgr("Copper Ingot to Copper Dust",
    ItemStack("yatm_core:ingot_copper"),
    {ItemStack("yatm_core:dust_copper 1")},
    1)

rgr("Copper Block (default) to Copper Dust",
    ItemStack("default:copperblock"),
    {ItemStack("yatm_core:dust_copper 9")},
    5)

rgr("Copper Block to Copper Dust",
    ItemStack("yatm_core:copper_block"),
    {ItemStack("yatm_core:dust_copper 9")},
    5)

--
-- Tin
--
rgr("Tin Ore to Tin Dust",
    ItemStack("default:stone_with_tin"),
    {ItemStack("yatm_core:dust_tin 3")},
    2)

rgr("Tin Ingot to Tin Dust",
    ItemStack("default:tin_ingot"),
    {ItemStack("yatm_core:dust_tin")},
    1)

rgr("Tin Block to Tin Dust",
    ItemStack("default:tinblock"),
    {ItemStack("yatm_core:dust_tin 9")},
    5)

--
-- Gold
--
rgr("Gold Ore to Gold Dust",
    ItemStack("default:stone_with_goal"),
    {ItemStack("yatm_core:dust_gold 3"), ItemStack("default:gravel")},
    2)

rgr("Gold Ingot to Gold Dust",
    ItemStack("default:gold_ingot"),
    {ItemStack("yatm_core:dust_gold 1")},
    1)

rgr("Gold Block (default) to Gold Dust",
    ItemStack("default:goldblock"),
    {ItemStack("yatm_core:dust_gold 9")},
    5)

--
-- Coal
--
rgr("Coal Ore to Coal Dust",
    ItemStack("default:stone_with_coal"),
    {ItemStack("yatm_core:dust_coal 3"), ItemStack("default:gravel")},
    2)

rgr("Coal Chunk to Coal Dust",
    ItemStack("default:coal_lump"),
    {ItemStack("yatm_core:dust_coal 1")},
    1)

rgr("Coal Block to Coal Dust",
    ItemStack("default:coal_lump"),
    {ItemStack("yatm_core:dust_coal 9")},
    5)

--
-- Stone
--
rgr("Stone to Gravel",
    ItemStack("default:stone"),
    {ItemStack("default:gravel 2")},
    3)

rgr("Cobblestone to Gravel",
    ItemStack("default:cobble"),
    {ItemStack("default:gravel 2")},
    2)

rgr("Gravel to Sand",
    ItemStack("default:gravel"),
    {ItemStack("default:sand 2")},
    1)
