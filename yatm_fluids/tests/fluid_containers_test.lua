local Luna = assert(yatm.Luna)

local FluidContainers = assert(yatm_fluids.FluidContainers)

local case = Luna:new("yatm.fluids.FluidContainers")

case:execute()
case:display_stats()
case:maybe_error()
