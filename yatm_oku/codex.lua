local mod = yatm_oku

yatm.codex.register_entry(mod:make_name("computer"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("computer"),
      },
      heading = mod.S("Computer"),
      lines = {
        "A programmable device to executing instructions in a device network.",
      },
    },
  },
})

yatm.codex.register_entry(mod:make_name("floppy_disk_drive"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("floppy_disk_drive"),
      },
      heading = mod.S("Floppy Disk Drive"),
      lines = {
        "A secondary storage device.",
      },
    },
  },
})

yatm.codex.register_entry(mod:make_name("oku_micro_controller"), {
  pages = {
    {
      heading_item = {
        context = true,
        default = mod:make_name("oku_micro_controller"),
      },
      heading = mod.S("OKU Micro Controller"),
      lines = {
        "A slightly underpowered computer.",
      },
    },
  },
})
