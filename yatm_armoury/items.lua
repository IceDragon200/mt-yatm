local mod = assert(yatm_armoury)

-- Grenades - All in one file for easier access
-- If it gets too crowded I'll split them up later
mod:require("/items/grenades.lua") -- WIP

-- Firearms - just all of them thrown into a file for easier access
mod:require("/items/firearms.lua") -- the firearms
mod:require("/items/ammunition.lua") -- the ammunition
mod:require("/items/magazines.lua") -- and the magazines to store ammunition
