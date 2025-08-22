# YATM Radio Network

YATM Radio Network provides a short-lived network service for nodes that want to listen for small events generally without needing to actually register in a large network.

## Node Definition

```lua
core.register_node("name", {
  ...

  radio_network = {
    on_message = function (self, pos, node, message)
      --- do whatever you like with the message
    end,
  }
})
```
