--- @namespace yatm

--- @spec info(message: String): void
function yatm.info(message)
  core.log("info", message, 2)
end

--- @spec warn(message: String): void
function yatm.warn(message)
  core.log("warning", message, 2)
end

--- @spec error(message: String): void
function yatm.error(message)
  if yatm.config.fail_loud then
    error("ERROR: " .. message)
  else
    core.log("error", message, 2)
  end
end

--- @spec fatal(message: String): void
function yatm.fatal(message)
  error("FATAL: " .. message)
end
