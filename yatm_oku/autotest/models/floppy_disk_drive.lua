local mod = assert(yatm_oku)

mod.autotest_suite:define_model("floppy_disk_drive", {
  state = {
    node = { name = mod:make_name("floppy_disk_drive_off") },
  },

  properties = {
    {
      property = "is_computer",
    },
    {
      property = "is_machine_like",
    },
  }
})
