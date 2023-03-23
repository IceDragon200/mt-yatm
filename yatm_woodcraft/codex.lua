local mod = yatm_woodcraft

yatm.codex.register_entry(mod:make_name("sawmill"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("sawmill"),
      },
      heading = mod.S("Sawmill"),
      lines = {
        "A simple machine for cutting wood into more components.",
      },
    },
  },
})

yatm.codex.register_entry(mod:make_name("dust_bin"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("yatm_woodcraft:dust_bin_sawdust"),
      },
      heading = mod.S("Dust Bin"),
      lines = {
        "A simple machine for cutting wood into more components.",
      },
    },
  },
})
