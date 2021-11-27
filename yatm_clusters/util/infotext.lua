-- @namespace yatm_clusters

-- @spec queue_refresh_infotext(Vector3, Node, Table): void
function yatm_clusters.queue_refresh_infotext(pos, node, params)
  assert(pos, "require position")
  local new_pos = vector.new(pos)
  return yatm.clusters:schedule_node_event('refresh_infotext', 'refresh_infotext', new_pos, node, params)
end
