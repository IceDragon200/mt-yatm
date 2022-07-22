--[[

  Bees, there are 5 bee variants currently and within those variants are 2 different 'colors',
  or subkinds.

  This is completely fictional so don't even bother saying "HEY, THAT'S NOT HOW BEES WORK", I know.

  There are 5 variants:

    * 2 gold (Queen and Princess)
    * 2 silver (Queen and Princess)
    * 1 worker

  'Default' bees produce normal honey and combs in the apiary.
  'Tech' bees produce synthetic honey and combs, in the apiary.

    Synthetic honey can be used as a substitute for some recipes, but cannot be eaten.

  Queens produce eggs, which hatch into workers, overtime workers can become princesses.

  Princesses that appear will be of the same rank as the Queen at that time (Silver or Gold).

  Gold bees produce more honey than silver.

  Silver however produces more workers.

]]
local mod = yatm_bees
local string_ends_with = assert(foundation.com.string_ends_with)

local colors = {
  {"default", "Default"},
  {"tech", "Tech"},
}

local variants = {
  gold_princess = {
    description = "Gold Princess",
    power = 8,
    evolve_to = {
      _ = {
        gold_queen = 60 * 5, -- 5 minutes
      }
    },
  },
  gold_queen = {
    description = "Gold Queen",
    power = 16,
  },
  silver_princess = {
    description = "Silver Princess",
    power = 4,
    evolve_to = {
      _ = {
        silver_queen = 60 * 5,
      }
    },
  },
  silver_queen = {
    description = "Silver Queen",
    power = 8,
  },
  worker = {
    description = "Worker",
    power = 1,
    evolve_to = {
      _ = {
        silver_princess = 60 * 5,
        gold_princess = 60 * 5,
      },
      gold_queen = {
        gold_princess = 60 * 5,
      },
      silver_queen = {
        silver_princess = 60 * 5,
      },
    },
  },
}

for variant_basename,variant_data in pairs(variants) do
  local variant_name = variant_data.description

  for _,color_pair in ipairs(colors) do
    local color_basename = color_pair[1]
    local color_name = color_pair[2]

    local name = mod:make_name("bee_" .. variant_basename .. "_" .. color_basename)

    local groups = {
      bee = 1,
      ["bee_" .. variant_basename] = 1,
      ["bee_color_" .. color_basename] = 1
    }

    if string_ends_with(variant_basename, "_queen") then
      groups.bee_queen = 1
    elseif string_ends_with(variant_basename, "_princess") then
      groups.bee_princess = 1
    elseif string_ends_with(variant_basename, "_worker") then
      groups.bee_worker = 1
    end

    local evolution = nil

    if variant_data.evolve_to then
      evolution = {}

      for queen_variant,possible_evolution_variants in pairs(variant_data.evolve_to) do
        local evolution_variants = {}
        local queen_name = "_"
        if queen_variant ~= "_" then
          mod:make_name("bee_" .. queen_variant .. "_" .. color_basename)
        end

        for basename,duration in pairs(possible_evolution_variants) do
          local evo_name = mod:make_name("bee_" .. basename .. "_" .. color_basename)

          evolution_variants[basename] = {
            item_name = evo_name,
            duration = duration,
          }
        end

        evolution[queen_name] = evolution_variants
      end
    end

    minetest.register_tool(name, {
      basename = "yatm_bees:bee_" .. variant_basename,

      base_description = mod.S(variant_name .. " Bee"),

      description = mod.S(variant_name .. " Bee (" .. color_name .. ")"),

      groups = groups,

      inventory_image = "yatm_bees_" .. variant_basename .. "_" .. color_basename .. ".png",

      bee = {
        color = color_basename,
        variant = variant_basename,
        power = variant_data.power,
        evolution = evolution,
      },
    })
  end
end
