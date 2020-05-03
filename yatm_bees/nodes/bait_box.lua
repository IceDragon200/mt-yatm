--[[

  A bait box attracts bees, if you're lucky you'll get a queen!

]]
local ItemInterface = assert(yatm.items.ItemInterface)

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
end)

local function bait_box_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  -- Some bait
  -- Like a honey drop
  inv:set_size("bait_slot", 1)

  -- And then some bees!
  inv:set_size("bees_slot", 16)

  minetest.get_node_timer(pos):start(1.0)
end

local function bait_box_on_timer(pos, elapsed)
  return true
end

local node_box = {
  type = "fixed",
  fixed = {
    {(2 / 16.0) - 0.5, -0.5, (2 / 16.0) - 0.5, (14 / 16.0) - 0.5, (2 / 16.0) - 0.5, (14 / 16.0) - 0.5}, -- Bottom Cap
    {-0.5, (2 / 16.0) - 0.5, -0.5, 0.5, (14 / 16.0) - 0.5, 0.5}, -- Base
    {(2 / 16.0) - 0.5, (14 / 16.0) - 0.5, (2 / 16.0) - 0.5, (14 / 16.0) - 0.5, 0.5, (14 / 16.0) - 0.5}, -- Top Cap
  }
}

local groups = {
  item_interface_out = 1,
  bee_bait_box = 1,
}

minetest.register_node("yatm_bees:bait_box_wood", {
  description = "Bait Box (Wood)",

  groups = yatm_core.table_merge(groups, { choppy = 1 }),

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = default.node_sound_wood_defaults(),

  tiles = {
    "yatm_bait_box_wood_top.png",
    "yatm_bait_box_wood_bottom.png",
    "yatm_bait_box_wood_side.png",
    "yatm_bait_box_wood_side.png",
    "yatm_bait_box_wood_side.png",
    "yatm_bait_box_wood_side.png"
  },
  drawtype = "nodebox",
  node_box = node_box,

  on_construct = bait_box_on_construct,
  on_timer = bait_box_on_timer,

  item_interface = item_interface,
})

minetest.register_node("yatm_bees:bait_box_metal", {
  description = "Bait Box (Metal)",

  groups = yatm_core.table_merge(groups, { cracky = 1 }),

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = default.node_sound_metal_defaults(),

  tiles = {
    "yatm_bait_box_metal_top.png",
    "yatm_bait_box_metal_bottom.png",
    "yatm_bait_box_metal_side.png",
    "yatm_bait_box_metal_side.png",
    "yatm_bait_box_metal_side.png",
    "yatm_bait_box_metal_side.png"
  },
  drawtype = "nodebox",
  node_box = node_box,

  on_construct = bait_box_on_construct,
  on_timer = bait_box_on_timer,

  item_interface = item_interface,
})
