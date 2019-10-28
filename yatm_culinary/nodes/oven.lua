local function get_oven_formspec(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  local formspec =
    "size[8,9]" ..
    "list[nodemeta:" .. spos .. ";fuel_slot;3,2.5.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";input_slot;1,1;1,1;]" ..
    "list[nodemeta:" .. spos .. ";processing_slot;3,1;1,1;]" ..
    "list[nodemeta:" .. spos .. ";output_slot;5,1;1,1;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";fuel_slot]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";input_slot]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";output_slot]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)

  return formspec
end

local function oven_on_rightclick(pos, node, clicker)
  minetest.show_formspec(
    clicker:get_player_name(),
    "yatm_culinary:oven",
    get_oven_formspec(pos)
  )
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  inv:set_size("fuel_slot", 1)
  inv:set_size("input_slot", 1)
  inv:set_size("processing_slot", 1)
  inv:set_size("output_slot", 1)
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  return count
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
  return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
  return stack:get_count()
end

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  minetest.get_node_timer(pos):start(1.0)
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
  minetest.get_node_timer(pos):start(1.0)
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
  minetest.get_node_timer(pos):start(1.0)
end

local function on_timer(pos, elapsed)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  -- Fuel > Heat
  local fuel_time = meta:get_float("fuel_time") or 0
  local fuel_time_max = meta:get_float("fuel_time_max") or 0
  local heat = meta:get_float("heat") or 0

  if fuel_time > 0 then
    meta:set_float("fuel_time", fuel_time - elapsed)
    meta:set_float("heat", math.min(heat + 10 * elapsed, 1600))

    if node.name ~= "yatm_culinary:oven_on" then
      node.name = "yatm_culinary:oven_on"
      minetest.swap_node(pos, node)
    end
    yatm.queue_refresh_infotext(pos, node)
  else
    local fuel_list = inv:get_list("fuel_slot")
    local fuel, afterfuel = minetest.get_craft_result({
      method = "fuel",
      width = 1,
      items = fuel_list
    })

    if fuel.time > 0 then
      inv:set_stack("fuel_slot", 1, afterfuel.items[1])

      meta:set_float("fuel_time", fuel.time)
      meta:set_float("fuel_time_max", fuel.time)

      node.name = "yatm_culinary:oven_on"
      minetest.swap_node(pos, node)
      yatm.queue_refresh_infotext(pos)
    else
      meta:set_float("fuel_time", 0)
      meta:set_float("fuel_time_max", 0)

      if heat > 0 then
        -- Heat dissipation logic - wow!
        meta:set_float("heat", math.max(heat - 5 * elapsed, 0))
        yatm.queue_refresh_infotext(pos, node)
      else
        node.name = "yatm_culinary:oven_off"
        minetest.swap_node(pos, node)
        yatm.queue_refresh_infotext(pos, node)
      end
    end
  end

  local heat = meta:get_float("heat") or 0

  -- Heat > Work
  if heat > 0 then
    --
    local input_stack = inv:get_stack("input_slot", 1)
    if not input_stack:is_empty() then
      -- TODO: get food specific recipes from the cooking craft
    end
  else
    return false
  end
  return true
end

local function oven_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local fuel_time = meta:get_float("fuel_time")
  local fuel_time_max = meta:get_float("fuel_time_max")

  local heat = math.floor(meta:get_float("heat"))

  meta:set_string("infotext",
    -- TODO: pull the max heat from configuration
    "Heat: " .. heat .. " / 1600" .. "\n" ..
    "Fuel Time: " .. yatm_core.format_pretty_time(fuel_time) .. " / " .. yatm_core.format_pretty_time(fuel_time_max)
  )
end

minetest.register_node("yatm_culinary:oven_off", {
  description = "Oven",

  groups = {
    cracky = 1,
    heatable_device = 1,
  },

  tiles = {
    "yatm_oven_top.png",
    "yatm_oven_bottom.png",
    "yatm_oven_side.png",
    "yatm_oven_side.png",
    "yatm_oven_back.off.png",
    "yatm_oven_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = on_construct,

  allow_metadata_inventory_move = allow_metadata_inventory_move,
  allow_metadata_inventory_put = allow_metadata_inventory_put,
  allow_metadata_inventory_take = allow_metadata_inventory_take,

  on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,

  on_timer = on_timer,

  on_rightclick = oven_on_rightclick,

  refresh_infotext = oven_refresh_infotext,
})

minetest.register_node("yatm_culinary:oven_on", {
  description = "Oven",

  groups = {
    cracky = 1,
    not_in_creative_inventory = 1,
    heatable_device = 1,
  },

  tiles = {
    "yatm_oven_top.png",
    "yatm_oven_bottom.png",
    "yatm_oven_side.png",
    "yatm_oven_side.png",
    "yatm_oven_back.on.png",
    "yatm_oven_front.on.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = on_construct,

  allow_metadata_inventory_move = allow_metadata_inventory_move,
  allow_metadata_inventory_put = allow_metadata_inventory_put,
  allow_metadata_inventory_take = allow_metadata_inventory_take,

  on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,

  on_timer = on_timer,

  on_rightclick = oven_on_rightclick,

  refresh_infotext = oven_refresh_infotext,
})
