--[[
Provides some utility functions for dealing with energy in YATM
]]
local energy = {}

energy.schema = yatm_core.MetaSchema:new("energy", "", {
  energy = {
    type = "integer",
  },
})

-- Helper function for dealing with energy
function energy.allowed_energy(energy, bandwidth)
  assert(energy, "expected energy to be present")
  if bandwidth then
    return math.min(energy, bandwidth)
  else
    return energy
  end
end

function energy.calc_received_energy(stored_energy, amount, bandwidth, capacity)
  local new_amount = energy.allowed_energy(amount, bandwidth)
  local new_stored_energy = math.min(stored_energy + new_amount, capacity)
  return new_stored_energy, new_stored_energy - stored_energy
end

function energy.calc_consumed_energy(stored_energy, amount, bandwidth, _capacity)
  local new_amount = energy.allowed_energy(amount, bandwidth)
  local new_stored_energy = math.max(stored_energy - new_amount, 0)
  return new_stored_energy, stored_energy - new_stored_energy
end

function energy.get_energy(meta, key)
  return energy.schema:get_field(meta, key, "energy")
end

function energy.get_energy_throughput(meta, key, bandwidth)
  return math.min(energy.get_energy(meta, key), bandwidth)
end

function energy.set_energy(meta, key, energy)
  energy.schema:set_field(meta, key, "energy", math.max(energy, 0))
end

function energy.increase_energy(meta, key, amount, commit)
  local stored = energy.schema:get_field(meta, key, "energy") + amount
  if commit then
    energy.schema:set_field(meta, key, "energy", stored)
  end
  return energy
end

function energy.decrease_energy(meta, key, amount, commit)
  local stored = energy.schema:get_field(meta, key, "energy") - amount
  if commit then
    energy.schema:set_field(meta, key, "energy", stored)
  end
  return energy
end

function energy.receive_energy(meta, key, amount, bandwidth, capacity, commit)
  local stored = energy.get_energy(meta, key)
  local stored, received_amount = energy.calc_received_energy(stored, amount, bandwidth, capacity)
  if commit then
    energy.schema:set_field(meta, key, "energy", stored)
  end
  return received_amount
end

function energy.consume_energy(meta, key, amount, bandwidth, capacity, commit)
  local stored = energy.get_energy(meta, key)
  local stored, consumed_amount = energy.calc_consumed_energy(stored, amount, bandwidth, capacity)
  if commit then
    energy.schema:set_field(meta, key, "energy", stored)
  end
  return consumed_amount
end

function energy.to_infotext(meta, key, capacity)
  assert(meta, "expected a meta")
  assert(key, "expected a key")
  local amount = energy.get_energy(meta, key)
  if capacity then
    return tostring(amount) .. " / " .. capacity .. ""
  else
    return tostring(amount)
  end
end

yatm_core.energy = energy

-- Tests
do
  assert(energy.allowed_energy(100, 10) == 10, "expected allowed_energy to limit given energy by the bandwidth")
  assert(energy.allowed_energy(100, nil) == 100, "expected allowed_energy given a nil bandwidth to return energy")
  assert(energy.allowed_energy(10, 100) == 10, "expected allowed_energy given a bandwidth greater than the energy to return it as is")
end

do
  local new_energy, actual_amount = energy.calc_received_energy(15, 10, 10, 20)
  assert(new_energy == 20, "expected new energy to be 20 but got " .. new_energy)
  assert(actual_amount == 5, "expected actual_amount to be lower than the given")
end

do
  local new_energy, actual_amount = energy.calc_consumed_energy(5, 15, 10, 20)
  assert(new_energy == 0, "expected new energy to be 0 but got " .. new_energy)
  assert(actual_amount == 5, "expected actual_amount to be lower than the given")
end
