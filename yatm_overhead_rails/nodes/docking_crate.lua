--
-- Docking Crates are portable inventory nodes
-- They can be placed flat on the ground, but their inventories will be inaccessible.
-- They can also be placed on a docking station (which turns it into an entity instead)
-- There its contents can be unloaded.
-- Every crate is colour coded based on its contents.
-- A crate cannot contain a mixture of contents.
--   That is; it cannot contain fluids AND energy, or any other combination
--   Similarly, certain types (i.e. fluids and items) may have multiple sub-items based on their
--   inventory configuration.
--
local mod = yatm_overhead_rails
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local table_merge = foundation.com.table_merge

local groups = {
  cracky = 1,
  docking_crate = 1,
}

yatm.register_stateful_node("yatm_overhead_rails:docking_crate", {
  base_description = mod.S("Docking Crate"),

  stack_max = 1,

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(2, 0, 2, 12, 12, 12),
    },
  },

  paramtype = "light",

  crate_spec = {},
}, {
  -- By default the empty crate has no inventories at all, but implements
  -- ALL the docking station interfaces, once it gains some kind of content
  -- it will change to the matching crate type.
  empty = {
    groups = table_merge(groups, {
      docking_crate_empty = 1,
    }),

    description = mod.S("Docking Crate [Empty]"),

    tiles = {
      "yatm_docking_crate_top_blank.png",
      "yatm_docking_crate_top_blank.png",
      "yatm_docking_crate_side_blank.png",
      "yatm_docking_crate_side_blank.png",
      "yatm_docking_crate_side_blank.png",
      "yatm_docking_crate_side_blank.png",
    },

    crate_spec = {
      type = "empty",
    },
  },

  fluid = {
    groups = table_merge(groups, {
      docking_crate_fluids = 1,
      not_in_creative_inventory = 1,
    }),

    description = mod.S("Docking Crate [Fluid]"),

    tiles = {
      "yatm_docking_crate_top_fluid.png",
      "yatm_docking_crate_top_fluid.png",
      "yatm_docking_crate_side_fluid.png",
      "yatm_docking_crate_side_fluid.png",
      "yatm_docking_crate_side_fluid.png",
      "yatm_docking_crate_side_fluid.png",
    },

    crate_spec = {
      type = "fluid",
    },
  },

  ele = {
    groups = table_merge(groups, {
      docking_crate_elemental = 1,
      not_in_creative_inventory = 1,
    }),

    description = mod.S("Docking Crate [Element]"),

    tiles = {
      "yatm_docking_crate_top_ele.png",
      "yatm_docking_crate_top_ele.png",
      "yatm_docking_crate_side_ele.png",
      "yatm_docking_crate_side_ele.png",
      "yatm_docking_crate_side_ele.png",
      "yatm_docking_crate_side_ele.png",
    },

    crate_spec = {
      type = "ele",
    },
  },

  energy = {
    groups = table_merge(groups, {
      docking_crate_energy = 1,
      not_in_creative_inventory = 1,
    }),

    description = mod.S("Docking Crate [Energy]"),

    tiles = {
      "yatm_docking_crate_top_energy.png",
      "yatm_docking_crate_top_energy.png",
      "yatm_docking_crate_side_energy.png",
      "yatm_docking_crate_side_energy.png",
      "yatm_docking_crate_side_energy.png",
      "yatm_docking_crate_side_energy.png",
    },

    crate_spec = {
      type = "energy",
    },
  },

  items = {
    groups = table_merge(groups, {
      docking_crate_items = 1,
      not_in_creative_inventory = 1,
    }),

    description = mod.S("Docking Crate [Item]"),

    tiles = {
      "yatm_docking_crate_top_items.png",
      "yatm_docking_crate_top_items.png",
      "yatm_docking_crate_side_items.png",
      "yatm_docking_crate_side_items.png",
      "yatm_docking_crate_side_items.png",
      "yatm_docking_crate_side_items.png",
    },

    crate_spec = {
      type = "items",
    },
  },

  heat = {
    groups = table_merge(groups, {
      docking_crate_heat = 1,
      not_in_creative_inventory = 1,
    }),

    description = mod.S("Docking Crate [Heat]"),

    tiles = {
      "yatm_docking_crate_top_heat.png",
      "yatm_docking_crate_top_heat.png",
      "yatm_docking_crate_side_heat.png",
      "yatm_docking_crate_side_heat.png",
      "yatm_docking_crate_side_heat.png",
      "yatm_docking_crate_side_heat.png",
    },

    crate_spec = {
      type = "heat",
    },
  },
})
