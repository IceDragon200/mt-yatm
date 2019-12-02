--
-- Provides some utility functions for dealing with energy in YATM
--
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
  assert(meta, "expected a metaref")
  return energy.schema:get_field(meta, key, "energy")
end

function energy.get_energy_throughput(meta, key, bandwidth)
  assert(meta, "expected a metaref")
  return math.min(energy.get_energy(meta, key), bandwidth)
end

function energy.set_energy(meta, key, energy)
  assert(meta, "expected a metaref")
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

function energy.format_string(amount, capacity)
  if capacity then
    return tostring(math.floor(amount)) .. " / " .. capacity .. ""
  else
    return tostring(math.floor(amount))
  end
end

function energy.to_infotext(meta, key, capacity)
  assert(meta, "expected a meta")
  assert(key, "expected a key")
  local amount = energy.get_energy(meta, key)

  return energy.format_string(amount, capacity)
end

yatm_cluster_energy.energy = energy
