local number_lerp = assert(foundation.com.number_lerp)

yatm.thermal = yatm.thermal or {}

function yatm.thermal.update_heat(meta, name, target_heat, amt, dtime)
  local available_heat = meta:get_float(name)
  --local delta = amt * dtime
  local new_heat = number_lerp(available_heat, target_heat, dtime)
  meta:set_float(name, new_heat)

  --print("update_heat", "target=" .. target_heat, "amt=" .. amt, "dtime=" .. dtime, "delta=" .. delta, "old_heat=" .. available_heat, "new_heat=" .. new_heat)
  return new_heat ~= available_heat
end
