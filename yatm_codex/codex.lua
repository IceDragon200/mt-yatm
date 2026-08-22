local mod = assert(yatm_codex)

yatm.codex.register_entry(mod:make_name("codex"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("codex"),
      },
      heading = mod.S("CODEX"),
      lines = {
        "The CODEX was a device gifted to the people of Harmonia by the goddess Belle.",
        "She granted the knowledge of the land freely to everyone in hopes that they would grow.",
      },
    },
  },
})

yatm.codex.register_entry(mod:make_name("codex_deploy"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("codex_deploy"),
      },
      heading = mod.S("CODEX [Deployment Mode]"),
      lines = {
        "A CODEX in deployment mode.",
      },
    },
  },
})
