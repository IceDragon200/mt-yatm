--- @namespace yatm.units
yatm.units = {}

--- @const METRIC_PREFIXES: { [prefix: String]: Integer }
yatm.units.METRIC_PREFIXES = {}
for _, row in ipairs(foundation.com.ALL_PREFIXES) do
  yatm.units.METRIC_PREFIXES[row[1]] = row[3]
end

--- @const BINARY_PREFIXES: { [prefix: String]: Integer }
yatm.units.BINARY_PREFIXES = {}

for _, row in ipairs(foundation.com.BINARY_PREFIXES) do
  yatm.units.BINARY_PREFIXES[row[1]] = row[3]
end


local METRIC_PREFIXES = yatm.units.METRIC_PREFIXES
local BINARY_PREFIXES = yatm.units.BINARY_PREFIXES

--- @spec yatm.units.metric(value: Number, base?: String): Number
function yatm.units.metric(value, base)
  local base_value = 1
  if base then
    base_value = METRIC_PREFIXES[base]
  end
  return value / base_value
end

--- @spec yatm.units.binary(value: Number, base?: String): Number
function yatm.units.binary(value, base)
  local base_value = 1
  if base then
    base_value = BINARY_PREFIXES[base]
  end
  return value / base_value
end
