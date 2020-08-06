--[[

  Bee Box, keeps all your bees in one easy to access place.

]]
local table_merge = assert(foundation.com.table_merge)

local ItemInterface = assert(yatm.items.ItemInterface)

local function itemstack_is_frame(item_stack)
  if not item_stack:is_empty() then
    local def = item_stack:get_definition()
    if def then
      if def.groups.bee_box_frame then
        return true
      end
    end
  end
  return false
end

local function get_bee_box_formspec(pos, user)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  local inv = meta:get_inventory()

  local frames = inv:get_list("frame_slots")

  local bg
  if nodedef.material_basename == "wood" then
    bg = yatm.formspec_bg_for_player(user:get_player_name(), "wood")
  else
    bg = yatm.formspec_bg_for_player(user:get_player_name(), "default")
  end

  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[10,9]" ..
    bg ..
    "list[nodemeta:" .. spos .. ";queen_slot;0,1.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";princess_slots;1,0.3;1,3;]" ..
    "list[nodemeta:" .. spos .. ";worker_slots;2,0.3;2,4;]" ..
    "list[nodemeta:" .. spos .. ";frame_slots;4.5,0.3;1,4;]"

  -- Oh look manually defining each comb row.
  -- I know, I could loop it, and that would be the better way

  -- Anyway adds all the comb slots that are currently active with the frames
  if itemstack_is_frame(frames[1]) then
    formspec = formspec ..
      "list[nodemeta:" .. spos .. ";comb_slots_1;6,0.3;4,1;]"
  end

  if itemstack_is_frame(frames[2]) then
    formspec = formspec ..
      "list[nodemeta:" .. spos .. ";comb_slots_2;6,1.3;4,1;]"
  end

  if itemstack_is_frame(frames[3]) then
    formspec = formspec ..
      "list[nodemeta:" .. spos .. ";comb_slots_3;6,2.3;4,1;]"
  end

  if itemstack_is_frame(frames[4]) then
    formspec = formspec ..
      "list[nodemeta:" .. spos .. ";comb_slots_4;6,3.3;4,1;]"
  end

  formspec = formspec ..
    "list[current_player;main;1,4.85;8,1;]" ..
    "list[current_player;main;1,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";queen_slot]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";princess_slots]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";worker_slots]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";frame_slots]" ..
    "listring[current_player;main]"

  -- And then list rings for all the comb rows
  if itemstack_is_frame(frames[1]) then
    formspec = formspec ..
      "listring[nodemeta:" .. spos .. ";comb_slots_1]" ..
      "listring[current_player;main]"
  end

  if itemstack_is_frame(frames[2]) then
    formspec = formspec ..
      "listring[nodemeta:" .. spos .. ";comb_slots_2]" ..
      "listring[current_player;main]"
  end

  if itemstack_is_frame(frames[3]) then
    formspec = formspec ..
      "listring[nodemeta:" .. spos .. ";comb_slots_3]" ..
      "listring[current_player;main]"
  end

  if itemstack_is_frame(frames[4]) then
    formspec = formspec ..
      "listring[nodemeta:" .. spos .. ";comb_slots_4]" ..
      "listring[current_player;main]"
  end

  formspec = formspec ..
    default.get_hotbar_bg(1,4.85)

  return formspec
end

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
end)

