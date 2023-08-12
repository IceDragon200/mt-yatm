local mod = assert(yatm_oku)

for _,row in ipairs(yatm.colors) do
  local color_basename = row.name
  local color_name = row.description

  mod:register_craftitem("floppy_disk_" .. color_basename, {
    basename = mod:make_name("floppy_disk"),

    base_description = mod.S("Floppy Disk"),

    description = mod.S("Floppy Disk [" .. color_name .. "]"),

    groups = {
      floppy_disk = 1,
    },

    inventory_image = "yatm_floppy_disks_" .. color_basename .. "_common.png",
    dye_color = color_basename,

    stack_max = 1,

    floppy_disk = {
      -- around 16k, and only for simplicity
      size = 0x4000,
    }
  })
end
