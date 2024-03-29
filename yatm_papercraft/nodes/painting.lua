local mod = assert(yatm_papercraft)
local table_merge = assert(foundation.com.table_merge)
local Directions = assert(foundation.com.Directions)

local Paintings = {
  members = {}
}

function Paintings:reduce_while(acc, cb)
  for name,def in pairs(self.members) do
    local cont, new_acc = cb(name, def, acc)
    acc = new_acc
    if not cont then
      break
    end
  end
  return acc
end

local painting_after_place_node = Directions.facedir_wallmount_after_place_node

local function register_painting(name, cols, rows, def)
  local nodedef = table_merge({
    basename = name,

    groups = table_merge(def.groups or {}, {
      snappy = nokore.dig_class("wme"),
      oddly_breakable_by_hand = nokore.dig_class("hand"),
      --
      painting = 1,
      -- It's apart of the painting canvas group, allowing the changing of the painting
      painting_canvas = 1,
      -- This represents the resolution of the painting
      ["painting_dim_" .. cols .. "x" .. rows] = 1,
      flammable = 3,
      not_in_creative_inventory = 1,
    }),

    painting_name = name,

    drop = "yatm_papercraft:painting_canvas",

    sounds = yatm.node_sounds:build("base"),

    is_ground_content = false,

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        -0.5, -0.5, -0.5,  0.5, (1.0 / 16.0) - 0.5,  0.5
      }
    },

    after_place_node = painting_after_place_node,
  }, def)
  local texture_basename = nodedef.texture_basename
  nodedef.texture_basename = nil

  Paintings.members[name] = {
    size = { w = cols, h = rows, d = 1 },
    cells = {}
  }
  local member_entry = Paintings.members[name]

  for row = 1,rows do
    for col = 1,cols do
      local tile_texture_name = texture_basename .. "_" .. (col - 1) .. "_" .. (row - 1) .. ".png"
      local new_def = table_merge(nodedef, {
        groups = table_merge(nodedef.groups or {}, {
          -- This represents the cells position in the total painting
          ["painting_cell_" .. col .. "_" .. row] = 1,
        }),

        tiles = {
          tile_texture_name
        },
      })
      local cell_name = name .. "_" .. col .. "_" .. row
      member_entry.cells[cell_name] = {
        pos = { x = col - 1, y = row - 1, z = 0 }
      }
      minetest.register_node(cell_name, new_def)
    end
  end
end

register_painting("yatm_papercraft:painting_1", 3, 2, {
  description = mod.S("Painting #1"),
  texture_basename = "yatm_painting_380485",
})

register_painting("yatm_papercraft:painting_2", 2, 3, {
  description = mod.S("Painting #2"),
  texture_basename = "yatm_painting_395686",
})

register_painting("yatm_papercraft:painting_3", 2, 3, {
  description = mod.S("Painting #3"),
  texture_basename = "yatm_painting_437182",
})

register_painting("yatm_papercraft:painting_4", 2, 4, {
  description = mod.S("Painting #4"),
  texture_basename = "yatm_painting_437470",
})

register_painting("yatm_papercraft:painting_5", 3, 2, {
  description = mod.S("Painting #5"),
  texture_basename = "yatm_painting_A31869",
})

register_painting("yatm_papercraft:painting_6", 3, 2, {
  description = mod.S("Painting #6"),
  texture_basename = "yatm_painting_A40662",
})

register_painting("yatm_papercraft:painting_7", 3, 2, {
  description = mod.S("Painting #7"),
  texture_basename = "yatm_painting_AC81-0174",
})

register_painting("yatm_papercraft:painting_8", 3, 2, {
  description = mod.S("Painting #8"),
  texture_basename = "yatm_painting_E11326",
})

register_painting("yatm_papercraft:painting_9", 3, 4, {
  description = mod.S("Painting #9"),
  texture_basename = "yatm_painting_rabbit_hare_pet_cute_0",
})

register_painting("yatm_papercraft:painting_10", 3, 4, {
  description = mod.S("Painting #10"),
  texture_basename = "yatm_painting_samurai_warrior_samurai_fighter",
})

register_painting("yatm_papercraft:painting_11", 4, 3, {
  description = mod.S("Painting #11"),
  texture_basename = "yatm_painting_fallen_tree_1997.73.1",
})

register_painting("yatm_papercraft:painting_12", 2, 2, {
  description = mod.S("Painting #12"),
  texture_basename = "yatm_painting_italian_coast_scene_with_ruined_tower_1993.55.1"
})

register_painting("yatm_papercraft:painting_13", 3, 4, {
  description = mod.S("Painting #13"),
  texture_basename = "yatm_painting_october_2003.29.1",
})

yatm_papercraft.Paintings = Paintings
