function yatm_core.string_starts_with(str, expected)
  return expected == "" or string.sub(str, 1, #expected) == expected
end

function yatm_core.string_ends_with(str, expected)
  return expected == "" or string.sub(str, -#expected) == expected
end
