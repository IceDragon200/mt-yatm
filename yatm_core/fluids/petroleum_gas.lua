-- Borrowed this from Factorio
yatm_core.register_fluid_nodes("yatm_core:petroleum_gas", {
  description_base = "Petroleum Gas",
  texture_basename = "yatm_petroleum_gas",
  groups = { oil = 1, gas = 1, petroleum_gas = 1, liquid = 3, explosive = 1 },
})

yatm_core.fluids.register("yatm_core:petroleum_gas", {
  groups = {
    gas = 1,
    petroleum_gas = 1,
    explosive = 1,
  },
  tiles = {
    source = "yatm_petroleum_gas_source",
    flowing = "yatm_petroleum_gas_flowing",
  },
})
