function yatm_spacetime.generate_address()
  local result = {}
  for i = 1,4 do
    table.insert(result, yatm_core.random_string16(4))
  end
  return table.concat(result, ":")
end
