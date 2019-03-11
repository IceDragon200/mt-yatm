## YATM Energy API

### Callbacks

__group__ `energy_producer`

```lua
-- Attempt to produce energy, the function should return how much energy is produced
-- This energy can be taken from a buffer or generated on fly
yatm_network.produce_energy(pos, node) -- => energy_produced :: integer
```

__group__ `energy_storage`

```lua
-- This should return how much energy is USABLE right now from the storage (not it's total capacity)
yatm_network.get_usable_stored_energy(pos, node) -- => energy_available :: integer
-- This callback is used to commit energy changes to the storage, the storage should subtract as much of the amount as it can and return the amount it was able to subtract.
yatm_network.use_stored_energy(pos, node, amount) -- => energy_used :: integer
```

__group__ `energy_consumer`

```lua
-- This should use the energy provided in some way, and return how much of that energy was used
-- Note it's called consume, but this is called from the network as an order to the node "consume this energy"
yatm_network.consume_energy(pos, node, amount) -- => energy_consumed :: integer
```

__group__ `energy_receiver`

```lua
-- This should receive the given energy, and return how much was received
yatm_network.receive_energy(pos, node, amount) :: (energy_received :: integer)
```

### Notes

If a device has an internal energy buffer, it should NOT be grouped as an `energy_storage` unless it's used for storage.

By marking something as `energy_storage`, it's telling the network that it's energy can be consumed by the rest of the network.

Note that `energy_storage` and `energy_receiver` are normally paired to create a battery like device.

They can be used indepedently to create different expectations.

A plain `energy_storage` device could be a static generator (i.e. where energy is built-up overtime), while a plain receiver could be an energy sink (e.g. resistance on the network)

`energy_producer` is meant to be used for non-bufferable generators (e.g. solar panels, various engine-based generators), the energy produced is used immediately and will be lost if no storage is available.

It's possible to use the network without any producers, however this puts strain on the storage side of it.

## YATM Fluids Interface
