--
-- Proxy function for building stairs, will try to use 'nokore_stairs'
--

-- @namespace yatm
local nokore_stairs = rawget(_G, "nokore_stairs")

-- @spec build_decor_nodes(Table): Table
if nokore_stairs then
  yatm.build_decor_nodes = nokore_stairs.build_nodes
else
  function yatm.build_decor_nodes(_data)
    return {}
  end
end

function yatm.register_decor_nodes(basename, data)
  local parts = yatm.build_decor_nodes(data)

  for suffix, node_def in pairs(parts) do
    minetest.register_node(basename .. "_" .. suffix, node_def)
  end
end
