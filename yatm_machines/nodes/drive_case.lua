minetest.register_node("yatm_machines:drive_case_off", {
  description = "Drive Case [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_drive_case_top.png",
    "yatm_drive_case_bottom.png",
    "yatm_drive_case_side.off.png",
    "yatm_drive_case_side.off.png",
    "yatm_drive_case_back.off.png",
    "yatm_drive_case_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_machines:drive_case_on", {
  description = "Drive Case [on]",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_drive_case_top.png",
    "yatm_drive_case_bottom.png",
    "yatm_drive_case_side.on.png",
    "yatm_drive_case_side.on.png",
    "yatm_drive_case_back.on.png",
    "yatm_drive_case_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
})
