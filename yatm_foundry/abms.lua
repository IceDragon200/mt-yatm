--[[
These are ABMS they aren't bound to any one thing, or may be apart of a greater system.
]]

-- This is the heat exchange ABM, this will trigger the `transfer_heat` function from the heater_device
-- It's up to the device to determine it's heatable neighbors and perform the exchange.
--
-- @callback transfer_heat(pos :: Vector3.t, node :: NodeDef.t) :: void
minetest.register_abm({
  label = "yatm_foundry:transfer_heat_from_heaters",

  nodenames = {
    "group:heater_device",
  },
  neighbors = {
    "group:heatable_device",
  },

  interval = 1,
  chance = 1,

  action = function (pos, node)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      --
      if nodedef.transfer_heat then
        nodedef.transfer_heat(pos, node)
      else
        print("WARN", node.name, "registered as heater_device but has no transfer_heat/2 function")
      end
    else
      -- shouldn't happen, ever.
      print("WARN", node.name, "registered as heater_device but has no node definition!?")
    end
  end,
})
