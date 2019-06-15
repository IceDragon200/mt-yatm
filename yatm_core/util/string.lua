function yatm_core.string_starts_with(str, expected)
  return expected == "" or string.sub(str, 1, #expected) == expected
end

function yatm_core.string_ends_with(str, expected)
  return expected == "" or string.sub(str, -#expected) == expected
end

-- https://stackoverflow.com/a/1647577
-- Modified for this
function yatm_core.string_split_iter(str, pat)
  pat = pat or '%s+'
  local st, g = 1, str:gmatch("()("..pat..")")
  local function getter(segs, seps, sep, cap1, ...)
    st = sep and seps + #sep
    return str:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end

  return function()
    if st then
      return getter(st, g())
    end
  end
end

-- @spec split(String.t, String.t) :: {String.t}
function yatm_core.string_split(str, pattern)
  local result = {}
  local iter = yatm_core.string_split_iter(str, pattern)
  local item = iter()
  local i = 0
  while item do
    i = i + 1
    result[i] = item
    item = iter()
  end
  return result
end
