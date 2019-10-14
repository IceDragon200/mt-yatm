function yatm_core.path_join(a, b)
  local a = yatm_core.string_trim_trailing(a, "/")
  local b = yatm_core.string_trim_leading(b, "/")

  return a .. "/" .. b
end
