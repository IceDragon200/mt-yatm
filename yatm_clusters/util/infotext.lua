function yatm_clusters.queue_refresh_infotext(pos, node)
  local new_pos = vector.new(pos)
  return yatm.clusters:schedule_node_event('refresh_infotext', 'refresh_infotext', new_pos, node, nil)
end
