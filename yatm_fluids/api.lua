yatm.fluids = {
  FluidStack = assert(yatm_fluids.FluidStack),
  FluidContainers = assert(yatm_fluids.FluidContainers),
  FluidTanks = assert(yatm_fluids.FluidTanks),
  FluidInterface = assert(yatm_fluids.FluidInterface),
  FluidMeta = assert(yatm_fluids.FluidMeta),
  FluidExchange = assert(yatm_fluids.FluidExchange),
  FluidInventory = assert(yatm_fluids.FluidInventory),
  FluidInventoryRegistry = assert(yatm_fluids.FluidInventoryRegistry),
  Utils = assert(yatm_fluids.Utils),
  formspec = assert(yatm_fluids.formspec),
  --
  fluid_registry = assert(yatm_fluids.fluid_registry),
  fluid_inventories = yatm_fluids.FluidInventoryRegistry:new(),
}
