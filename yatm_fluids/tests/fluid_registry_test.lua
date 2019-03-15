local MetaRef = assert(yatm_core.FakeMetaRef)
local Luna = assert(yatm.Luna)

local m = assert(yatm.fluids.FluidRegistry)
local FluidStack = assert(yatm.fluids.FluidStack)

local case = Luna:new("yatm.fluids.FluidRegistry")

case:describe("item_name_to_fluid_name/1", function (t2)
  t2:test("can retrieve fluid names for registered fluid source blocks", function (t3)
    t3:assert_eq(m.item_name_to_fluid_name("default:water_source"), "default:water")
    t3:assert_eq(m.item_name_to_fluid_name("default:river_water_source"), "default:river_water")
    t3:assert_eq(m.item_name_to_fluid_name("default:lava_source"), "default:lava")
    t3:assert_eq(m.item_name_to_fluid_name("yatm_fluids:crude_oil_source"), "yatm_fluids:crude_oil")
    t3:assert_eq(m.item_name_to_fluid_name("yatm_fluids:heavy_oil_source"), "yatm_fluids:heavy_oil")
    t3:assert_eq(m.item_name_to_fluid_name("yatm_fluids:light_oil_source"), "yatm_fluids:light_oil")
    t3:assert_eq(m.item_name_to_fluid_name("yatm_fluids:corium_source"), "yatm_fluids:corium")
    t3:assert_eq(m.item_name_to_fluid_name("yatm_fluids:ice_slurry_source"), "yatm_fluids:ice_slurry")
  end)
end)

case:describe("fluid_name_to_tank_name/1", function (t2)
  t2:test("can retrieve tank names for registered fluids", function (t3)
    t3:assert_eq(m.fluid_name_to_tank_name("default:water"), "yatm_fluids:fluid_tank_default_water")
    t3:assert_eq(m.fluid_name_to_tank_name("default:river_water"), "yatm_fluids:fluid_tank_default_river_water")
    t3:assert_eq(m.fluid_name_to_tank_name("default:lava"), "yatm_fluids:fluid_tank_default_lava")
    t3:assert_eq(m.fluid_name_to_tank_name("yatm_fluids:crude_oil"), "yatm_fluids:fluid_tank_yatm_fluids_crude_oil")
    t3:assert_eq(m.fluid_name_to_tank_name("yatm_fluids:heavy_oil"), "yatm_fluids:fluid_tank_yatm_fluids_heavy_oil")
    t3:assert_eq(m.fluid_name_to_tank_name("yatm_fluids:light_oil"), "yatm_fluids:fluid_tank_yatm_fluids_light_oil")
    t3:assert_eq(m.fluid_name_to_tank_name("yatm_fluids:corium"), "yatm_fluids:fluid_tank_yatm_fluids_corium")
    t3:assert_eq(m.fluid_name_to_tank_name("yatm_fluids:ice_slurry"), "yatm_fluids:fluid_tank_yatm_fluids_ice_slurry")
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
