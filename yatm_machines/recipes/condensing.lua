local FluidStack = yatm.fluids.FluidStack

local condensing_registry = assert(yatm.condensing.condensing_registry)

local reg = condensing_registry:method("register_condensing_recipe")

reg("yatm_machines:steam_to_water",
    FluidStack.new("yatm_fluids:steam", 100),
    FluidStack.new("default:water", 100),
    5.0)
