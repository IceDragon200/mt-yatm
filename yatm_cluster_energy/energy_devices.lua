--[[
The unforgiving energy interface, if you didn't define the functions properly, this WILL BLOW UP IN YOUR FACE.
]]
local EnergyDevices = {}

local function get_energy_interface_function(pos, node, function_name)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    local ym = nodedef.yatm_network
    if ym then
      local en = nodedef.yatm_network.energy
      if en then
        local func = en[function_name]
        if func then
          return func
        else
          error("expected yatm_network.energy." .. function_name .. " to be defined for node `" .. node.name .. "`")
        end
      else
        error("expected a yatm_network.energy interface for node `" .. node.name .. "`")
      end
    else
      error("expected a yatm_network configuration for node `" .. node.name .. "`")
    end
  else
    error("expected a registered node for " .. node.name)
  end
end

function EnergyDevices.produce_energy(pos, node, dtime, ot)
  return get_energy_interface_function(pos, node, "produce_energy")(pos, node, dtime, ot)
end

function EnergyDevices.get_usable_stored_energy(pos, node, dtime, ot)
  return get_energy_interface_function(pos, node, "get_usable_stored_energy")(pos, node, dtime, ot)
end

function EnergyDevices.consume_energy(pos, node, energy_available, dtime, ot)
  return get_energy_interface_function(pos, node, "consume_energy")(pos, node, energy_available, dtime, ot)
end

function EnergyDevices.use_stored_energy(pos, node, amount_to_consume, dtime, ot)
  return get_energy_interface_function(pos, node, "use_stored_energy")(pos, node, amount_to_consume, dtime, ot)
end

function EnergyDevices.receive_energy(pos, node, energy_left, dtime, ot)
  return get_energy_interface_function(pos, node, "receive_energy")(pos, node, energy_left, dtime, ot)
end

yatm_cluster_energy.EnergyDevices = EnergyDevices
