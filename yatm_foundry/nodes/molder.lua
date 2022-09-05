--
-- A non-electric version of the molder, unfortunately for you it requires heat instead of energy!
--
-- Reason? Balance, otherwise you could just abuse the poor thing for all your molding needs.
--
-- That or just make it god awful slow at it's job.
--
local Directions = assert(foundation.com.Directions)
local format_pretty_time = assert(foundation.com.format_pretty_time)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local itemstack_is_blank = assert(foundation.com.itemstack_is_blank)
local itemstack_copy = assert(foundation.com.itemstack_copy)
local table_merge = assert(foundation.com.table_merge)
local cluster_thermal = assert(yatm.cluster.thermal)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local ItemInterface = assert(yatm.items.ItemInterface)
local molding_registry = assert(yatm.molding.molding_registry)
local fspec = assert(foundation.com.formspec.api)

local function get_molder_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_heated" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(node_inv_name, "mold_slot", rect.x, rect.y, 1, 1) ..
             fspec.list(node_inv_name, "molding_slot", rect.x + cio(2), rect.y, 1, 1) ..
             fspec.list(node_inv_name, "output_slot", rect.x + cio(4), rect.y, 1, 1)
    elseif loc == "footer" then
      return fspec.list_ring(node_inv_name, "mold_slot") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(node_inv_name, "output_slot") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local TANK_CAPACITY = 8000
local fluid_interface = FluidInterface.new_simple("molten_tank", TANK_CAPACITY)

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

function fluid_interface:allow_replace(pos, dir, fluid_stack)
  -- If the fluid is molten, then it can be replaced
  if FluidStack.is_member_of_group(fluid_stack, "molten") then
    return true
  else
    return false, "fluid is not molten"
  end
end

fluid_interface.allow_fill = fluid_interface.allow_replace
fluid_interface.allow_drain = fluid_interface.allow_replace

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_UP or new_dir == Directions.D_DOWN then
    return "mold_slot"
  end
  return "output_slot"
end)

local function molder_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local heat = math.floor(meta:get_float("heat"))

  local molten_tank_fluid_stack = FluidMeta.get_fluid_stack(meta, "molten_tank")
  local molding_tank_fluid_stack = FluidMeta.get_fluid_stack(meta, "molding_tank")
  local recipe_name = meta:get_string("recipe_name")
  local recipe_time = meta:get_float("recipe_time")
  local recipe_time_max = meta:get_float("recipe_time_max")

  local capacity = fluid_interface:get_capacity(pos, 0)

  local infotext =
    cluster_thermal:get_node_infotext(pos) .. "\n" ..
    "Heat: " .. heat .. "\n" ..
    "Recipe: " .. recipe_name .. "\n" ..
    "Molten Tank: " .. FluidStack.pretty_format(molten_tank_fluid_stack, capacity) .. "\n" ..
    "Molding Tank: " .. FluidStack.pretty_format(molding_tank_fluid_stack, capacity) .. "\n" ..
    "Time Remaining: " .. format_pretty_time(recipe_time) .. " / " .. format_pretty_time(recipe_time_max)

  meta:set_string("infotext", infotext)
end

local function molder_on_rightclick(pos, node, user)
  maybe_start_node_timer(pos, 1.0)
  minetest.show_formspec(
    user:get_player_name(),
    "yatm_foundry:molder",
    get_molder_formspec(pos, user)
  )
end

