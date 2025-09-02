function yatm.info(message)
  core.log("info", message, 2)
end

function yatm.warn(message)
  core.log("warning", message, 2)
end

function yatm.error(message)
  if yatm.config.fail_loud then
    error("ERROR: " .. message)
  else
    core.log("error", message, 2)
  end
end

function yatm.fatal(message)
  error("FATAL: " .. message)
end
