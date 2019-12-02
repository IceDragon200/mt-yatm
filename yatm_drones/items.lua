minetest.register_tool("yatm_drones:scavenger_drone_case", {
  description     = "Scavenger Drone Case\nRight-click to deploy a drone.",
  inventory_image = "yatm_scavenger_drone_case.png",
  stack_max       = 1,

  on_place = function(itemstack, clicker, pointed_thing)
    if pointed_thing.above ~= nil then
      local drone = minetest.add_entity(pointed_thing.above, "yatm_drones:scavenger_drone")
      drone:get_luaentity():set_owner_name(clicker:get_player_name())

      itemstack:take_item()
      return itemstack
    end

    return nil
  end,
})

minetest.register_craftitem("yatm_drones:drone_upgrade_speed", {
  base_description = "Drone Upgrade",
  basename = "yatm_drones:drone_upgrade",

  description = "Drone Upgrade - Speed\nAdds 1 to max speed",
  inventory_image = "yatm_drone_upgrade_speed.png",

  groups = {
    drone_upgrade = 1,
    speed_upgrade = 1,
  },
})

minetest.register_craftitem("yatm_drones:drone_upgrade_jump", {
  base_description = "Drone Upgrade",
  basename = "yatm_drones:drone_upgrade",

  description = "Drone Upgrade - Jump\nAdds 0.5 to Jump",
  inventory_image = "yatm_drone_upgrade_jump.png",

  groups = {
    drone_upgrade = 1,
    jump_upgrade = 1,
  },
})

minetest.register_craftitem("yatm_drones:drone_upgrade_vacuum", {
  base_description = "Drone Upgrade",
  basename = "yatm_drones:drone_upgrade",

  description = "Drone Upgrade - Vacuum",
  inventory_image = "yatm_drone_upgrade_vacuum.png",

  groups = {
    drone_upgrade = 1,
    vacuum_upgrade = 1,
  },
})
