--
-- YATM Energy
--
--[[
Provides YATM an energy interface
]]
yatm_energy = rawget(_G, "yatm_energy") or {}
yatm_energy.modpath = minetest.get_modpath(minetest.get_current_modname())

-- Helper function for dealing with energy
function yatm_energy.receive_energy(current_energy, energy, bandwidth, capacity)
  local received_energy = yatm_energy.allowed_energy(energy, bandwidth)
  local current_energy = current_energy + received_energy
  if current_energy > capacity then
    local over = current_energy - capacity
    received_energy = received_energy - over
  end
  return current_energy, received_energy
end

function yatm_energy.consume_energy(current_energy, energy, bandwidth, _capacity)
  local consumed_energy = yatm_energy.allowed_energy(energy, bandwidth)
  local current_energy = current_energy - consumed_energy
  if current_energy < 0 then
    local under = current_energy
    current_energy = 0
    consumed_energy = consumed_energy + under
  end
  return current_energy, consumed_energy
end

function yatm_energy.allowed_energy(energy, bandwidth)
  return math.min(energy, bandwidth)
end
