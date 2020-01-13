local colors = {
  {"default", "default"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = yatm_core.table_concat(colors, dye.dyes)
else
  print("yatm_data_control", "dye is not available, lamps will only be available in white")
end

for _,pair in ipairs(colors) do
  local basename = pair[1]
  local display_name = pair[2]

  minetest.register_craftitem("yatm_data_control:control_button_" .. basename, {
    description = "Control Button [Momentary Button] (" .. display_name .. ")",

    group = {
      data_control = 1,
      data_control_momentary_button = 1,
    },

    dye_color = basename,
    inventory_image = "yatm_colored_buttons_" .. basename .. ".off.png",

    data_control_spec = {
      type = "momentary_button",
      images = {
        off = "yatm_colored_buttons_" .. basename .. ".off.png",
        on = "yatm_colored_buttons_" .. basename .. ".on.png",
      },
    },
  })

  minetest.register_craftitem("yatm_data_control:control_switch_" .. basename, {
    description = "Control Switch (" .. display_name .. ")",

    group = {
      data_control = 1,
      data_control_switch = 1,
    },

    dye_color = basename,
    inventory_image = "yatm_colored_switches_" .. basename .. ".left.png",

    data_control_spec = {
      type = "switch2",
      images = {
        left = "yatm_colored_switches_" .. basename .. ".left.png",
        right = "yatm_colored_switches_" .. basename .. ".right.png",
      },
    },
  })
end
