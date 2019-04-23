function yatm_core.string_to_list(str)
  return {string.byte(str, 1, #str)}
end
