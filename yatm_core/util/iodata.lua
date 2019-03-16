function yatm_core.iodata_to_string(value)
  if type(value) == "string" then
    return value
  elseif type(value) == "table" then
    local result = yatm_core.table_flatten(value)
    return table.concat(result)
  else
    error("unexpected value " .. dump(value))
  end
end
