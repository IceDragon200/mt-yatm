--
-- Basins act as a item storage and fluid storage node, it is meant to interact with
-- a press or mixer node directly above it, actually any number of specialized
-- nodes can be placed above it to affect the recipe
--
local mod = yatm_brewery
local Directions = assert(foundation.com.Directions)
local ItemInterface = assert(yatm.items.ItemInterface)
local FluidInterface = assert(yatm.fluids.FluidInterface)

local BASIN_CAPACITY = 4000

local fluid_interface = FluidInterface.new_simple("tank", BASIN_CAPACITY)

local item_interface = ItemInterface.new_simple("main")

local function on_construct(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()
  inv:set_size("main", 4)
end

local function on_destruct(pos)
end

mod:register_node("wood_basin", {
  description = "Wood Basin",

  groups = {
    basin = 1,
    choppy = 1,
  },

  tiles = {
  },

  on_construct = on_construct,
  on_destruct = on_destruct,

  fluid_interface = fluid_interface,
  item_interface = item_interface,
})
