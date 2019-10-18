function yatm_clusters.queue_refresh_infotext(pos, node)
  return yatm.clusters.schedule_node_event('refresh_infotext', 'refresh_infotext', pos, node, nil)
end
