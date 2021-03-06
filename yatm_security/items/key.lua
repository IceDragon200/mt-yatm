local list_concat = assert(foundation.com.list_concat)

local materials = {
  {"carbon_steel", "Carbon Steel"},
  {"iron", "Iron"},
  {"gold", "Gold"},
}

for _,material_pair in ipairs(materials) do
  local material_basename = material_pair[1]
  local material_name = material_pair[2]

  for _,row in ipairs(yatm.colors_with_default) do
    local color_basename = row.name
    local color_name = row.description

    local key_states = {
      blank = "yatm_security:key_blank_" .. material_basename .. "_" .. color_basename,
      toothed = "yatm_security:key_toothed_" .. material_basename .. "_" .. color_basename,
      toothless = "yatm_security:key_toothless_" .. material_basename .. "_" .. color_basename,
    }

    minetest.register_craftitem(key_states.blank, {
      basename = "yatm_security:key_blank",
      base_description = "Blank Key",

      description = material_name .. " Blank Key [" .. color_name .. "]",
      groups = {
        lockable_key = 1,
        blank_key = 1,
      },
      inventory_image = "yatm_key_" .. material_basename .. "_" .. color_basename .. "_blank.png",
      dye_color = color_basename,
      key_states = key_states,
    })

    minetest.register_craftitem(key_states.toothed, {
      basename = "yatm_security:key_toothed",
      base_description = "Key",

      description = material_name .. " Key [" .. color_name .. "]",
      groups = {
        lockable_key = 1,
        toothed_key = 1,
        not_in_creative_inventory = 1,
      },
      inventory_image = "yatm_key_" .. material_basename .. "_" .. color_basename .. "_toothed.png",
      dye_color = color_basename,
      key_states = key_states,
      stack_max = 1,
    })

    -- These are broken keys
    minetest.register_craftitem(key_states.toothless, {
      basename = "yatm_security:key_toothless",
      base_description = "Toothless Key",

      description = material_name .. " Toothless Key [" .. color_name .. "]",
      groups = {
        lockable_key = 1,
        toothless_key = 1,
        not_in_creative_inventory = 1,
      },
      inventory_image = "yatm_key_" .. material_basename .. "_" .. color_basename .. "_toothless.png",
      dye_color = color_basename,
      key_states = key_states,
    })
  end
end
