--
-- YATM Machines
--
yatm_machines = rawget(_G, "yatm_machines") or {}
yatm_machines.modpath = minetest.get_modpath(minetest.get_current_modname())

function yatm_machines.default_after_place_node(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    nodedef.on_yatm_device_changed(pos, node, pos, node)
  end
  yatm_cables.default_yatm_notify_neighbours_changed(pos)
end

function yatm_machines.default_on_device_changed(pos, _node, _origin_pos, _origin_node)
  yatm_core.Network.schedule_refresh_network_topography(pos, {kind = "device_added"})
end

function yatm_machines.register_network_device(name, nodedef)
  if not nodedef.on_yatm_device_changed then
    nodedef.on_yatm_device_changed = yatm_machines.default_on_device_changed
  end
  if not nodedef.on_yatm_network_changed then
    nodedef.on_yatm_network_changed = yatm_core.Network.default_handle_network_changed
  end
  if not nodedef.after_place_node then
    nodedef.after_place_node = yatm_machines.default_after_place_node
  end
  if not nodedef.after_destruct then
    nodedef.after_destruct = yatm_cables.default_yatm_notify_neighbours_changed
  end
  minetest.register_node(name, nodedef)
end

dofile(yatm_machines.modpath .. "/nodes.lua")
