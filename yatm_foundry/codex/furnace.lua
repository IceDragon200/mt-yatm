local mod = assert(yatm_foundry)

yatm.codex.register_entry("yatm_foundry:furnace", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_foundry:furnace_on",
      },
      heading = "Furnace",
      lines = {
        "Thermal furnace capable of cooking items using heat.",
      },
    },
  },
})
