local c = assert(yatm_core.Cuboid)

local full_shelf_nodebox = {
  type = "fixed",
  fixed = {
    c:new( 0,  0,  0, 16,  1, 16):fast_node_box(), -- bottom shelf
    c:new( 0,  7,  0, 16,  1, 16):fast_node_box(), -- mid shelf
    c:new( 0, 15,  0, 16,  1, 16):fast_node_box(), -- top
    c:new( 0,  0, 15, 16, 16,  1):fast_node_box(), -- back
    c:new( 0,  0,  0,  1, 16, 16):fast_node_box(), -- left
    c:new(15,  0,  0,  1, 16, 16):fast_node_box(), -- right
  }
}

local half_shelf_nodebox = {
  type = "fixed",
  fixed = {
    c:new( 0,  0,  8, 16,  1,  8):fast_node_box(), -- bottom shelf
    c:new( 0,  7,  8, 16,  1,  8):fast_node_box(), -- mid shelf
    c:new( 0, 15,  8, 16,  1,  8):fast_node_box(), -- top
    c:new( 0,  0, 15, 16, 16,  1):fast_node_box(), -- back
    c:new( 0,  0,  8,  1, 16,  8):fast_node_box(), -- left
    c:new(15,  0,  8,  1, 16,  8):fast_node_box(), -- right
  }
}

local full_shelf_nodeboxes = {
  ["1x1x1"] = {
    type = "fixed",
    fixed = {
      c:new( 0,  0,  0, 16,  1, 16):fast_node_box(), -- bottom shelf
      c:new( 0, 15,  0, 16,  1, 16):fast_node_box(), -- top
      c:new( 0,  0, 15, 16, 16,  1):fast_node_box(), -- back
      c:new( 0,  0,  0,  1, 16, 16):fast_node_box(), -- left
      c:new(15,  0,  0,  1, 16, 16):fast_node_box(), -- right
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
      c:new( 0,  0,  8, 16,  1,  8):fast_node_box(), -- bottom shelf
      c:new( 0, 15,  8, 16,  1,  8):fast_node_box(), -- top
      c:new( 0,  0, 15, 16, 16,  1):fast_node_box(), -- back
      c:new( 0,  0,  8,  1, 16,  8):fast_node_box(), -- left
      c:new(15,  0,  8,  1, 16,  8):fast_node_box(), -- right
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
      basename = "yatm_item_shelves:full_shelf",

      description = def.name .. " " .. x .. " Shelf",

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
      basename = "yatm_item_shelves:half_shelf",

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

    minetest.register_lbm({
      name = "yatm_item_shelves:migrate_legacy_shelves_" .. material_basename .. "_" .. x2d .. "_full_shelf",
      nodenames = {
        "yatm_item_shelves:" .. material_basename .. "_" .. x2d .. "_full_shelf",
      },
      run_at_every_load = false,
      action = function (pos, node)
        node.name = full_shelf_name
        minetest.swap_node(pos, node)
      end,
    })

    minetest.register_lbm({
      name = "yatm_item_shelves:migrate_legacy_shelves_" .. material_basename .. "_" .. x2d .. "_half_shelf",
      nodenames = {
        "yatm_item_shelves:" .. material_basename .. "_" .. x2d .. "_half_shelf",
      },
      run_at_every_load = false,
      action = function (pos, node)
        node.name = half_shelf_name
        minetest.swap_node(pos, node)
      end,
    })
  end
end
