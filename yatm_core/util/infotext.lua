function yatm_core.trigger_refresh_infotext(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.refresh_infotext then
      nodedef.refresh_infotext(pos)
      return true
    end
  else
    print("trigger_refresh_infotext/1", "unknown node", node.name)
  end
  return false
end
