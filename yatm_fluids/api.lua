yatm.fluids = {
  FluidStack = assert(yatm_fluids.FluidStack),
  FluidTanks = assert(yatm_fluids.FluidTanks),
  FluidInterface = assert(yatm_fluids.FluidInterface),
  FluidMeta = assert(yatm_fluids.FluidMeta),
  FluidExchange = assert(yatm_fluids.FluidExchange),
  fluid_registry = assert(yatm_fluids.fluid_registry),
  FluidInventory = assert(yatm_fluids.FluidInventory),
  FluidInventoryRegistry = assert(yatm_fluids.FluidInventoryRegistry),
  fluid_inventories = yatm_fluids.FluidInventoryRegistry:new(),
  Utils = assert(yatm_fluids.Utils),
}
