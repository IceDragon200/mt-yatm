local mod = assert(yatm_fluids)

mod:require("fluids/corium.lua")
mod:require("fluids/crude_oil.lua")
mod:require("fluids/garfielium.lua")
mod:require("fluids/heavy_oil.lua")
mod:require("fluids/ice_slurry.lua")
mod:require("fluids/light_oil.lua")
mod:require("fluids/petroleum_gas.lua")
mod:require("fluids/steam.lua")
mod:require("fluids/oxygen.lua")
mod:require("fluids/hydrogen.lua")
mod:require("fluids/nitrogen.lua")
mod:require("fluids/argon.lua")
mod:require("fluids/methane.lua")
mod:require("fluids/hydrogen_sulphide.lua")
mod:require("fluids/sulphur_dioxide.lua")
mod:require("fluids/sulphur_trioxide.lua")
mod:require("fluids/sulphuric_acid_gas.lua")
mod:require("fluids/sulphuric_acid.lua")

if rawget(_G, "default") or rawget(_G, "nokore_world_water") then
  mod:require("fluids/river_water.lua")
  mod:require("fluids/water.lua")
end

if rawget(_G, "nokore_world_water") then
  mod:require("fluids/sea_water.lua")
end

if rawget(_G, "default") or rawget(_G, "nokore_world_lava") then
  mod:require("fluids/lava.lua")
end
