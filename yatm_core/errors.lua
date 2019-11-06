function yatm.warn(message)
  minetest.log("warning", message)
end

function yatm.error(message)
  if yatm.config.fail_loud then
    error("ERROR: " .. message)
  else
    minetest.log("error", message)
  end
end

function yatm.fatal(message)
  error("FATAL: " .. message)
end
