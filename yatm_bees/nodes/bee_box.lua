--
-- Bee Box, keeps all your bees in one easy to access place.
--
local mod = yatm_bees
local itemstack_is_blank = assert(foundation.com.itemstack_is_blank)
local table_merge = assert(foundation.com.table_merge)
local table_sample = assert(foundation.com.table_sample)
local list_sample = assert(foundation.com.list_sample)
local ItemInterface = assert(yatm.items.ItemInterface)
local fspec = assert(foundation.com.formspec.api)
local Vector3 = foundation.com.Vector3
local player_service = assert(nokore.player_service)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
--
local itemstack_is_frame = assert(yatm.bees.itemstack_is_frame)
local itemstack_is_bee = assert(yatm.bees.itemstack_is_bee)
local itemstack_is_bee_queen = assert(yatm.bees.itemstack_is_bee_queen)
local itemstack_is_bee_princess = assert(yatm.bees.itemstack_is_bee_princess)
local itemstack_is_bee_worker = assert(yatm.bees.itemstack_is_bee_worker)

local MAX_FRAMES = 4

local function render_formspec(pos, user, _state)
  assert(user, "expected a user")

  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  local cio = fspec.calc_inventory_offset

  local inv = meta:get_inventory()
  local frames = inv:get_list("frame_slots")

  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local my_inv_name = "nodemeta:" .. spos

  local bg
  if nodedef.material_basename == "wood" then
    bg = "wood"
  else
    bg = "default"
  end

  return yatm.formspec_render_split_inv_panel(user, 10, math.max(MAX_FRAMES, 4), { bg = bg }, function (loc, rect)
    if loc == "main_body" then
      local formspec =
        fspec.list(my_inv_name, "queen_slot", rect.x, rect.y, 1, 1) ..
        fspec.list(my_inv_name, "princess_slots", rect.x + cio(1), rect.y, 1, 3) ..
        fspec.list(my_inv_name, "worker_slots", rect.x + cio(2), rect.y, 2, 4) ..
        fspec.list(my_inv_name, "frame_slots", rect.x + cio(4.5), rect.y, 1, MAX_FRAMES)

      -- Oh look manually defining each comb row.
      -- I know, I could loop it, and that would be the better way

      -- Anyway adds all the comb slots that are currently active with the frames
      for i = 1,MAX_FRAMES do
        if itemstack_is_frame(frames[i]) then
          formspec =
            formspec ..
            fspec.list(my_inv_name, "comb_slots_" .. i, rect.x + cio(6), rect.y + cio(i - 1), 4, 1)
        end
      end

      return formspec
    elseif loc == "footer" then
      local formspec =
        fspec.list_ring(my_inv_name, "queen_slot") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(my_inv_name, "princess_slots") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(my_inv_name, "worker_slots") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(my_inv_name, "frame_slots") ..
        fspec.list_ring("current_player", "main")

      -- And then list rings for all the comb rows
      for i = 1,MAX_FRAMES do
        if itemstack_is_frame(frames[i]) then
          formspec =
            formspec ..
            fspec.list_ring(my_inv_name, "comb_slots_" .. i) ..
            fspec.list_ring("current_player", "main")
        end
      end

      return formspec
    end
    return ""
  end)
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

local function on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  -- There are 4 rows of comb slots each with 4 columns
  -- Yes it's split this way since it requires 4 frames, one for each row.
  -- This also makes it easier to drop slots from the formspec as needed.
  for i = 1,MAX_FRAMES do
    inv:set_size("comb_slots_"..i, 4)
  end

  -- Frames, each frame can support up to 4 combs
  inv:set_size("frame_slots", MAX_FRAMES)
  -- Drone/Worker slots, there are 8 worker slots
  inv:set_size("worker_slots", 8)
  -- Princess slots
  inv:set_size("princess_slots", 3)
  -- Queen slot, finally one queen per box
  inv:set_size("queen_slot", 1)

  maybe_start_node_timer(pos, 1.0)
end

