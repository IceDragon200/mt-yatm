--
-- Provides some utility functions for dealing with energy in YATM
--

-- @namespace yatm_cluster_energy.energy
local energy = {}

energy.schema = foundation.com.MetaSchema:new("energy", "", {
  energy = {
    type = "integer",
  },
})

-- Helper function for dealing with energy

-- How much energy can be used, given the current 'energy'
-- and an optional bandwidth (maximum allowed energy)
--
-- @spec allowed_energy(energy: Integer, bandwidth?: Integer): Integer
function energy.allowed_energy(energy, bandwidth)
  assert(energy, "expected energy to be present")
  if bandwidth then
    return math.min(energy, bandwidth)
  else
    return energy
  end
end

-- @spec calc_received_energy(
--   stored_energy: Integer,
--   amount: Integer,
--   bandwidth?: Integer,
--   capacity: Integer
-- ): (new_stored_energy: Integer, energy_used: Integer)
function energy.calc_received_energy(stored_energy, amount, bandwidth, capacity)
  local new_amount = energy.allowed_energy(amount, bandwidth)
  local new_stored_energy = math.min(stored_energy + new_amount, capacity)
  return new_stored_energy, new_stored_energy - stored_energy
end

-- @spec calc_consumed_energy(
--   stored_energy: Integer,
--   amount: Integer,
--   bandwidth?: Integer,
--   capacity?: Integer
-- ): (new_stored_energy: Integer, energy_used: Integer)
function energy.calc_consumed_energy(stored_energy, amount, bandwidth, _capacity)
  local new_amount = energy.allowed_energy(amount, bandwidth)
  local new_stored_energy = math.max(stored_energy - new_amount, 0)
  return new_stored_energy, stored_energy - new_stored_energy
end

-- @spec get_meta_energy(MetaRef, key: String): Integer
function energy.get_meta_energy(meta, key)
  assert(meta, "expected a metaref")
  return energy.schema:get_field(meta, key, "energy")
end

local get_meta_energy = energy.get_meta_energy

-- @spec get_meta_energy_throughput(MetaRef, key: String, bandwidth: Integer): Integer
function energy.get_meta_energy_throughput(meta, key, bandwidth)
  assert(meta, "expected a metaref")
  return math.min(get_meta_energy(meta, key), bandwidth)
end

-- @spec set_meta_energy(MetaRef, key: String, amount: Integer): void
function energy.set_meta_energy(meta, key, amount)
  assert(meta, "expected a metaref")
  energy.schema:set_field(meta, key, "energy", math.max(amount, 0))
end

-- @spec increase_meta_energy(
--   MetaRef,
--   key: String,
--   amount: Integer,
--   commit: Boolean
-- ): Integer
function energy.increase_meta_energy(meta, key, amount, commit)
  local stored = energy.schema:get_field(meta, key, "energy") + amount
  if commit then
    energy.schema:set_field(meta, key, "energy", stored)
  end
  return energy
end

-- @spec decrease_meta_energy(
--   MetaRef,
--   key: String,
--   amount: Integer,
--   commit: Boolean
-- ): Integer
function energy.decrease_meta_energy(meta, key, amount, commit)
  local stored = energy.schema:get_field(meta, key, "energy") - amount
  if commit then
    energy.schema:set_field(meta, key, "energy", stored)
  end
  return energy
end

-- @spec receive_meta_energy(
--   MetaRef,
--   key: String,
--   amount: Integer,
--   bandwidth?: Integer,
--   capacity?: Integer,
--   commmit?: Boolean
-- ): Integer
function energy.receive_meta_energy(meta, key, amount, bandwidth, capacity, commit)
  local stored = get_meta_energy(meta, key)
  local stored, received_amount = energy.calc_received_energy(stored, amount, bandwidth, capacity)
  if commit then
    energy.schema:set_field(meta, key, "energy", stored)
  end
  return received_amount
end

-- @spec consume_meta_energy(
--   MetaRef,
--   key: String,
--   amount: Integer,
--   bandwidth?: Integer,
--   capacity?: Integer,
--   commit?: Boolean
-- ): Integer
function energy.consume_meta_energy(meta, key, amount, bandwidth, capacity, commit)
  local stored = get_meta_energy(meta, key)
  local stored, consumed_amount = energy.calc_consumed_energy(stored, amount, bandwidth, capacity)
  if commit then
    energy.schema:set_field(meta, key, "energy", stored)
  end
  return consumed_amount
end

-- @spec format_string(amount: Integer, capacity: Integer): String
function energy.format_string(amount, capacity)
  if capacity then
    return tostring(math.floor(amount)) .. " / " .. capacity .. ""
  else
    return tostring(math.floor(amount))
  end
end

local format_string = energy.format_string

-- @spec meta_to_infotext(meta: MetaRef, key: String, capacity: Integer): String
function energy.meta_to_infotext(meta, key, capacity)
  assert(meta, "expected a meta")
  assert(key, "expected a key")
  local amount = get_meta_energy(meta, key)

  return format_string(amount, capacity)
end

yatm_cluster_energy.energy = energy
