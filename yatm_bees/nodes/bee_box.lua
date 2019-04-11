local node_box = {
  type = "fixed",
  fixed = {
    {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
    {-0.4375, -0.5, -0.4375, 0.4375, 0.3125, 0.4375}, -- NodeBox2
  }
}

local groups = {
  item_interface_out = 1,
  bee_box = 1,
}

local function bee_box_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  -- There are 4 rows of comb slots each with 4 columns
  -- Yes it's split this way since it requires 4 frames, one for each row.
  inv:set_size("comb_slots_1", 4)
  inv:set_size("comb_slots_2", 4)
  inv:set_size("comb_slots_3", 4)
  inv:set_size("comb_slots_4", 4)
  -- Frames, each frame can support up to 4 combs
  inv:set_size("frame_slots", 4)
  -- Drone/Worker slots, there are 8 drone/worker slots
  inv:set_size("worker_slots", 8)
  -- Princess slots
  inv:set_size("princess_slots", 3)
  -- Queen slot, finally one queen per box
  inv:set_size("queen_slot", 1)
end

local function bee_box_on_timer(pos, elapsed)
end

minetest.register_node("yatm_bees:bee_box_wood", {
  description = "Apiary (Wood)",

  groups = yatm_core.table_merge(groups, { choppy = 1 }),

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    "yatm_bee_box_wood_top.png",
    "yatm_bee_box_wood_bottom.png",
    "yatm_bee_box_wood_side.png",
    "yatm_bee_box_wood_side.png",
    "yatm_bee_box_wood_back.png",
    "yatm_bee_box_wood_front.png"
  },
  drawtype = "nodebox",
  node_box = node_box,

  on_construct = bee_box_on_construct,
  on_timer = bee_box_on_timer,
})

minetest.register_node("yatm_bees:bee_box_metal", {
  description = "Apiary (Metal)",

  groups = yatm_core.table_merge(groups, { cracky = 1 }),

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    "yatm_bee_box_metal_top.png",
    "yatm_bee_box_metal_bottom.png",
    "yatm_bee_box_metal_side.png",
    "yatm_bee_box_metal_side.png",
    "yatm_bee_box_metal_back.png",
    "yatm_bee_box_metal_front.png"
  },
  drawtype = "nodebox",
  node_box = node_box,

  on_construct = bee_box_on_construct,
  on_timer = bee_box_on_timer,
})
