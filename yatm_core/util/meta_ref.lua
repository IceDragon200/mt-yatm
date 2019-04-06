function yatm_core.metaref_dec_float(meta, name, amount)
  amount = amount or 1
  local n = meta:get_float(name)
  n = n - amount
  meta:set_float(name, n)
  return n
end

function yatm_core.metaref_dec_int(meta, name, amount)
  amount = amount or 1
  local n = meta:get_int(name)
  n = n - amount
  meta:set_int(name, n)
  return n
end

function yatm_core.metaref_inc_float(meta, name, amount)
  amount = amount or 1
  local n = meta:get_float(name)
  n = n + amount
  meta:set_float(name, n)
  return n
end

function yatm_core.metaref_inc_int(meta, name, amount)
  amount = amount or 1
  local n = meta:get_int(name)
  n = n + amount
  meta:set_int(name, n)
  return n
end
