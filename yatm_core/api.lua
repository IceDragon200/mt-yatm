--[[

  The public API exposed by the yatm_core

]]
yatm.Luna = assert(yatm_core.Luna)

function yatm.register_stateful_node(basename, base, states)
  for name, changes in pairs(states) do
    local nodedef = yatm_core.table_merge(base, changes)
    minetest.register_node(basename .. "_" .. name, nodedef)
  end
end
