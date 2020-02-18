local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

for _,color in pairs(colors) do
  local color_basename = color[1]
  local color_name = color[2]

  minetest.register_craftitem("yatm_oku:floppy_disk_" .. color_basename, {
    basename = "yatm_oku:floppy_disk",
    base_description = "Floppy Disk",

    description = "Floppy Disk [" .. color_name .. "]",

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
