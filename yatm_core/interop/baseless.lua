print("sad yatm sounds, no base game detected")
local node_sounds = assert(yatm_core.node_sounds)

-- empty sounds
node_sounds:register("base", {})
node_sounds:register("glass", { extends = { "base" } })
node_sounds:register("wood", { extends = { "base" } })
node_sounds:register("leaves", { extends = { "base" } })
node_sounds:register("metal", { extends = { "base" } })
node_sounds:register("stone", { extends = { "base" } })
node_sounds:register("water", { extends = { "base" } })
node_sounds:register("cardboard", { extends = { "base" } })
