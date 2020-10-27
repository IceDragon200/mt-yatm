local table_concat = assert(foundation.com.table_concat)

for _,row in ipairs(yatm.colors_with_default) do
  local basename = row.name
  local display_name = row.description

  minetest.register_craftitem("yatm_data_control:control_button_" .. basename, {
    basename = "yatm_data_control:control_button",
    base_description = "Control Button [Momentary Button]",

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
    basename = "yatm_data_control:control_switch",
    base_description = "Control Switch",

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
