local HeatInterface = assert(yatm.heating.HeatInterface)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local ItemInterface = assert(yatm.items.ItemInterface)
local SmeltingRegistry = assert(yatm.smelting.SmeltingRegistry)

local function get_smelter_formspec(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    yatm.bg.machine_heated ..
    "list[nodemeta:" .. spos .. ";input_slot;0,0.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";processing_slot;2,0.3;1,1;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";input_slot]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)
  return formspec
end

local heat_interface = HeatInterface.new_simple("heat", 400)
function heat_interface:on_heat_changed(pos, dir, old_heat, new_heat)
  local node = minetest.get_node(pos)
  if math.floor(new_heat) > 0 then
    node.name = "yatm_foundry:smelter_on"
  else
    node.name = "yatm_foundry:smelter_off"
  end
  minetest.swap_node(pos, node)
  yatm.queue_refresh_infotext(pos, node)
  minetest.get_node_timer(pos):start(1.0)
end

local TANK_CAPACITY = 4000
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
    return false, "not molten fluid"
  end
end

fluid_interface.allow_fill = fluid_interface.allow_replace
fluid_interface.allow_drain = fluid_interface.allow_replace

local item_interface = ItemInterface.new_simple("input_slot")

local function smelter_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local heat = math.floor(meta:get_float("heat"))

  local molten_tank_fluid_stack = FluidMeta.get_fluid_stack(meta, "molten_tank")

  local recipe_time = meta:get_float("recipe_time")
  local recipe_time_max = meta:get_float("recipe_time_max")

  meta:set_string("infotext",
    "Heat: " .. heat .. " / " .. heat_interface.heat_capacity .. "\n" ..
    "Molten Tank: " .. FluidStack.pretty_format(molten_tank_fluid_stack, fluid_interface.capacity) .. "\n" ..
    "Time Remaining: " .. yatm_core.format_pretty_time(recipe_time) .. " / " .. yatm_core.format_pretty_time(recipe_time_max)
  )
end

local function smelter_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_size("input_slot", 1)
  inv:set_size("processing_slot", 1)
end

local function smelter_on_rightclick(pos, node, clicker)
  minetest.show_formspec(
    clicker:get_player_name(),
    "yatm_foundry:smelter",
    get_smelter_formspec(pos)
  )
end

local function smelter_on_timer(pos, dtime)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)

  local available_heat = meta:get_float("heat")

  if available_heat > 0 then
    local inv = meta:get_inventory()

    local processing_item_stack = inv:get_stack("processing_slot",  1)
    if yatm_core.itemstack_is_blank(processing_item_stack) then
      local input_item_stack = inv:get_stack("input_slot",  1)

      if not yatm_core.itemstack_is_blank(input_item_stack) then
        local recipe = SmeltingRegistry:get_smelting_recipe(input_item_stack)
        if recipe then
          meta:set_float("recipe_time", recipe.duration)
          meta:set_float("recipe_time_max", recipe.duration)

          local processing_item_stack = yatm_core.itemstack_copy(recipe.source_item_stack)
          inv:add_item("processing_slot", processing_item_stack)
          inv:remove_item("input_slot", processing_item_stack)
        end
      end
    end

    local processing_item_stack = inv:get_stack("processing_slot",  1)
    if not yatm_core.itemstack_is_blank(processing_item_stack) then
      local applyable_dtime = math.min(available_heat / 5.0, dtime)
      meta:set_float("heat", math.max(available_heat - 5 * applyable_dtime, 0))

      local recipe_time = meta:get_float("recipe_time")
      recipe_time = math.max(recipe_time - applyable_dtime, 0)
      meta:set_float("recipe_time", recipe_time)
      if recipe_time == 0 then
        local recipe = SmeltingRegistry:get_smelting_recipe(processing_item_stack)
        if recipe then
          local result_fluid_stack = recipe.results[1]
          if FluidMeta.room_for_fluid(meta, "molten_tank", result_fluid_stack, TANK_CAPACITY, TANK_CAPACITY) then
            FluidMeta.fill_fluid(meta, "molten_tank", result_fluid_stack, TANK_CAPACITY, TANK_CAPACITY, true)
            inv:remove_item("processing_slot", processing_item_stack)
            meta:set_float("recipe_time", 0)
            meta:set_float("recipe_time_max", 0)
            yatm.queue_refresh_infotext(pos, node)
          end
        end
      else
        yatm.queue_refresh_infotext(pos, node)
      end
    end
  end
  return true
end

local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
  fluid_interface_out = 1,
  heatable_device = 1,
}

minetest.register_node("yatm_foundry:smelter_off", {
  basename = "yatm_foundry:smelter",

  description = "Smelter",
  groups = groups,
  tiles = {
    "yatm_smelter_top.off.png",
    "yatm_smelter_bottom.off.png",
    "yatm_smelter_side.off.png",
    "yatm_smelter_side.off.png^[transformFX",
    "yatm_smelter_side.off.png",
    "yatm_smelter_side.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),

  refresh_infotext = smelter_refresh_infotext,
  heat_interface = heat_interface,
  item_interface = item_interface,
  fluid_interface = fluid_interface,

  on_construct = smelter_on_construct,
  on_rightclick = smelter_on_rightclick,
  on_timer = smelter_on_timer,
})

minetest.register_node("yatm_foundry:smelter_on", {
  basename = "yatm_foundry:smelter",

  description = "Smelter",

  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),

  drop = "yatm_foundry:smelter_off",

  tiles = {
    "yatm_smelter_top.on.png",
    "yatm_smelter_bottom.on.png",
    "yatm_smelter_side.on.png",
    "yatm_smelter_side.on.png^[transformFX",
    "yatm_smelter_side.on.png",
    "yatm_smelter_side.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  light_source = 7,

  sounds = default.node_sound_stone_defaults(),

  refresh_infotext = smelter_refresh_infotext,
  heat_interface = heat_interface,
  item_interface = item_interface,
  fluid_interface = fluid_interface,

  on_construct = smelter_on_construct,
  on_rightclick = smelter_on_rightclick,
  on_timer = smelter_on_timer,
})