local function on_timer(pos, elapsed)
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
  -- If a hive has neither Queen nor Princesses, workers will slowly die off unless there are existing "brood combs"

  local hive_death = true
  local can_make_combs = false
  local can_nurture_queen = false

  do
    local princesses = inv:get_list("princess_slots")

    for index, item_stack in pairs(princesses) do
      if itemstack_is_bee_princess(item_stack) then
        can_nurture_queen = true
      end
    end

    if can_nurture_queen then
      hive_death = inv:is_empty("worker_slots")
    end
  end

  -- Queen
  local queen_bee = inv:get_stack("queen_slot", 1)

  -- check if a queen exists
  if itemstack_is_bee_queen(queen_bee) then
    hive_death = inv:is_empty("worker_slots")

    -- a queen already exists, princesses cannot be promoted
    can_nurture_queen = false

    -- can generate combs
    can_make_combs = not inv:is_empty("worker_slots")
  end

  -- print(
  --   "pos", Vector3.to_string(pos),
  --   "hive_death", hive_death,
  --   "can_nurture_queen", can_nurture_queen,
  --   "can_make_combs", can_make_combs
  -- )

  if hive_death then
    local list
    -- the hive is on a death timer
    local hive_death_timer = meta:get_float("hive_death_timer") + elapsed
    while hive_death_timer > 15 do
      hive_death_timer = hive_death_timer - 15

      -- first kill of any workers if the hive is dying
      if inv:is_empty("worker_slots") then
        -- if no workers are left, kill of the princesses
        if inv:is_empty("princess_slots") then
          -- if no princesses are left, kill the queen
          if inv:is_empty("queen_slot") then
            list = inv:get_list("queen_slot")

            for _, item_stack in pairs(list) do
              inv:remove_item("queen_slot", item_stack)
              break
            end
          end
        else
          list = inv:get_list("princess_slots")

          for _, item_stack in pairs(list) do
            inv:remove_item("princess_slots", item_stack)
            break
          end
        end
      else
        list = inv:get_list("worker_slots")

        for _, item_stack in pairs(list) do
          inv:remove_item("worker_slots", item_stack)
          break
        end
      end
    end
    meta:set_float("hive_death_timer", hive_death_timer)
  else
    -- Workers produce honey and nuture other workers into princesses
    meta:set_float("hive_death_timer", 0)

    local queens = inv:get_list("queen_slot")
    local princesses = inv:get_list("princess_slots")
    local workers = inv:get_list("worker_slots")

    local queen_power = 0
    local princess_power = 0
    local worker_power = 0
    local itemdef
    local item_meta

    for index, item_stack in pairs(queens) do
      if itemstack_is_bee_queen(item_stack) then
        itemdef = item_stack:get_definition()

        if itemdef.bee then
          queen_power = queen_power + itemdef.bee.power
        end
      end
    end

    for index, item_stack in pairs(princesses) do
      if itemstack_is_bee_princess(item_stack) then
        itemdef = item_stack:get_definition()

        if itemdef.bee then
          princess_power = princess_power + itemdef.bee.power
        end
      end
    end

    for index, item_stack in pairs(workers) do
      if itemstack_is_bee_worker(item_stack) then
        itemdef = item_stack:get_definition()

        if itemdef.bee then
          worker_power = worker_power + itemdef.bee.power
        end
      end
    end

    if can_nurture_queen then
      local evo_timer
      local evo_duration
      local evo_id
      local evo_def

      for index, item_stack in pairs(princesses) do
        itemdef = item_stack:get_definition()

        if itemdef.bee and itemdef.bee.evolution then
          item_meta = item_stack:get_meta()

          evo_id = item_meta:get("evolution_id")

          if evo_id then
            -- if the evolution_id was set, verify the evolution is actually valid
            evo_def = itemdef.bee.evolution._[evo_id]
            if not evo_def then
              -- invalidate the id
              evo_id = nil
              item_meta:set_string("evolution_id", nil)
            end
          end

          -- if not evolution id was set (or was invalidated recently)
          if not evo_id then
            evo_id, evo_def = table_sample(itemdef.bee.evolution._)
            if evo_id then
              item_meta:set_string("evolution_id", evo_id)
            end
          end

          -- if we really have an evolution id now, evolve time!
          if evo_id then
            evo_def = itemdef.bee.evolution._[evo_id]
            evo_duration = evo_def.duration

            evo_timer = math.min(evo_def.duration, item_meta:get_float("evolution_timer") + elapsed * worker_power)

            item_meta:set_float("evolution_timer", evo_timer)

            item_stack:set_wear(0xFFFF - math.min(0xFFFF * evo_timer / evo_def.duration, 0xFFFF))

            if evo_timer >= evo_duration then
              local queen_stack = ItemStack(evo_def.item_name)

              local leftover = inv:add_item("queen_slot", queen_stack)

              if itemstack_is_blank(leftover) then
                inv:set_stack("princess_slots", index, nil)
              else
                inv:set_stack("princess_slots", index, item_stack)
              end
            else
              inv:set_stack("princess_slots", index, item_stack)
            end
          else
            item_stack:set_wear(0)
            inv:set_stack("princess_slots", index, item_stack)
          end
        end
      end
    end

    if can_make_combs then
      local frames = inv:get_list("frame_slots")

      for i = 1,MAX_FRAMES do
        if itemstack_is_frame(frames[i]) then
          local combs = inv:get_list("comb_slots_" .. i)
        end
      end
    end
  end

  return true
