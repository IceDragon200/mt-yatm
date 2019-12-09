function yatm_core.number_lerp(a, b, t)
  return a + (b - a) * t
end

-- not sure what the correct name is for this function
function yatm_core.number_moveto(a, b, amt)
  if a < b then
    return math.min(a + amt, b)
  elseif a > b then
    return math.max(a - amt, b)
  end
  return a
end
