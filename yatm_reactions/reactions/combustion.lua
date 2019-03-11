--[[
Nodes in the `combustable` group will sometimes spotaneously combust when exposed to `air`

A node can define a `on_combust(pos :: vector, node :: NodeDef) :: boolean` callback
to handle the pre-combustion,
if true is returned, then the node is swapped for fire
else, nothing happens.
]]
minetest.register_abm({
  name = "yatm_reactions:combustion",
  label = "Combustion",
  nodenames = {
    "group:combustable",
  },
  neighbours = {"air"},

  interval = 7,
  chance = 12,

  catch_up = false,

  action = function (pos, node)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef.on_combust then
      nodedef.on_combust(pos, node)
    else
      minetest.swap_node(pos, { name = "fire:basic_flame" })
    end
  end
})
