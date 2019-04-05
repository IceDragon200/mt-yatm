# YATM Fluid Pipes

Adds fluid transport pipes using the yatm_fluids system.


## Pipe Types

There are 3 main components:

* Inserters
* Extractors
* Transporters

### Inserters

Inserter pipes will accept fluids extracted by extractors and attempts to 'insert' them into a neighbour `fluid_interface_in` node.

By default they can only handle 1000 units of fluid per-tick

### Extractors

Extractor pipes will extract fluids from neighbouring nodes for consumption by the fluid network.

By default they can only handle 1000 units of fluid per-tick.

### Transporters

Technically, they don't do anything on their own, they have a more general usage however, setting up where fluids should be transported.

## How does it work?

As with other YATM systems, fluid transport uses the Network system, see the yatm_core for details on that.

In this system nodes will register to the FluidTransportNetwork which in turn will scan all neighbouring nodes to determine all members.

This network is cached and only the inserters and extractors do any heavy lifting.

The entire process is ran in a globalstep at the full framerate, this may be lowered in the future along with the other networks to lower the CPU costs.