end

local function on_receive_fields(player, form_name, fields, state)

end

local function make_formspec_name(pos)
  return "yatm_bees:bee_box:"..Vector3.to_string(pos)
end

local function on_rightclick(pos, node, user)
  local state = {}
  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
    }
  )
end

local function can_dig(pos, player)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  for i = 1,MAX_FRAMES do
    if not inv:is_empty("comb_slots_" .. i) then
      return false
    end
  end

  return inv:is_empty("frame_slots") and
         inv:is_empty("worker_slots") and
         inv:is_empty("princess_slots") and
         inv:is_empty("queen_slot")
end

local function allow_metadata_inventory_put(pos, list_name, index, stack, player)
  if list_name == "queen_slot" then
    if itemstack_is_bee_queen(stack) then
      return 1
    end
  elseif list_name == "princess_slots" then
    if itemstack_is_bee_princess(stack) then
      return 1
    end
  elseif list_name == "worker_slots" then
    if itemstack_is_bee_worker(stack) then
      return 1
    end
  end
  return 0
end

local function on_metadata_inventory_move(pos, from_index, to_list, to_index, count, player)
  maybe_start_node_timer(pos, 1.0)
  if list == "frame_slots" then
    nokore.formspec_bindings:refresh_formspecs(make_formspec_name(pos), function (player_name, state)
      local player = player_service:get_player_by_name(player_name)
      return render_formspec(pos, player, state)
    end)
  end
end

local function on_metadata_inventory_put(pos, list, index, item_stack, player)
  maybe_start_node_timer(pos, 1.0)
  if list == "queen_slot" then
  elseif list == "frame_slots" then
    nokore.formspec_bindings:refresh_formspecs(make_formspec_name(pos), function (player_name, state)
      local player = player_service:get_player_by_name(player_name)
      return render_formspec(pos, player, state)
    end)
  end
end

local function on_metadata_inventory_take(pos, list, index, item_stack, player)
  maybe_start_node_timer(pos, 1.0)
  if list == "frame_slots" then
    nokore.formspec_bindings:refresh_formspecs(make_formspec_name(pos), function (player_name, state)
      local player = player_service:get_player_by_name(player_name)
      return render_formspec(pos, player, state)
    end)
  end
end

mod:register_node("bee_box_wood", {
  codex_entry_id = "yatm_bees:bee_box_wood",

  basename = "yatm_bees:bee_box",

  material_basename = "wood",

  description = mod.S("Bee Box (Wood)"),

  groups = table_merge(groups, { choppy = 1 }),

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("wood"),

  use_texture_alpha = "opaque",
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

  on_construct = on_construct,
  on_timer = on_timer,
  on_rightclick = on_rightclick,

  allow_metadata_inventory_put = allow_metadata_inventory_put,
  on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,

  can_dig = can_dig,

  item_interface = item_interface,
})

mod:register_node("bee_box_metal", {
  codex_entry_id = "yatm_bees:bee_box_metal",

  basename = "yatm_bees:bee_box",

  material_basename = "metal",

  description = mod.S("Bee Box (Metal)"),

  groups = table_merge(groups, { cracky = 1 }),

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  use_texture_alpha = "opaque",
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

  on_construct = on_construct,
  on_timer = on_timer,
  on_rightclick = on_rightclick,

  allow_metadata_inventory_put = allow_metadata_inventory_put,
  on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,

  can_dig = can_dig,

  item_interface = item_interface,
})
