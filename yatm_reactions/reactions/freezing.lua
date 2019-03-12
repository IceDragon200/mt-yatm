--[[
Nodes in the `radioactive` group will attempt harm nearby entities without radioactive protection.

It may also set off other nodes.
]]
local dirts = {
  "default:dirt",
  "default:dirt_with_grass",
  "default:dirt_with_grass_footsteps",
  "default:dirt_with_dry_grass",
  "default:dirt_with_rainforest_litter",
  "default:dirt_with_coniferous_litter",
}

local freezables = "group:freezable"

minetest.register_abm({
  name = "yatm_reactions:freezing",
  label = "Freezing Solids",

  nodenames = {
    "group:freezing",
  },

  --neighbours = dirts,

  interval = 1,
  chance = 1,

  catch_up = false,

  action = function (pos, node)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef.do_freezing then
      nodedef.do_freezing(pos, node)
    else
      local strength = nodedef.groups.freezing
      local p = minetest.find_node_near(pos, strength, dirts)
      if p then
        minetest.set_node(p, {name = "default:permafrost"})
      end

      local p = minetest.find_node_near(pos, strength, "group:water")
      if p then
        minetest.set_node(p, {name = "default:ice"})
      end

      p = minetest.find_node_near(pos, strength, freezables)
      if p then
        local new_node = minetest.get_node(p)
        local new_nodedef = minetest.registered_nodes[new_node.name]
        if new_nodedef then
          if new_nodedef.on_freeze then
            new_nodedef.on_freeze(p, new_node)
          elseif new_nodedef.freezes_to then
            local freezes_to = new_nodedef.freezes_to
            minetest.set_node(p, { name = freezes_to })
          end
        end
      end
    end
  end
})
