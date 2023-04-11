--- @namespace yatm.fluids

yatm.fluids = {
  --- @const FluidStack = yatm_fluids.FluidStack
  FluidStack = assert(yatm_fluids.FluidStack),
  --- @const FluidContainers = yatm_fluids.FluidContainers
  FluidContainers = assert(yatm_fluids.FluidContainers),
  --- @const FluidTanks = yatm_fluids.FluidTanks
  FluidTanks = assert(yatm_fluids.FluidTanks),
  --- @const FluidInterface = yatm_fluids.FluidInterface
  FluidInterface = assert(yatm_fluids.FluidInterface),
  --- @const FluidMeta = yatm_fluids.FluidMeta
  FluidMeta = assert(yatm_fluids.FluidMeta),
  --- @const FluidExchange = yatm_fluids.FluidExchange
  FluidExchange = assert(yatm_fluids.FluidExchange),
  --- @const FluidInventory = yatm_fluids.FluidInventory
  FluidInventory = assert(yatm_fluids.FluidInventory),
  --- @const FluidInventoryRegistry = yatm_fluids.FluidInventoryRegistry
  FluidInventoryRegistry = assert(yatm_fluids.FluidInventoryRegistry),
  --- @const Utils = yatm_fluid.Utils
  Utils = assert(yatm_fluids.Utils),
  --- @const fluid_registry = yatm_fluid.fluid_registry
  fluid_registry = assert(yatm_fluids.fluid_registry),
  --- @const fluid_inventories: yatm_fluids.FluidInventoryRegistry
  fluid_inventories = yatm_fluids.FluidInventoryRegistry:new(),
}
