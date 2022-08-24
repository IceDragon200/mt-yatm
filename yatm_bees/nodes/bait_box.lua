--
-- A bait box attracts bees, if you're lucky you'll get a queen!
--
local mod = yatm_bees
local table_merge = assert(foundation.com.table_merge)
local itemstack_is_blank = assert(foundation.com.itemstack_is_blank)
local ItemInterface = assert(yatm.items.ItemInterface)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local bait_catches_registry = yatm.bees.bait_catches_registry
local fspec = assert(foundation.com.formspec.api)
local Vector3 = foundation.com.Vector3
local player_service = assert(nokore.player_service)

local CATCH_INTERVAL = 15 -- seconds

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
end)

local function render_formspec(pos, user, _state)
  assert(user, "expected a user")

  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  local cio = fspec.calc_inventory_offset

  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local my_inv_name = "nodemeta:" .. spos

  local bg
  if nodedef.material_basename == "wood" then
    bg = "wood"
  else
    bg = "default"
  end

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = bg }, function (loc, rect)
    if loc == "main_body" then
      local formspec =
        fspec.list(my_inv_name, "bait_slot", rect.x, rect.y, 1, 1) ..
        fspec.list(my_inv_name, "bees_slot", rect.x + cio(2), rect.y, 4, 4)

      return formspec
    elseif loc == "footer" then
      local formspec =
        fspec.list_ring(my_inv_name, "bait_slot") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(my_inv_name, "bees_slot") ..
        fspec.list_ring("current_player", "main")

      return formspec
    end
    return ""
  end)
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  -- Some bait
  -- Like a honey drop
  inv:set_size("bait_slot", 1)

  -- And then some bees!
  inv:set_size("bees_slot", 16)

  maybe_start_node_timer(pos, 1.0)
end

local function on_timer(pos, elapsed)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  -- calculate the total elapsed time
  local elapsed_check = meta:get_float("elapsed_check") + elapsed

  local stack
  local leftover
  local catch_item
  local bait_name

  -- loop the interval checks, the populate the box as much as possible
  while elapsed_check > CATCH_INTERVAL do
    -- subtract the interval and continue
    elapsed_check = elapsed_check - CATCH_INTERVAL

    -- pull whatever is currently in the bait slot
    stack = inv:get_stack("bait_slot", 1)

    -- ensure that the bait isn't empty
    if not itemstack_is_blank(stack) then
      -- catches are indexed by their name
      bait_name = stack:get_name()

      -- try determining what would be caught in the bait box
      catch_item = bait_catches_registry:random_catch(bait_name)

      if catch_item then
        -- turn the catch_item into an actual ItemStack
        catch_item = ItemStack(catch_item)

        -- try adding the catch item to the inventory, getting back the leftovers
        leftover = inv:add_item("bees_slot", catch_item)

        if leftover:get_count() < catch_item:get_count() then
          -- if anything was added to the inventory, consume the bait
          inv:remove_item("bait_slot", stack:peek_item(1))
        end
      end
    end
  end

  -- set the elapsed time
  meta:set_float("elapsed_check", elapsed_check)

  return true
end

local function on_receive_fields(player, form_name, fields, state)

end

local function make_formspec_name(pos)
  return "yatm_bees:bait_box:"..Vector3.to_string(pos)
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

  return inv:is_empty("bees_slot") and
         inv:is_empty("bait_slot")
end

local function on_metadata_inventory_move(pos, from_index, to_list, to_index, count, player)
  maybe_start_node_timer(pos, 1.0)
end

local function on_metadata_inventory_put(pos, list, index, item_stack, player)
  maybe_start_node_timer(pos, 1.0)
end

local function on_metadata_inventory_take(pos, list, index, item_stack, player)
  maybe_start_node_timer(pos, 1.0)
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

mod:register_node("bait_box_wood", {
  description = "Bait Box (Wood)",

  groups = table_merge(groups, { choppy = 1 }),

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("wood"),

  use_texture_alpha = "opaque",
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

  on_construct = on_construct,
  on_timer = on_timer,
  on_rightclick = on_rightclick,

  on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,

  can_dig = can_dig,

  item_interface = item_interface,
})

mod:register_node("bait_box_metal", {
  description = "Bait Box (Metal)",

  groups = table_merge(groups, { cracky = 1 }),

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  use_texture_alpha = "opaque",
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

  on_construct = on_construct,
  on_timer = on_timer,
  on_rightclick = on_rightclick,

  on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,

  can_dig = can_dig,

  item_interface = item_interface,
})
