if not yatm_data_logic then
  return
end

--
-- Access Chips are the Data equivalent of Locks
-- They can be installed in place of a lock, and will require the use of an access card to unlock.
--
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

  -- Access chips that have been programmed cannot be stacked
  minetest.register_craftitem("yatm_security:access_chip_with_pins_" .. color_basename, {
    basename = "yatm_security:access_chip_with_pins",
    base_description = "Access Chip (Programmed)",

    description = "Access Chip (Programmed) (" .. color_name .. ")",

    groups = {
      access_chip = 1,
      not_in_creative_inventory = 1,
    },

    inventory_image = "yatm_access_chips_" .. color_basename .. "_with_pins.png",
    dye_color = color_basename,

    stack_max = 1,
  })

  -- Unprogrammed access chips can be stacked
  minetest.register_craftitem("yatm_security:access_chip_" .. color_basename, {
    basename = "yatm_security:access_chip",
    base_description = "Access Chip (Unprogrammed)",

    description = "Access Chip (Unprogrammed) (" .. color_name .. ")",

    groups = {
      blank_access_chip = 1,
    },

    inventory_image = "yatm_access_chips_" .. color_basename .. "_common.png",
    dye_color = color_basename,
  })
end
