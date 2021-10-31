local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local format_pretty_time = assert(foundation.com.format_pretty_time)
local cluster_thermal = assert(yatm.cluster.thermal)
local fspec = assert(foundation.com.formspec.api)

local function get_oven_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local meta = minetest.get_meta(pos)
  local cio = fspec.calc_inventory_offset

  return yatm.formspec_render_split_inv_panel(user, 7, 1, { bg = "machine_heated" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(node_inv_name, "fuel_slot", rect.x, rect.y, 1, 1) ..
        fspec.list(node_inv_name, "input_slot", rect.x + cio(2), rect.y, 1, 1) ..
        fspec.list(node_inv_name, "processing_slot", rect.x + cio(4), rect.y, 1, 1) ..
        fspec.list(node_inv_name, "output_slot", rect.x + cio(6), rect.y, 1, 1)
    elseif loc == "footer" then
      return fspec.list_ring(node_inv_name, "fuel_slot") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(node_inv_name, "input_slot") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(node_inv_name, "output_slot") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function oven_on_rightclick(pos, node, user)
  minetest.show_formspec(
    user:get_player_name(),
    "yatm_culinary:oven",
    get_oven_formspec(pos, user)
  )
end

local function on_construct(pos)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  inv:set_size("fuel_slot", 1)
  inv:set_size("input_slot", 1)
  inv:set_size("processing_slot", 1)
  inv:set_size("output_slot", 1)

  cluster_thermal:schedule_add_node(pos, node)
end

local function after_destruct(pos, node)
  cluster_thermal:schedule_remove_node(pos, node)
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
  maybe_start_node_timer(pos, 1.0)
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
  maybe_start_node_timer(pos, 1.0)
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
  maybe_start_node_timer(pos, 1.0)
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
    "Fuel Time: " .. format_pretty_time(fuel_time) .. " / " .. format_pretty_time(fuel_time_max)
  )
end

yatm.register_stateful_node("yatm_culinary:oven", {
  codex_entry_id = "yatm_culinary:oven",

  basename = "yatm_culinary:oven",

  description = "Oven",

  groups = {
    cracky = 1,
    heatable_device = 1,
    yatm_cluster_thermal = 1,
  },

  paramtype = "none",
  paramtype2 = "facedir",

  on_construct = on_construct,
  after_destruct = after_destruct,

  allow_metadata_inventory_move = allow_metadata_inventory_move,
  allow_metadata_inventory_put = allow_metadata_inventory_put,
  allow_metadata_inventory_take = allow_metadata_inventory_take,

  on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,

  on_timer = on_timer,

  on_rightclick = oven_on_rightclick,

  refresh_infotext = oven_refresh_infotext,

  thermal_interface = {
    groups = {
      heater = 1,
      thermal_user = 1,
    },

    update_heat = function (self, pos, node, heat, dtime)
      local meta = minetest.get_meta(pos)

      if yatm.thermal.update_heat(meta, "heat", heat, 10, dtime) then
        local new_name
        if math.floor(heat) > 0 then
          new_name = "yatm_culinary:oven_on"
        else
          new_name = "yatm_culinary:oven_off"
        end
        if new_name ~= node.name then
          node.name = new_name
          minetest.swap_node(pos, node)
        end

        maybe_start_node_timer(pos, 1.0)
        yatm.queue_refresh_infotext(pos, node)
      end
    end,
  },
}, {
  off = {
    tiles = {
      "yatm_oven_top.png",
      "yatm_oven_bottom.png",
      "yatm_oven_side.png",
      "yatm_oven_side.png",
      "yatm_oven_back.off.png",
      "yatm_oven_front.off.png"
    },
  },

  on = {
    groups = {
      cracky = 1,
      not_in_creative_inventory = 1,
      heatable_device = 1,
      yatm_cluster_thermal = 1,
    },

    tiles = {
      "yatm_oven_top.png",
      "yatm_oven_bottom.png",
      "yatm_oven_side.png",
      "yatm_oven_side.png",
      "yatm_oven_back.on.png",
      "yatm_oven_front.on.png"
    },
  },
})
