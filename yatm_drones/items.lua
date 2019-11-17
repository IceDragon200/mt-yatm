minetest.register_tool("yatm_drones:scavenger_drone_case", {
  description     = "Scavenger Drone Case\nRight-click to deploy a drone.",
  inventory_image = "yatm_scavenger_drone_case.png",
  stack_max       = 1,

  on_place = function(itemstack, clicker, pointed_thing)
    if pointed_thing.above ~= nil then
      local drone = minetest.add_entity(pointed_thing.above, "yatm_drones:scavenger_drone")
      drone:get_luaentity():set_owner_name(clicker:get_player_name())
      drone:get_luaentity():receive_energy(500)

      itemstack:take_item()
      return itemstack
    end

    return nil
  end,
})
