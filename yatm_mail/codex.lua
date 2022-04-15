yatm.codex.register_entry("yatm_mail:mailbox", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_mail:mailbox_wood_default",
      },
      heading = "Mailbox",
      lines = {
        "Mailboxes are item storage nodes.",
        "They can be used by other players to drop-off items in a secure manner.",
        "They can be equipped with a lock.",
        "While locked, it's contents cannot be accessed.",
        "Only the correct key will reveal the contents of the mailbox.",
      },
    },
  },
})

yatm.codex.register_entry("yatm_mail:package", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_mail:package",
      },
      heading = "Package",
      lines = {
        "Packages are item storage nodes.",
        "Items can be placed into a package, and then moved around.",
        "Similar to Cardboard Boxes, they can be dropped off in a mailbox.",
        "In addition (not yet implemented), the can be signed to a specific player.",
        "Only the sender or the receiver can then open the package.",
      },
    },
  },
})