local node_box = {
  type = "fixed",
  fixed = {
    {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- Cap
    {-0.4375, -0.5, -0.4375, 0.4375, 0.3125, 0.4375}, -- Base
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
  -- This also makes it easier to drop slots from the formspec as needed.
  inv:set_size("comb_slots_1", 4)
  inv:set_size("comb_slots_2", 4)
  inv:set_size("comb_slots_3", 4)
  inv:set_size("comb_slots_4", 4)
  -- Frames, each frame can support up to 4 combs
  inv:set_size("frame_slots", 4)
  -- Drone/Worker slots, there are 8 worker slots
  inv:set_size("worker_slots", 8)
  -- Princess slots
  inv:set_size("princess_slots", 3)
  -- Queen slot, finally one queen per box
  inv:set_size("queen_slot", 1)
end

local function bee_box_on_timer(pos, elapsed)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  -- https://animals.howstuffworks.com/insects/bee
  -- Using the power of the internet, I have done a little research, sorry for being lazy.
  -- Anyway the code here is not 1:1 of true bee behaviour and is fictional, because reasons.
  -- If you want factual bee-keeping, then you're in the wrong place.

  -- The Queen is pretty important, though you need at least 1 worker to do anything extra...
  -- It will lay eggs which will produce "brood combs", which will eventually hatch into workers.
  -- Princesses can aid with speeding up the process of hatching brood combs into workers.
  -- Princesses can be hatched directly from brood combs, or nurtured from existing workers.
  -- If a hive is left without a Queen, but has a princess, the princess can be nutured into a Queen.
  -- If a give has neither Queen nor Princesses, workers will slowly die off unless there are existing "brood combs"

  local queen_bee = inv:get_stack("queen_slot", 1)
  -- Princesses act as nurses and aid with the creation of additional workers
  local princesses = inv:get_list("princess_slots")
  -- Workers produce honey and nuture other workers into princesses
  local workers = inv:get_list("worker_slots")
  local frames = inv:get_list("frame_slots")

  if itemstack_is_frame(frames[1]) then
    local combs1 = inv:get_list("comb_slots_1")
  end

  if itemstack_is_frame(frames[2]) then
    local combs2 = inv:get_list("comb_slots_2")
  end

  if itemstack_is_frame(frames[3]) then
    local combs3 = inv:get_list("comb_slots_3")
  end

  if itemstack_is_frame(frames[4]) then
    local combs4 = inv:get_list("comb_slots_4")
  end

  return true
end

local function bee_box_on_rightclick(pos, node, user)
  minetest.show_formspec(
    user:get_player_name(),
    "yatm_bees:bee_box",
    get_bee_box_formspec(pos, user)
  )
end

local function bee_box_can_dig(pos, player)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  return inv:is_empty("comb_slots_1") and
         inv:is_empty("comb_slots_2") and
         inv:is_empty("comb_slots_3") and
         inv:is_empty("comb_slots_4") and
         inv:is_empty("frame_slots") and
         inv:is_empty("worker_slots") and
         inv:is_empty("princess_slots") and
         inv:is_empty("queen_slot")
end

local function bee_box_on_metadata_inventory_move(pos, from_index, to_list, to_index, count, player)
end

local function bee_box_on_metadata_inventory_put(pos, list, index, item_stack, player)
  if list == "queen_slot" then
    minetest.get_node_timer(pos):start(1.0)
  end
end

local function bee_box_on_metadata_inventory_take(pos, list, index, item_stack, player)
end


minetest.register_node("yatm_bees:bee_box_wood", {
  basename = "yatm_bees:bee_box",

  material_basename = "wood",

  description = "Bee Box (Wood)",

  groups = table_merge(groups, { choppy = 1 }),

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("wood"),

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
  on_rightclick = bee_box_on_rightclick,

  on_metadata_inventory_move = bee_box_on_metadata_inventory_move,
  on_metadata_inventory_put = bee_box_on_metadata_inventory_put,
  on_metadata_inventory_take = bee_box_on_metadata_inventory_take,

  can_dig = bee_box_can_dig,

  item_interface = item_interface,
})

minetest.register_node("yatm_bees:bee_box_metal", {
  basename = "yatm_bees:bee_box",

  material_basename = "metal",

  description = "Bee Box (Metal)",

  groups = table_merge(groups, { cracky = 1 }),

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

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
  on_rightclick = bee_box_on_rightclick,

  on_metadata_inventory_move = bee_box_on_metadata_inventory_move,
  on_metadata_inventory_put = bee_box_on_metadata_inventory_put,
  on_metadata_inventory_take = bee_box_on_metadata_inventory_take,

  can_dig = bee_box_can_dig,

  item_interface = item_interface,
})
