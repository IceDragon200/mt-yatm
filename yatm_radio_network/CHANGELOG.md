# 0.3.0

* Added support for message mailboxes, this allows nodes or entity's to instruct the network to "hold" messages until they can be digested by the subscriber.
  * Mailboxes also have TTL, so they don't have to sit around indefinetly.

# 0.2.0

* `on_message` now passes the message's metadata as the last argument
