yatm_foundry.blasting_registry = yatm_foundry.BlastingRegistry:new()
yatm_foundry.molding_registry = yatm_foundry.MoldingRegistry:new()
yatm_foundry.kiln_registry = yatm_foundry.KilnRegistry:new()
yatm_foundry.smelting_registry = yatm_foundry.SmeltingRegistry:new()

yatm.blasting = {
  blasting_registry = assert(yatm_foundry.blasting_registry),
}
yatm.smelting = {
  smelting_registry = assert(yatm_foundry.smelting_registry),
}
yatm.kiln = {
  kiln_registry = assert(yatm_foundry.kiln_registry),
}
yatm.molding = {
  molding_registry = assert(yatm_foundry.molding_registry),
}
