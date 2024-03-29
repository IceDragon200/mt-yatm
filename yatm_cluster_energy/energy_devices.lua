---
--- The unforgiving energy interface, if you didn't define the functions properly,
--- this WILL BLOW UP IN YOUR FACE.
---
--- The energy system operates on four main groups of nodes:
--- * `energy_producer`
---   Energy production is the first step in all ticks, `energy_producer` nodes
---   are expected to implement `produce_energy/4` callback, and should return the amount
---   of energy produced for that tick, if the energy was buffered then it should consume
---   its buffers here, it will not get another chance during this tick.
---
--- * `energy_storage`
---   Energy storage makes up a bulk of the operations in the system, it provides
---   any stored energy that can be consumed by the `energy_consumer`s via
---   `get_usable_stored_energy/4` then uses that energy via the `use_stored_energy/5` function.
---
---   Normally energy_storage nodes will also implement in the energy_receiver part of the interface.
---
--- * `energy_consumer`
---   Energy consumers take any energy from production and stored to perform some work using it.
---   Generally nodes will buffer this energy they consume and perform work later via the `update`
---   callback (for nodes in the `has_update` group).
---
--- * `energy_receiver`
---   Energy receivers are the lowest priority node, like consumers they take energy from the
---   produced, generally they should attempt to store this energy in some capacity as it will
---   only receive energy that was produced, and not energy that was stored.
---
--- See the energy_system.lua for implementation details.

--- @namespace yatm_cluster_energy.EnergyDevices
local EnergyDevices = {}

local function get_energy_interface_function_safe(pos, node, function_name)
  local nodedef = minetest.registered_nodes[node.name]
  if not nodedef then
    return nil, "expected a registered node"
  end

  local ym = nodedef.yatm_network
  if not ym then
    return nil, "expected a yatm_network configuration for node"
  end

  local en = ym.energy
  if not en then
    return nil, "expected a yatm_network.energy interface for node"
  end

  local func = en[function_name]
  if not func then
    return nil, "expected yatm_network.energy." .. function_name .. " to be defined for node"
  end

  return func
end

local function get_energy_interface_function(pos, node, function_name)
  local func, err = get_energy_interface_function_safe(pos, node, function_name)

  if not func then
    error(
      "get_energy_interface_function error:\n\t" ..
      err ..
      "\n\tpos: " .. minetest.pos_to_string(pos) ..
      "\n\tnode: " .. node.name
    )
  end

  return func
end

--- Requests the target node/device return the amount of energy it will generate for this tick.
--- The node should consume it's internal buffers (if any) when this function is called.
--- But if needed, it can perform it's actual generation here and return the result.
--- This function is guarnteed to be called only once during a tick per-energy_producer-node.
---
--- This is only valid for `energy_producer` device nodes.
---
--- @spec produce_energy(pos: Vector3, node: Node, dtime: Float, trace: Trace): Integer | nil
function EnergyDevices.produce_energy(pos, node, dtime, trace)
  return get_energy_interface_function(
    pos,
    node,
    "produce_energy"
  )(pos, node, dtime, trace)
end

--- Requests the target node to report it's current 'usable' energy, usable need not be the full
--- capacity of the device, but rather how much it's willing to use for this tick.
---
--- This is only valid for `energy_storage` device nodes.
---
--- @spec get_usable_stored_energy(
---   pos: Vector3,
---   node: Node,
---   dtime: Float,
---   trace: Trace
--- ): Integer | nil
function EnergyDevices.get_usable_stored_energy(pos, node, dtime, trace)
  return get_energy_interface_function(
    pos,
    node,
    "get_usable_stored_energy"
  )(pos, node, dtime, trace)
end

--- Requests that the target node use the provided energy `energy_available` and return how much it
--- consumed, note the system does not check if the node used more energy than provided it is up
--- to the implementor to not mess it up.
---
--- Normally this energy will be siphoned off into an internal buffer so the node can operate
--- outside of the energy loop.
---
--- This is only valid for `energy_consumer` device nodes.
---
--- @spec consume_energy(
---   pos: Vector3,
---   node: Node,
---   energy_available: Integer,
---   dtime: Float,
---   trace: Trace
--- ): Integer | nil
function EnergyDevices.consume_energy(pos, node, energy_available, dtime, trace)
  return get_energy_interface_function(
    pos,
    node,
    "consume_energy"
  )(pos, node, energy_available, dtime, trace)
end

--- Requests that the target node consume its "stored" energy, this is only used for nodes that
--- reported a device group of `energy_storage`, the system does not track who contributed what to
--- the previous pool created with get_usable_stored_energy/4, so devices that didn't contribute can
--- be expected to be drained as well if possible.
---
--- It is up to the implementor to handle consuming the correct amount from whatever internal buffers
--- are being used.
---
--- This must return the amount of energy that was actually used from the node.
---
--- This is only valid for `energy_storage` device nodes.
---
--- @spec use_stored_energy(
---   pos: Vector3,
---   node: Node,
---   amount_to_consume: Integer,
---   dtime: Float,
---   trace: Trace
--- ): Integer | nil
function EnergyDevices.use_stored_energy(pos, node, amount_to_consume, dtime, trace)
  return get_energy_interface_function(
    pos,
    node,
    "use_stored_energy"
  )(pos, node, amount_to_consume, dtime, trace)
end

--- Requests the target node to 'receive' the remaining energy after the system has resolved
--- everything else.
--- This step is used to recharge `energy_storage` devices, and is the last (energy) function
--- in the system to be called.
---
--- The receiving node must return how much energy it actually consumed from the `energy_left`
---
--- This is only valid for `energy_storage` device nodes.
---
--- @spec receive_energy(
---   pos: Vector3,
---   node: Node,
---   energy_left: Integer,
---   dtime: Float,
---   trace: Trace
--- ): Integer | nil
function EnergyDevices.receive_energy(pos, node, energy_left, dtime, trace)
  return get_energy_interface_function(
    pos,
    node,
    "receive_energy"
  )(pos, node, energy_left, dtime, trace)
end

yatm_cluster_energy.EnergyDevices = EnergyDevices
