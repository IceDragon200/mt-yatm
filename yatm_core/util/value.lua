function yatm_core.is_blank(value)
  if value == nil then
    return true
  elseif value == "" then
    return true
  else
    return false
  end
end
