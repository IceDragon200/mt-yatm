local Directions = assert(foundation.com.Directions)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

yatm_device_hubs.HUB_NODEBOX = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.375, 0.375, (3 / 16.0) - 0.5, 0.375},
  }
}

function yatm_device_hubs.hub_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

function yatm_device_hubs.hub_after_place_node(pos, placer, item_stack, pointed_thing)
  Directions.facedir_wallmount_after_place_node(pos, placer, item_stack, pointed_thing)
  yatm.devices.device_after_place_node(pos, placer, item_stack, pointed_thing)
end
