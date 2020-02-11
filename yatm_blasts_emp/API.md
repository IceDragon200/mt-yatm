# EMP Blast

EMP blasts raycast to various `emp_target` nodes, they can be stopped by `em_insulator` nodes between them, protecting them from the effects.

```lua
--
-- This is a quick snippet of an emp target node
--
minetest.register_node("mymod:my_emp_target", {
  ...
  groups = {
    ...
    emp_target = 1,
  },
  ...
  --
  -- blast_info is a table that contains some information on the emp origin
  --   blast_info.pos - the originating position of the blast
  --   blast_info.strength - how strong was the blast
  on_emp_blast = function (pos, node, blast_info)
    -- do something
  end,
})

--
-- This is a quick snippet of an em insulator node
--
minetest.register_node("mymod:my_emp_target", {
  ...
  groups = {
    ...
    em_insulator = 1,
  },
})
```

In the future the API may be expanded to allow lowering the strength of the blast by insulators instead of out right cancelling.
Or even deflecting the blast, or chain reactions.
