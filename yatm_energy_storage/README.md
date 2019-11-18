# YATM Energy Storage

Adds energy storage nodes and items.

## Provided APIs

__Inventory Batteries__

```lua
--
-- The Inventory Battery API provides a simple module for dealing with
-- Inventories with batteries, this will take care of sharding receive/consume
-- across the batteries, it can also calculate the total capacity of the inventory.
--
local invbat = yatm.energy.inventory_batteries

...
local inv = meta:get_inventory() -- any inventory

local list_name = "batteries"
-- Calculate the total capacity
local capacity = invbat.calc_capacity(inv, list_name)

-- Receive some energy, will roll over into other batteries
local amount = 5000
local new_energy_level, used = invbat.receive_energy(inv, list_name, amount)
-- As with most energy apis, this returns the total energy level and the actual amount used

-- Consume some energy, will roll over into other batteries
local amount = 1000
local new_energy_level, consumed = invbat.consume_energy(inv, list_name, amount)
-- As with most energy apis, this returns the total energy level and the actual amount consumed
```

__Item Energy__

```lua
minetest.register_tool("modname:itemname", {
  ...
  energy = {
    get_capacity = function (item_stack)
      -- This should return the maximum energy capacity of the item
      return 5000
    end,

    get_stored_energy = function (item_stack)
      -- This should return the amount of energy stored by the item
      local meta = item_stack:get_meta()
      return meta:get_float("energy")
    end,

    consume_energy = function (item_stack, amount)
      -- You can utilize yatm.energy to help with the consume calculations
      local meta = item_stack:get_meta()
      local new_energy, used = yatm.energy.calc_consumed_energy(meta:get_float("energy"), amount, 5000, 5000)
      meta:set_float("energy", new_energy)
      -- At the end, you should return the amount of energy that was actually consumed
      return used
    end,

    receive_energy = function (item_stack, amount)
      -- You can utilize yatm.energy to help with the receive calculations
      local meta = item_stack:get_meta()
      local new_energy, used = yatm.energy.calc_received_energy(meta:get_float("energy"), amount, 5000, 5000)
      meta:set_float("energy", new_energy)
      -- At the end, you should return the amount of energy that was actually received
      return used
    end,
  }
})
```
