yatm.codex.register_entry("yatm_armoury_icbm:icbm_silo", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_armoury_icbm:icbm_silo",
      },
      heading = "ICBM Silo",
      lines = {
        "ICBM Silos create, arm and launch ICBMs.",
        "They can be partially configured from the formspec.",
        "All other configuration must be done from a data interface.",
      },
    },
  },
})

yatm.codex.register_entry("yatm_armoury_icbm:icbm_guiding_ring", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_armoury_icbm:icbm_guiding_ring",
      },
      heading = "ICBM Guiding Ring",
      lines = {
        "ICBM Guiding Rings are decorative nodes when used normally.",
        "They become an important factor in the launch range of an ICBM.",
        "Stacked in a column, the ICBM to follow the rings.",
      },
    },
  },
})
