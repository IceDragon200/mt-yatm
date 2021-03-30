local number_lerp = assert(foundation.com.number_lerp)

yatm.thermal = yatm.thermal or {}

function yatm.thermal.set_heat(meta, name, amount)
  meta:set_float(name, amount)
end

function yatm.thermal.get_heat(meta, name)
  return meta:get_float(name)
end

function yatm.thermal.update_heat(meta, name, target_heat, amt, dtime)
  local available_heat = yatm.thermal.get_heat(meta, name)
  --local delta = amt * dtime
  local new_heat = number_lerp(available_heat, target_heat, dtime)
  yatm.thermal.set_heat(meta, name, new_heat)

  --print("update_heat", "target=" .. target_heat, "amt=" .. amt, "dtime=" .. dtime, "delta=" .. delta, "old_heat=" .. available_heat, "new_heat=" .. new_heat)
  return new_heat ~= available_heat
end
