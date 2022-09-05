--
-- Just some decorative plastic panels.
--
minetest.register_node("yatm_plastics:plastic_panel_plain_block", {
  basename = "yatm_plastics:plastic_panel_plain_block",
  description = "Plain Plastic Panel Block",

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  tiles = {
    "yatm_plastic_panel_plain.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",
})

yatm.register_stateful_node("yatm_plastics:plastic_panel_plain_block", {
  basename = "yatm_plastics:plastic_panel_plain_block",
  base_description = "Plain Plastic Panel Block",

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  paramtype = "none",
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
  basename = "yatm_plastics:plastic_panel_notched_block",
  description = "Notched Plastic Panel Block",

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  tiles = {
    "yatm_plastic_panel_notched.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",
})

yatm.register_stateful_node("yatm_plastics:plastic_panel_notched_block", {
  basename = "yatm_plastics:plastic_panel_notched_block",
  base_description = "Notched Plastic Panel Block",

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  paramtype = "none",
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
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  tiles = {
    "yatm_plastic_panel_hollow.off.png",
  },

  drawtype = "glasslike",

  paramtype = "none",
  paramtype2 = "facedir",
})

yatm.register_stateful_node("yatm_plastics:plastic_panel_hollow_block", {
  basename = "yatm_plastics:plastic_panel_hollow_block",
  base_description = "Hollow Plastic Panel Block",

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  drawtype = "glasslike",

  paramtype = "none",
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


yatm.register_stateful_node("yatm_plastics:plastic_panel_checker_block", {
  basename = "yatm_plastics:plastic_panel_checker_block",
  base_description = "Checker Plastic Panel Block",

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  drawtype = "glasslike_framed",

  paramtype = "none",
  paramtype2 = "facedir",
}, {
  off = {
    description = "Checker Plastic Panel Block",

    tiles = {
      "yatm_plastic_panel_border.off.png",
      "yatm_plastic_panel_checker.png",
    },
  },

  cooling = {
    description = "Checker Plastic Panel Block (Cooling Lights)",

    tiles = {
      "yatm_plastic_panel_border.cooling.png",
      "yatm_plastic_panel_checker.png",
    },
  },

  heating = {
    description = "Checker Plastic Panel Block (Heating Lights)",

    tiles = {
      "yatm_plastic_panel_border.heating.png",
      "yatm_plastic_panel_checker.png",
    },
  },

  radiating = {
    description = "Checker Plastic Panel Block (Radiating Lights)",

    tiles = {
      "yatm_plastic_panel_border.radiating.png",
      "yatm_plastic_panel_checker.png",
    },
  },
})
