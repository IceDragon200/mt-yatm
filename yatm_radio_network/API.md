# YATM Radio Network - API

The Radio Network is accessible via it's default instance at `yatm.radio_network`.

A `WorldVector` can be:
* standard luanti vector,
* a foundation Vector3
* a foundation Vector4 for tetra support, where w-coord is used for the `dimension_id`

## API

### Node Subscribers

* `subscribe_for_messages(pos: WorldVector, addr: String, ttl: Number): void` - to subscribe a node to receive radio events, ttl is in seconds, try to keep the ttl values low to avoid zombie registrations
* `unsubscribe_for_messages(pos: WorldVector, addr: String)` - immediately unsubcribe a node from the network, TTLs checks can continue
* `has_subscribers(): Boolean` - reports if the network has any node subscribers

### Mailbox

* `request_mailbox_id(): Any` - Requests a new mailbox_id from the network, this value should be treated as opaque and never interpeted otherwise.
* `request_mailbox_id(addr: String, ttl: Number): Any` - Same as `request_mailbox_id/0` + `subscribe_mailbox/3`
* `subscribe_mailbox(mailbox_id: Any, addr: String, ttl: Number): void` - Using a mailbox id, setup a mailbox to capture messages
* `unsubscribe_mailbox(mailbox_id: Any, addr: String): void` - Removes existing mailbox for the mailbox_id + addr pair, all messages are dropped for tha mailbox as well.
* `get_next_mailbox_message(mailbox_id: Any, addr: String): (message: Any, meta: Any) | nil` - Pops and returns the next message in the mailbox
* `has_mailboxes(): Boolean` - reports if the network has any mailboxes

### Publish

* `publish_message(addr: String, message: Any, meta: Any): void` - schedules a message to be published on the NEXT tick of the network, despite it's name it's delayed

## Usage

As the network provides roughly two different systems, developers should choose the system that fits their usecase or needs.

If you want messages in almost realtime (i.e. the next tick), and your object in question is a node that has a static position, one can utilize the node subscribers system.

```lua
core.register_node("my_mod:my_radio_node", {
  ...

  radio_network = {
    -- self refers to the radio_network table itself allowing you to access any members of
    -- the network table, this can be useful if multiple nodes are using the same radio network
    -- definition for something like a stateful node.
    on_message = function (self, pos, node, message, meta)
      --- do whatever you like with the message
    end,
  },

  on_construct = function (pos)
    local addr = "some_address_of_sorts_up_to_you"
    yatm.radio_network:subscribe_for_messages(pos, addr, 5)
    core.get_node_timer(pos):start(1)
  end,

  on_timer = function (pos, elapsed)
    -- keep renewing your subscription by any timing methods you like
    -- for this example, the standard node on_timer is be used to renew the
    -- subscription, the ttl is being set to 5 seconds, this gives the node
    -- room to be more lenient with its healthcheck-ins and for the network to survive spikes
    yatm.radio_network:subscribe_for_messages(pos, addr, 5)
    return true
  end,
})

-- at some point, you can publish messages
yatm.radio_network:publish_message("some_address_of_sorts_up_to_you", "Hello, World", nil)
-- if all is well, the radio node should receive the message during the next tick
-- on_message(self, pos, node, "Hello, World", nil)
```

If one wants to fetch messages at their own pace, or utilizing entities, the mailbox system should be used instead.
