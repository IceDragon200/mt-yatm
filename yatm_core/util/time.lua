-- Time in 'Network' frames, all networks run at the same speed so this function will return the equivalent network frame count

function yatm_core.time_network_frames(time)
  return math.floor(time)
end

function yatm_core.time_network_seconds(s)
  return yatm_core.time_network_frames(s * 60)
end

function yatm_core.time_network_minutes(m)
  return yatm_core.time_network_seconds(m * 60)
end

function yatm_core.time_network_hours(h)
  return yatm_core.time_network_minutes(h * 60)
end

function yatm_core.time_network_hms(h, m, s)
  return yatm_core.time_network_hours(h) +
    yatm_core.time_network_minutes(m) +
    yatm_core.time_network_seconds(s)
end
