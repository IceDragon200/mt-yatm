# Blasts System

The blasts system handles explosions and their logic, but before you can begin,
you'll need to register an explosion type.

Explosion types handle the logic for an explosion, provided the parameters and an 'assigns' table for any variable data.

The system is accessible:

```lua
yatm.blasts.system
```

## Register New Explosion Type

```lua
yatm.blasts.system:register_explosion_type(name :: String, params :: Table)

yatm.blasts.system:register_explosion_type("high-explosive", {
  description = "High Explosive",

  init = function (blasts_system, explosion, assigns)
    -- an example of setting some information on the assigns for use elsewhere
    assigns.is_high_explosive = true
  end,

  update = function (blasts_system, explosion, assigns, delta)
    --
    if assigns.is_high_explosive then
      -- perform some action for this explosion
    else
      -- mark the explosion as expired so the system can clean up
      explosion.expired = true
    end
  end,

  on_expired = function (blasts_system, explosion, assigns)
    -- when the explosion is about to be removed from the system
    minetest.log("info", "high explosive expired")
  end,
})
```
