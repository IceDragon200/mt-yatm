local mod = yatm_reactors

local variants = {
  {"plutonium", "Plutonium"},
  {"radium", "Radium"},
  {"redranium", "Redranium"},
  {"uranium", "Uranium"},
}

for _,pair in ipairs(variants) do
  local basename = pair[1]
  local name = pair[2]

  mod:register_craftitem("nuclear_pellet_"..basename, {
    basename = "yatm_reactor:nuclear_pellet",
    base_description = mod.S("Nuclear Pellet"),

    description = mod.S("Nuclear Pellet ("..name..")"),

    inventory_image = "yatm_nuclear_pellets_"..basename..".png",

    nuclear_fuel = {
      type = "pellet",
      material = basename,
    },
  })

  mod:register_craftitem("nuclear_pellet_depleted_"..basename, {
    basename = "yatm_reactor:nuclear_pellet_depleted",
    base_description = mod.S("Nuclear Pellet [Depleted]"),

    description = mod.S("Nuclear Pellet [Depleted] ("..name..")"),

    inventory_image = "yatm_nuclear_pellets_depleted_"..basename..".png",

    nuclear_fuel = {
      type = "pellet",
      material = basename,
    },
  })
end
