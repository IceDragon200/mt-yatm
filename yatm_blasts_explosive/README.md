# YATM Blasts Explosive

YATM's defintiion of standard explosive blasts.

These are used for things like C4, TNT, etc.

Explosives are particularly destructive as they will:
* Destroy nodes
* Damage or launch entities

## Types

This mod registers 2 explosive blasts:

* `yatm:explosive` - A simple range loop which destroys all nodes within range, doesn't care about node position or what is in front of who, will just try to destroy everything
* `yatm:raycast_explosive` - does additional calculations to perform an explosion based on raycast information, this also allows nodes to "block" an explosion preventing those behind it from being destroyed, or dampening the explosion
