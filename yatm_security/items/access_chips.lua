if not rawget(_G, "yatm_data_logic") then
  return
end

--
-- Access Chips are the Data equivalent of Locks
-- They can be installed in place of a lock, and will require the use of an access card to unlock.
--
for _,row in ipairs(yatm.colors_with_default) do
  local basename = row.name
  local name = row.description

  -- Access chips that have been programmed cannot be stacked
  minetest.register_craftitem("yatm_security:access_chip_with_pins_" .. basename, {
    basename = "yatm_security:access_chip_with_pins",
    base_description = "Access Chip [Programmed]",

    description = "Access Chip [" .. name .. "] [Programmed]",

    groups = {
      access_chip = 1,
      not_in_creative_inventory = 1,
    },

    inventory_image = "yatm_access_chips_" .. basename .. "_with_pins.png",
    dye_color = basename,

    stack_max = 1,
  })

  -- Unprogrammed access chips can be stacked
  minetest.register_craftitem("yatm_security:access_chip_" .. basename, {
    basename = "yatm_security:access_chip",
    base_description = "Access Chip [Unprogrammed]",

    description = "Access Chip [Unprogrammed] (" .. name .. ")",

    groups = {
      blank_access_chip = 1,
      table_programmable = 1,
    },

    inventory_image = "yatm_access_chips_" .. basename .. "_common.png",
    dye_color = basename,
    programmed_chip = "yatm_security:access_chip_with_pins_" .. basename,

    on_programmed = function (stack, data)
      local new_stack = ItemStack({ name = stack:get_definition().programmed_chip, count = 1 })
      local meta = new_stack:get_meta()
      yatm_security.set_access_chip_pubkey(meta, data)

      local lock_id = string.sub(data, 1, 6)
      meta:set_string("lock_id", lock_id)
      meta:set_string("description", new_stack:get_definition().description .. " (" .. lock_id .. ")")
      return new_stack
    end,
  })
end