local function molder_on_timer(pos, dtime)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)

  local available_heat = meta:get_float("heat")
  if available_heat > 0 then
    local inv = meta:get_inventory()

    local molding_fluid = FluidMeta.get_fluid_stack(meta, "molding_tank")
    if not FluidStack.presence(molding_fluid) then
      local mold_item_stack = inv:get_stack("mold_slot",  1)

      if not itemstack_is_blank(mold_item_stack) then
        local molten_fluid = FluidMeta.get_fluid_stack(meta, "molten_tank")
        local recipe = molding_registry:get_molding_recipe(mold_item_stack, molten_fluid)
        if recipe then
          local drained_fluid = FluidMeta.drain_fluid(meta, "molten_tank", recipe.molten_fluid, TANK_CAPACITY, TANK_CAPACITY, false)
          if FluidMeta.room_for_fluid(meta, "molding_tank", drained_fluid, TANK_CAPACITY, TANK_CAPACITY) then
            meta:set_float("recipe_time", recipe.duration)
            meta:set_float("recipe_time_max", recipe.duration)
            meta:set_string("recipe_name", recipe.name)
            inv:add_item("molding_slot", mold_item_stack)
            inv:remove_item("mold_slot", mold_item_stack)
            local filled_fluid = FluidMeta.fill_fluid(meta, "molding_tank", drained_fluid, TANK_CAPACITY, TANK_CAPACITY, true)
            local drained_fluid = FluidMeta.drain_fluid(meta, "molten_tank", filled_fluid, TANK_CAPACITY, TANK_CAPACITY, true)
            --print("filled fluid in molten tank", minetest.pos_to_string(pos), FluidStack.pretty_format(filled_fluid))
            yatm.queue_refresh_infotext(pos, node)
          end
        end
      end
    end

    local molding_fluid = FluidMeta.get_fluid_stack(meta, "molding_tank")
    if FluidStack.presence(molding_fluid) then
      local applyable_dtime = math.min(available_heat / 5.0, dtime)
      meta:set_float("heat", math.max(available_heat - 5 * applyable_dtime, 0))

      local recipe_time = meta:get_float("recipe_time")
      recipe_time = math.max(recipe_time - applyable_dtime, 0)
      meta:set_float("recipe_time", recipe_time)
      if recipe_time == 0 then
        local mold_item_stack = inv:get_stack("molding_slot",  1)
        local recipe = molding_registry:get_molding_recipe(mold_item_stack, molding_fluid)

        if recipe and inv:room_for_item("output_slot", recipe.result_item_stack) then
          local drained_fluid = FluidMeta.drain_fluid(meta, "molding_tank", recipe.molten_fluid, TANK_CAPACITY, TANK_CAPACITY, false)
          if drained_fluid and drained_fluid.amount == recipe.molten_fluid.amount then
            local drained_fluid = FluidMeta.drain_fluid(meta, "molding_tank", recipe.molten_fluid, TANK_CAPACITY, TANK_CAPACITY, true)
            local result = itemstack_copy(recipe.result_item_stack)
            --print("drained fluid from molten tank", minetest.pos_to_string(pos), FluidStack.pretty_format(drained_fluid))
            inv:add_item("output_slot", result)
            inv:add_item("mold_slot", mold_item_stack)
            inv:remove_item("molding_slot", mold_item_stack)
            meta:set_string("recipe_name", "")
            meta:set_float("recipe_time", 0)
            meta:set_float("recipe_time_max", 0)
            yatm.queue_refresh_infotext(pos, node)
          end
        end
      else
        yatm.queue_refresh_infotext(pos, node)
      end
    end
    return true
  else
    return false
  end
end

local groups = {
  cracky = nokore.dig_class("copper"),
  fluid_interface_in = 1,
  item_interface_in = 1,
  item_interface_out = 1,
  heatable_device = 1,
  heat_interface_in = 1,
  yatm_cluster_thermal = 1,
}

local node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (12 / 16.0) - 0.5, 0.5}, -- Base
    {-0.5, (15 / 16.0) - 0.5, -0.5, 0.5, 0.5, 0.5}, -- Cap
    -- Columns
    {(1 / 16.0) - 0.5, (12 / 16.0) - 0.5, (1 / 16.0) - 0.5, (3 / 16.0) - 0.5, (15 / 16.0) - 0.5, (3 / 16.0) - 0.5},
    {(1 / 16.0) - 0.5, (12 / 16.0) - 0.5, (13 / 16.0) - 0.5, (3 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5},
    {(13 / 16.0) - 0.5, (12 / 16.0) - 0.5, (1 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5, (3 / 16.0) - 0.5},
    {(13 / 16.0) - 0.5, (12 / 16.0) - 0.5, (13 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5},
  },
}

yatm.register_stateful_node("yatm_foundry:molder", {
  basename = "yatm_foundry:molder",

  description = "Molder",

  codex_entry_id = "yatm_foundry:molder",

  groups = groups,

  drop = "yatm_foundry:molder_off",

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("stone"),

  fluid_interface = fluid_interface,
  item_interface = item_interface,

  refresh_infotext = molder_refresh_infotext,

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("mold_slot", 1)
    inv:set_size("molding_slot", 1)
    inv:set_size("output_slot", 1)
    cluster_thermal:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    cluster_thermal:schedule_remove_node(pos, node)
  end,

  on_rightclick = molder_on_rightclick,
  on_timer = molder_on_timer,

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
          new_name = "yatm_foundry:molder_on"
        else
          new_name = "yatm_foundry:molder_off"
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
    use_texture_alpha = "opaque",
    tiles = {
      "yatm_molder_top.off.png",
      "yatm_molder_bottom.off.png",
      "yatm_molder_side.off.png",
      "yatm_molder_side.off.png^[transformFX",
      "yatm_molder_side.off.png",
      "yatm_molder_side.off.png"
    },
  },

  on = {
    groups = table_merge(groups, {not_in_creative_inventory = 1}),

    use_texture_alpha = "opaque",
    tiles = {
      "yatm_molder_top.on.png",
      "yatm_molder_bottom.on.png",
      "yatm_molder_side.on.png",
      "yatm_molder_side.on.png^[transformFX",
      "yatm_molder_side.on.png",
      "yatm_molder_side.on.png"
    },
  }
})
