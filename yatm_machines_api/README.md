# YATM Machines API

Extracted the device API and behaviours.

## Upgrade Classes

* AMPLIFY - amplify work typically with heat related machines (that includes cooling machines), it increases the effectiveness of those machines (hence AMPLIFY)
* COIL - coil upgrades add additional functionality to an existing machine, sometimes changing its behaviour or what happens to items processed in it
* Auto-Eject - by default, machines MUST have their inventories extracted either manually by a player or with the appropriate extractor node, auto-eject allows nodes to push their own items to an adjacent node.
* Efficiency - Efficiency affects the work to energy ratio of a machine, in short, it allows the machine to work using less energy than normal
* Energy - Energy affects the maximum energy capacity of the machine

## API

```lua
-- Machines are expected to tie into the upgrade's system by using a handful of functions:
```
