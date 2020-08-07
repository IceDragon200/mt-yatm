local random_string16 = assert(foundation.com.random_string16)

function yatm_spacetime.generate_address()
  local result = {}
  for i = 1,4 do
    table.insert(result, random_string16(4))
  end
  return table.concat(result, ":")
end
