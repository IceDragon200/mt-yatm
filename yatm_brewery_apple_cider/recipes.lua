local mod = yatm_brewery_apple_cider

local brewing_registry = assert(yatm.brewing.brewing_registry)
local aging_registry = assert(yatm.brewing.aging_registry)

-- recipe for creating apple cider from apple juice
aging_registry:register_aging_recipe(mod:make_name("aged_apple_cider"), {
  inputs = {
    item = {
      name = "yatm_brewery:yeast_brewers",
      amount = 1,
    },
    fluid = {
      name = "yatm_brewery_apple_cider:apple_cider",
      amount = 100,
    },
  },
  outputs = {
    item = nil,
    fluid = {
      name = "yatm_brewery_apple_cider:apple_cider",
      amount = 100,
    },
  },
  duration = 3600,
})
