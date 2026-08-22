--
-- Tokens are used as markers in formspecs, they aren't useful for anything else
--
local mod = assert(yatm_data_logic)

for _,row in ipairs(yatm.colors_with_default) do
  local basename = row.name
  local name = row.description

  core.register_craftitem("yatm_data_logic:token_" .. basename, {
    basename = "yatm_data_logic:token",
    base_description = mod.S("YATM Token"),

    short_description = mod.S("YATM Token [" .. name .. "]"),
    description = mod.S("YATM Token [" .. name .. "]"),

    groups = {
      token = 1,
    },

    inventory_image = "yatm_tokens_" .. basename .. ".png",
    dye_color = basename,
  })
end
