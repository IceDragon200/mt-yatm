function yatm_core.maybe_start_node_timer(pos, duration)
  local timer = minetest.get_node_timer(pos)

  if not timer:is_started() then
    timer:start(duration)
  end
end
