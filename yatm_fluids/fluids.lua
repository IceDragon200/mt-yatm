yatm_fluids:require("fluids/corium.lua")
yatm_fluids:require("fluids/crude_oil.lua")
yatm_fluids:require("fluids/garfielium.lua")
yatm_fluids:require("fluids/heavy_oil.lua")
yatm_fluids:require("fluids/ice_slurry.lua")
yatm_fluids:require("fluids/light_oil.lua")
yatm_fluids:require("fluids/petroleum_gas.lua")
yatm_fluids:require("fluids/steam.lua")
yatm_fluids:require("fluids/oxygen.lua")
yatm_fluids:require("fluids/hydrogen.lua")

if rawget(_G, "default") or rawget(_G, "nokore_world_water") then
  yatm_fluids:require("fluids/river_water.lua")
  yatm_fluids:require("fluids/water.lua")
end

if rawget(_G, "nokore_world_water") then
  yatm_fluids:require("fluids/sea_water.lua")
end

if rawget(_G, "default") or rawget(_G, "nokore_world_lava") then
  yatm_fluids:require("fluids/lava.lua")
end
