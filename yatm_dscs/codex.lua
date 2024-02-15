local mod = assert(yatm_dscs)

yatm.codex.register_entry("yatm_dscs:inventory_controller", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_dscs:inventory_controller_off",
      },
      heading = mod.S("Inventory Controller"),
      lines = {
        "Inventory Controllers allow a DSCS network to access multiple storage devices.",
        "They are required for a Compute Module to locate items within the network.",
      },
    },
  },
})

yatm.codex.register_entry("yatm_dscs:void_chest", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_dscs:void_chest_off",
      },
      heading = mod.S("Void Chest"),
      lines = {
        "Void Chests are devices that allow accessing the contents of an Item Drive.",
        "While the it's origins are dubious, there is no doubt of its usefulness.",
        "Simply install an item drive in the respective slot and power it to see it's contents."
      },
    },
  },
})

yatm.codex.register_entry("yatm_dscs:void_crate", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_dscs:void_crate_off",
      },
      heading = mod.S("Void Crate"),
      lines = {
        "Void Crates are devices that allow accessing the contents of a Fluid Drive.",
        "While the its origins are dubious, there is no doubt of its usefulness.",
        "Simply install an item drive in the respective slot and power it to see it's contents."
      },
    },
  },
})
