--
-- Just some decorative plastic panels.
--
minetest.register_node("yatm_plastics:plastic_panel_plain_block", {
  description = "Plain Plastic Panel Block",

  tiles = {
    "yatm_plastic_panel_plain.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

yatm_core.register_stateful_node("yatm_plastics:plastic_panel_plain_block", {
  basename = "yatm_plastics:plastic_panel_plain_block",
  base_description = "Plain Plastic Panel Block",

  groups = {
    cracky = 1,
  },

  drawtype = "glasslike",

  paramtype = "light",
  paramtype2 = "facedir",
}, {
  cooling = {
    description = "Plain Plastic Panel Block (Cooling Lights)",

    tiles = {"yatm_plastic_panel_plain.cooling.png"}
  },
  heating = {
    description = "Plain Plastic Panel Block (Heating Lights)",

    tiles = {"yatm_plastic_panel_plain.heating.png"}
  },
  radiating = {
    description = "Plain Plastic Panel Block (Radiating Lights)",

    tiles = {"yatm_plastic_panel_plain.radiating.png"}
  },
})

minetest.register_node("yatm_plastics:plastic_panel_notched_block", {
  description = "Notched Plastic Panel Block",

  tiles = {
    "yatm_plastic_panel_notched.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

yatm_core.register_stateful_node("yatm_plastics:plastic_panel_notched_block", {
  basename = "yatm_plastics:plastic_panel_notched_block",
  base_description = "Notched Plastic Panel Block",

  groups = {
    cracky = 1,
  },

  drawtype = "glasslike",

  paramtype = "light",
  paramtype2 = "facedir",
}, {
  cooling = {
    description = "Notched Plastic Panel Block (Cooling Lights)",

    tiles = {"yatm_plastic_panel_notched.cooling.png"}
  },
  heating = {
    description = "Notched Plastic Panel Block (Heating Lights)",

    tiles = {"yatm_plastic_panel_notched.heating.png"}
  },
  radiating = {
    description = "Notched Plastic Panel Block (Radiating Lights)",

    tiles = {"yatm_plastic_panel_notched.radiating.png"}
  },
})

minetest.register_node("yatm_plastics:plastic_panel_hollow_block", {
  basename = "yatm_plastics:plastic_panel_hollow_block",

  description = "Hollow Plastic Panel Block",

  groups = {
    cracky = 1,
  },

  tiles = {
    "yatm_plastic_panel_hollow.off.png",
  },

  drawtype = "glasslike",

  paramtype = "light",
  paramtype2 = "facedir",
})

yatm_core.register_stateful_node("yatm_plastics:plastic_panel_hollow_block", {
  basename = "yatm_plastics:plastic_panel_hollow_block",
  base_description = "Hollow Plastic Panel Block",

  groups = {
    cracky = 1,
  },

  drawtype = "glasslike",

  paramtype = "light",
  paramtype2 = "facedir",
}, {
  cooling = {
    description = "Hollow Plastic Panel Block (Cooling Lights)",

    tiles = {"yatm_plastic_panel_hollow.cooling.png"}
  },
  heating = {
    description = "Hollow Plastic Panel Block (Heating Lights)",

    tiles = {"yatm_plastic_panel_hollow.heating.png"}
  },
  radiating = {
    description = "Hollow Plastic Panel Block (Radiating Lights)",

    tiles = {"yatm_plastic_panel_hollow.radiating.png"}
  },
})
