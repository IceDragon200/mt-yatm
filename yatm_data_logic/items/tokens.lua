--
-- Tokens are used as markers in formspecs, they aren't useful for anything else
--
for _,row in ipairs(yatm.colors_with_default) do
  local basename = row.name
  local name = row.description

  minetest.register_craftitem("yatm_data_logic:token_" .. basename, {
    basename = "yatm_data_logic:token",
    base_description = "YATM Token",

    description = "YATM Token [" .. name .. "]",

    groups = {
      token = 1,
    },

    inventory_image = "yatm_tokens_" .. basename .. ".png",
    dye_color = basename,
  })
end
