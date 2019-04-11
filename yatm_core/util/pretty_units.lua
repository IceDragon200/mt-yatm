local PREFIXES = {
  --{"yotta", "Y", 1000000000000000000000000},
  --{"zetta", "Z", 1000000000000000000000},
  --{"exa", "E", 1000000000000000000},
  --{"peta", "P", 1000000000000000},
  {"tera", "T", 1000000000000},
  {"giga", "G", 1000000000},
  {"mega", "M", 1000000},
  {"kilo", "k", 1000},
  --{"hecto", "h", 100},
  --{"deca", "da", 10},
  {"", "", 1},
  --{"deci", "d", 0.1},
  --{"centi", "c", 0.01},
  {"milli", "m", 0.001},
  {"micro", "μ", 0.000001},
  {"nano", "n", 0.000000001},
  --{"pico", "p", 0.000000000001},
  --{"femto", "f", 0.000000000000001},
  --{"atto", "a", 0.000000000000000001},
  --{"zepto", "z", 0.000000000000000000001},
  --{"yocto", "y", 0.000000000000000000000001},
}

function yatm_core.format_pretty_unit(value, unit)
  unit = unit or ""
  local result = tostring(value)
  for _,row in ipairs(PREFIXES) do
    -- until the unit is less than the value
    if row[3] < value then
      result = string.format("%.2f", value / row[3]) .. row[2]
      break
    end
  end
  return result .. unit
end

local function pad_number(number, len)
  local str = tostring(number)
  -- the naive approach
  while #str < len do
    str = "0" .. str
  end
  return str
end

function yatm_core.format_pretty_time(value)
  value = math.floor(value)
  local hours = math.floor(value / 60 / 60)
  local minutes = math.floor(value / 60) % 60
  local seconds = math.floor(value % 60)

  if hours > 0 then
    return pad_number(hours, 2) .. ":" .. pad_number(minutes, 2) .. ":" .. pad_number(seconds, 2)
  elseif minutes > 0 then
    return pad_number(minutes, 2) .. ":" .. pad_number(seconds, 2)
  else
    return pad_number(seconds, 2)
  end
end
