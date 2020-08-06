local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local full_shelf_nodebox = {
  type = "fixed",
  fixed = {
    ng( 0,  0,  0, 16,  1, 16), -- bottom shelf
    ng( 0,  7,  0, 16,  1, 16), -- mid shelf
    ng( 0, 15,  0, 16,  1, 16), -- top
    ng( 0,  0, 15, 16, 16,  1), -- back
    ng( 0,  0,  0,  1, 16, 16), -- left
    ng(15,  0,  0,  1, 16, 16), -- right
  }
}

local half_shelf_nodebox = {
  type = "fixed",
  fixed = {
    ng( 0,  0,  8, 16,  1,  8), -- bottom shelf
    ng( 0,  7,  8, 16,  1,  8), -- mid shelf
    ng( 0, 15,  8, 16,  1,  8), -- top
    ng( 0,  0, 15, 16, 16,  1), -- back
    ng( 0,  0,  8,  1, 16,  8), -- left
    ng(15,  0,  8,  1, 16,  8), -- right
  }
}

local full_shelf_nodeboxes = {
  ["1x1x1"] = {
    type = "fixed",
    fixed = {
      ng( 0,  0,  0, 16,  1, 16), -- bottom shelf
      ng( 0, 15,  0, 16,  1, 16), -- top
      ng( 0,  0, 15, 16, 16,  1), -- back
      ng( 0,  0,  0,  1, 16, 16), -- left
      ng(15,  0,  0,  1, 16, 16), -- right
    },
  },
  ["2x2x1"] = full_shelf_nodebox,
  ["3x2x1"] = full_shelf_nodebox,
  ["4x2x1"] = full_shelf_nodebox,
}

local half_shelf_nodeboxes = {
  ["1x1x1"] = {
    type = "fixed",
    fixed = {
      ng( 0,  0,  8, 16,  1,  8), -- bottom shelf
      ng( 0, 15,  8, 16,  1,  8), -- top
      ng( 0,  0, 15, 16, 16,  1), -- back
      ng( 0,  0,  8,  1, 16,  8), -- left
      ng(15,  0,  8,  1, 16,  8), -- right
    },
  },
  ["2x2x1"] = half_shelf_nodebox,
  ["3x2x1"] = half_shelf_nodebox,
  ["4x2x1"] = half_shelf_nodebox,
}

local shelf_materials = {
  wood = {
    name = "Wood",
    texture_basename = "wood",
    configurations = {
      {
        cols = 1,
        rows = 1,
        layers = 1,
      },
      {
        cols = 2,
        rows = 2,
        layers = 1,
      },
      {
        cols = 3,
        rows = 2,
        layers = 1,
      },
      {
        cols = 4,
        rows = 2,
        layers = 1,
      },
    }
  },
  carbon_steel = {
    name = "Carbon Steel",
    texture_basename = "metal",
    configurations = {
      {
        cols = 1,
        rows = 1,
        layers = 1,
      },
      {
        cols = 2,
        rows = 2,
        layers = 1,
      },
      {
        cols = 3,
        rows = 2,
        layers = 1,
      },
      {
        cols = 4,
        rows = 2,
        layers = 1,
      },
    }
  },
}

for material_basename, def in pairs(shelf_materials) do
  for _, configuration in ipairs(def.configurations) do
    local x2d = configuration.cols .. "x" .. configuration.rows
    local x = configuration.cols .. "x" .. configuration.rows .. "x" .. configuration.layers

    local full_shelf_name = "yatm_item_shelves:" .. material_basename .. "_" .. x .. "_full_shelf"
    local half_shelf_name = "yatm_item_shelves:" .. material_basename .. "_" .. x .. "_half_shelf"

    yatm.shelves.register_shelf(full_shelf_name, {
      basename = "yatm_item_shelves:" .. material_basename .. "_full_shelf",

      base_description = def.name .. " Full Shelf",

      material_basename = material_basename,

      description = def.name .. " " .. x .. " Shelf",

      codex_entry_id = "yatm_item_shelves:shelf",

      tiles = {
        "yatm_shelf_" .. def.texture_basename .. "_top.png",
        "yatm_shelf_" .. def.texture_basename .. "_bottom.png",
        "yatm_shelf_" .. def.texture_basename .. "_side.png",
        "yatm_shelf_" .. def.texture_basename .. "_side.png",
        "yatm_shelf_" .. def.texture_basename .. "_back.png",
        "yatm_shelf_" .. def.texture_basename .. "_front_" .. x2d .. ".png"
      },

      shelf_configuration = configuration,

      drawtype = "nodebox",
      node_box = full_shelf_nodeboxes[x],
    })

    yatm.shelves.register_shelf(half_shelf_name, {
      basename = "yatm_item_shelves:" .. material_basename .. "_half_shelf",

      base_description = def.name .. " Half Shelf",

      material_basename = material_basename,

      description = def.name .. " " .. x .. " Half Shelf",

      tiles = {
        "yatm_shelf_" .. def.texture_basename .. "_top_half.png",
        "yatm_shelf_" .. def.texture_basename .. "_bottom_half.png",
        "yatm_shelf_" .. def.texture_basename .. "_side_half.png",
        "yatm_shelf_" .. def.texture_basename .. "_side_half.png",
        "yatm_shelf_" .. def.texture_basename .. "_back.png",
        "yatm_shelf_" .. def.texture_basename .. "_front_" .. x2d .. ".png"
      },

      shelf_configuration = configuration,

      drawtype = "nodebox",
      node_box = half_shelf_nodeboxes[x],
    })
  end
end
