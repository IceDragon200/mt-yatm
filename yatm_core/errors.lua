function yatm.warn(message)
  print("\n\tWARN: " .. message .. "\n")
end

function yatm.error(message)
  if yatm.config.fail_loud then
    error("ERROR: " .. message)
  else
    print("\n\tERROR: " .. message .. "\n")
  end
end

function yatm.fatal(message)
  error("FATAL: " .. message)
end
