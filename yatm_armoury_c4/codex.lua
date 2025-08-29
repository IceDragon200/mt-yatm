local mod = assert(yatm_armoury_c4)

yatm.codex.register_entry(mod:make_name("c4_tripwired"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("c4_tripwired"),
      },
      heading = mod.S("C4 (Tripwired)"),
      lines = {
      },
    },
  },
})

yatm.codex.register_entry(mod:make_name("c4_remote"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("c4_remote"),
      },
      heading = mod.S("C4 (Remote)"),
      lines = {
        "A C4 with a small radio receiver.",
      },
    },
  },
})
