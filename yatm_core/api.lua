--[[

  The public API exposed by the yatm_core

]]
yatm.Luna = assert(yatm_core.Luna)

function yatm.register_stateful_node(basename, base, states)
  for name, changes in pairs(states) do
    local nodedef = yatm_core.table_merge(base, changes)
    nodedef.basename = nodedef.basename or basename
    minetest.register_node(basename .. "_" .. name, nodedef)
  end
end

function yatm.register_stateful_tool(basename, base, states)
  for name, changes in pairs(states) do
    local tooldef = yatm_core.table_merge(base, changes)
    tooldef.basename = tooldef.basename or basename
    minetest.register_tool(basename .. "_" .. name, tooldef)
  end
end

function yatm.register_stateful_craftitem(basename, base, states)
  for name, changes in pairs(states) do
    local craftitemdef = yatm_core.table_merge(base, changes)
    craftitemdef.basename = craftitemdef.basename or basename
    minetest.register_craftitem(basename .. "_" .. name, craftitemdef)
  end
end
