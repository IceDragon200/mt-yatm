local HeatableDevice = {}

--
-- @spec HeatableDevice.transfer_heat(Vector3.t, DirCode.t, float, boolean)
function HeatableDevice.transfer_heat(pos, dir, heat_amount, commit)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.heat_interface then
      if nodedef.heat_interface.receive_heat then
        return nodedef.heat_interface:receive_heat(pos, dir, heat_amount, commit)
      else
        return 0, "no receive_heat/5"
      end
    else
      return 0, "no heat interface"
    end
  else
    return 0, "no node definition"
  end
end

yatm_foundry.HeatableDevice = HeatableDevice
