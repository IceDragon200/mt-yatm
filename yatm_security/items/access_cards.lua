if not rawget(_G, "yatm_data_logic") then
  return
end

--
-- Access Cards are the Data equivalent of keys
-- Their corresponding lock is formed from an Access Chip
-- Unlike Keys and Locks however, they must be paired before hand in a 'Programmer's Table'
--
for _,row in ipairs(yatm.colors) do
  local basename = row.name
  local name = row.description

  minetest.register_craftitem("yatm_security:access_card_" .. basename, {
    basename = "yatm_security:access_card",
    base_description = "Access Card",

    description = "Access Card [" .. name .. "]",

    groups = {
      access_card = 1,
      table_programmable = 1,
    },

    inventory_image = "yatm_access_cards_" .. basename .. "_common.png",
    dye_color = basename,

    stack_max = 1,

    on_programmed = function (stack, data)
      local meta = stack:get_meta()
      yatm_security.set_access_card_prvkey(meta, data)

      local lock_id = string.sub(data, 1, 6)
      meta:set_string("lock_id", lock_id)
      local description = stack:get_definition().description .. " [Programmed] (" .. lock_id .. ")"
      meta:set_string("description", description)
      return stack
    end,
  })
end
