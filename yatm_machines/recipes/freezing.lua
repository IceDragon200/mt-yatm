local FluidStack = yatm.fluids.FluidStack

local freezing_registry = assert(yatm.freezing.freezing_registry)

local rifr = freezing_registry:method("register_item_freezing_recipe")
local rffr = freezing_registry:method("register_fluid_freezing_recipe")

--
-- Item Recipes
--

-- Nothing here at the moment, sad >:

--
-- Fluid Recipes
--

-- River water contains less salt - fresh water, so it's easier to freeze
rffr("yatm_machines:freeze_river_water",
    FluidStack.new("default:river_water", 1000),
    ItemStack("default:ice", 1),
    4.0
    )

-- On the other hand, there is water in general, or sea water which contains salt, takes a bit longer to freeze.
rffr("yatm_machines:freeze_water",
    FluidStack.new("default:water", 1000),
    ItemStack("default:ice", 1),
    6.0
    )
