--[[
Nodes in the `radioactive` group will attempt harm nearby entities without radioactive protection.

It may also set off other nodes.
]]
minetest.register_abm({
  name = "yatm_reactions:radioactivity",
  label = "Radioactivity",

  nodenames = {
    "group:radioactive",
  },

  interval = 7,
  chance = 12,

  catch_up = false,

  action = function (pos, node)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef.do_radioactive_decay then
      nodedef.do_radioactive_decay(pos, node)
    end
  end
})
