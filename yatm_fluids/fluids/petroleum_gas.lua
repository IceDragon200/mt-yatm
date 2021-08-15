-- Borrowed this from Factorio
yatm.fluids.fluid_registry.register("yatm_fluids", "petroleum_gas", {
  description = "Petroleum Gas",

  groups = {
    gas = 1,
    petroleum_gas = 1,
    explosive = 1,
    combustable = 1,
  },

  tiles = {
    source = "yatm_petroleum_gas_source.png",
    flowing = "yatm_petroleum_gas_flowing.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
