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

local colors = {
  {"default", "Default"},
  {"tech", "Tech"},
}

local variants = {
  {"gold_princess", "Gold Princess"},
  {"gold_queen", "Gold Queen"},
  {"silver_princess", "Silver Princess"},
  {"silver_queen", "Silver Queen"},
  {"worker", "Worker"},
}

for _,variant_pair in ipairs(variants) do
  local variant_basename = variant_pair[1]
  local variant_name = variant_pair[2]

  for _,color_pair in ipairs(colors) do
    local color_basename = color_pair[1]
    local color_name = color_pair[2]

    local name = mod:make_name("bee_" .. variant_basename .. "_" .. color_basename)

    minetest.register_tool(name, {
      basename = "yatm_bees:bee_" .. variant_basename,
      base_description = variant_name .. " Bee",

      description = variant_name .. " Bee (" .. color_name .. ")",

      groups = {
        bee = 1,
        ["bee_" .. variant_basename] = 1,
        ["bee_color_" .. color_basename] = 1
      },

      inventory_image = "yatm_bees_" .. variant_basename .. "_" .. color_basename .. ".png",

      bee = {
        color = color_basename,
        variant = variant_basename,
      },
    })
  end
end
