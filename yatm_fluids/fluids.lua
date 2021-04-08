yatm_fluids:require("fluids/corium.lua")
yatm_fluids:require("fluids/crude_oil.lua")
yatm_fluids:require("fluids/garfielium.lua")
yatm_fluids:require("fluids/heavy_oil.lua")
yatm_fluids:require("fluids/ice_slurry.lua")
yatm_fluids:require("fluids/light_oil.lua")
yatm_fluids:require("fluids/petroleum_gas.lua")
yatm_fluids:require("fluids/lava.lua")

if rawget(_G, "default") then
  yatm_fluids:require("fluids/river_water.lua")
  yatm_fluids:require("fluids/steam.lua")
  yatm_fluids:require("fluids/water.lua")
end
