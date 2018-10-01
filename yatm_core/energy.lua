--[[
Provides some utility functions for dealing with energy in YATM
]]
local energy = {}

-- Helper function for dealing with energy
function energy.calc_received_energy(current_energy, amount, bandwidth, capacity)
  local received_energy = energy.allowed_energy(amount, bandwidth)
  local current_energy = current_energy + received_energy
  if current_energy > capacity then
    local over = current_energy - capacity
    received_energy = received_energy - over
  end
  return current_energy, received_energy
end

function energy.calc_consumed_energy(current_energy, amount, bandwidth, _capacity)
  local consumed_energy = energy.allowed_energy(amount, bandwidth)
  local current_energy = current_energy - consumed_energy
  if current_energy < 0 then
    local under = current_energy
    current_energy = 0
    consumed_energy = consumed_energy + under
  end
  return current_energy, consumed_energy
end

function energy.allowed_energy(energy, bandwidth)
  return math.min(energy, bandwidth)
end

energy.schema = yatm_core.MetaSchema.new("energy", "", {
  energy = {
    type = "integer",
  },
})

function energy.get_energy(meta, key)
  return energy.schema:get_field(meta, key, "energy")
end

function energy.get_energy_throughput(meta, key, bandwidth)
  return math.min(energy.get_energy(meta, key), bandwidth)
end

function energy.set_energy(meta, key, energy)
  energy.schema:set_field(meta, key, "energy", math.max(energy, 0))
end

function energy.increase_energy(meta, key, amount)
  local energy = energy.schema:get_field(meta, key, "energy") + amount
  energy.schema:set_field(meta, key, "energy", energy)
  return energy
end

function energy.decrease_energy(meta, key, amount)
  local energy = energy.schema:get_field(meta, key, "energy") - amount
  energy.schema:set_field(meta, key, "energy", energy)
  return energy
end

function energy.receive_energy(meta, key, amount, bandwidth, capacity)
  local energy = energy.get_energy(meta, key)
  local energy, received_amount = calc_received_energy(energy, amount, bandwidth, capacity)
  energy.schema:set_field(meta, key, "energy", energy)
  return received_amount
end

function energy.consume_energy(meta, key, amount, bandwidth, capacity)
  local energy = energy.get_energy(meta, key)
  local energy, consumed_amount = calc_consumed_energy(energy, amount, bandwidth, capacity)
  energy.schema:set_field(meta, key, "energy", energy)
  return consumed_amount
end

yatm_core.energy = energy
