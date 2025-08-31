function yatm.info(message)
  core.log("info", message)
end

function yatm.warn(message)
  core.log("warning", message)
end

function yatm.error(message)
  if yatm.config.fail_loud then
    error("ERROR: " .. message)
  else
    core.log("error", message)
  end
end

function yatm.fatal(message)
  error("FATAL: " .. message)
end
