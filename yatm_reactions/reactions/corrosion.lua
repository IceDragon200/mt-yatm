--[[
Nodes in the `corrosive` group will attempt to eat through material near it
]]
minetest.register_abm({
  name = "yatm_reactions:corrosion",
  label = "Corrosion",

  nodenames = {
    "group:corrosive",
  },

  interval = 7,
  chance = 12,

  catch_up = false,

  action = function (pos, node)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef.do_corrode then
      nodedef.do_corrode(pos, node)
    else
      -- TODO: default corrosive behaviour
    end
  end
})
