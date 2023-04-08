# YATM Cluster Thermal

YATM's thermal cluster implementation.

## What is it?

Thermal is another energy system for YATM, however unlike `energy` (which is a simulation of electrical energy), thermal is based on a equalizing value.

Producers will generate heat up to a certain point (some temperature for example), and will sustain that value over time as long as it can produce it.

When the node is no longer able to produce that heat, it will gradually drift back to its neutral state (typically zero).

Thermal ducts transfer this heat from the producers to consumers which will themselves heat up in response to produce work.

Consumers may optionally `consume` the heat from it's neighbouring ducts to create a passive cooling effect.

Note that heat means both HOT and COLD in YATM, a node can cooled through the same interface.

## How do I get started?

As with most clusters you will need to register your node to it's respective cluster using the
`schedule_add_node/2` and remove them when they are no longer needed with `schedule_remove_node/2`.

In addition nodes must be apart of the `yatm_cluster_thermal` group.

And finally a `thermal_interface` MUST be defined on the node's definition.

All together that looks like this for a producer:

```lua
minetest.register_node("my_mod:my_thermal_producer", {
  groups = {
    --- YATM has an LBM that will restore the node to its cluster automatically
    --- As long as this group is set
    yatm_cluster_thermal = 1,
  },

  thermal_interface = {
    groups = {
      thermal_producer = 1,
    },

    --- @spec get_heat(self: ThermalInterface, pos: Vector3, node: NodeRef): Float
    get_heat = function (self, pos, node)
      local meta = minetest.get_meta(pos)
      -- you only need to return a number that represents the heat value
      return meta:get_float("heat")
    end
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    yatm.cluster.thermal:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, old_node)
    yatm.cluster.thermal:schedule_remove_node(pos, old_node)
  end,
})
```

And for a consumer:

```lua
minetest.register_node("my_mod:my_thermal_consumer", {
  groups = {
    --- YATM has an LBM that will restore the node to its cluster automatically
    --- As long as this group is set
    yatm_cluster_thermal = 1,
  },

  thermal_interface = {
    groups = {
      -- consumers do not have a specific group, as long as they are not a thermal_producer
      -- note that even producers can have an update_heat/4 called

      -- a special group that will have an update function called very tick for the cluster group
      updatable = 1,
    },

    --- @spec update_heat(self: ThermalInterface, pos: Vector3, node: NodeRef, heat: Float, dtime: Float): void
    update_heat = function (self, pos, node, heat, dtime)
      -- perform any heat transfer logic you wish here
    end,

    --- Only called when a node is a part of the updatable group
    --- This callback can be used to perform any logic you'd like that depends on the thermal
    --- cluster's update cycle.
    ---
    --- @spec update(self, pos, node, dtime)
    update = function (self, pos, node, dtime)
      --- Do whatever you like, for example if you are implementing a heated furnace, this
      --- callback can be used to perform the "work"
    end,
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    yatm.cluster.thermal:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, old_node)
    yatm.cluster.thermal:schedule_remove_node(pos, old_node)
  end,
})
```
