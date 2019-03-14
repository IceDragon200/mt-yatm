yatm_spacetime.teleporter_address_schema = yatm_core.MetaSchema.new("teleporter_address", "", {
  address = { type = "string" },
})

local BASENAME = "spaddr"

function yatm_spacetime.generate_address()
  local result = {}
  for i = 1,4 do
    table.insert(result, yatm_core.random_string16(4))
  end
  return table.concat(result, ":")
end

function yatm_spacetime.get_address_in_meta(src)
  return yatm_spacetime.teleporter_address_schema:get_field(src, BASENAME, "address")
end

function yatm_spacetime.set_address_in_meta(dest, address)
  yatm_spacetime.teleporter_address_schema:set_field(dest, BASENAME, "address", address)
end

function yatm_spacetime.patch_address_in_meta(dest, new_address)
  local old_address = yatm_spacetime.get_address_in_meta(dest)
  if yatm_core.is_blank(old_address) then
    new_address = new_address or yatm_spacetime.generate_address()
    yatm_spacetime.set_address_in_meta(dest, new_address)
  else
    new_address = old_address
  end
  return new_address
end

function yatm_spacetime.copy_address_in_meta(src, dest)
  local address = yatm_spacetime.get_address_in_meta(src)
  yatm_spacetime.set_address_in_meta(dest, address)
  return address
end
