local Directions = assert(foundation.com.Directions)
local is_blank = assert(foundation.com.is_blank)
local itemstack_split = assert(foundation.com.itemstack_split)
local format_pretty_time = assert(foundation.com.format_pretty_time)
local cluster_devices = assert(yatm.cluster.devices)
local ItemInterface = assert(yatm.items.ItemInterface)
local Energy = assert(yatm.energy)
local grinding_registry = assert(yatm.grinding.grinding_registry)

local function get_auto_grinder_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "machine") ..
    "list[nodemeta:" .. spos .. ";grinder_input;0,0.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";grinder_processing;2,0.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";grinder_output;4,0.3;2,2;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";grinder_input]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";grinder_output]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)
  return formspec
end

local auto_grinder_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:auto_grinder_error",
    error = "yatm_machines:auto_grinder_error",
    off = "yatm_machines:auto_grinder_off",
    on = "yatm_machines:auto_grinder_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    startup_threshold = 100,
    network_charge_bandwidth = 1000,
  },
}

local item_interface =
  ItemInterface.new_directional(function (self, pos, dir)
    local node = minetest.get_node(pos)
    local new_dir = Directions.facedir_to_face(node.param2, dir)
    if new_dir == Directions.D_UP or new_dir == Directions.D_DOWN then
      return "grinder_input"
    end
    return "grinder_output"
  end)

function auto_grinder_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local consumed = 0

  if is_blank(meta:get_string("active_recipe")) then
    -- check for recipe
    local input_stack = inv:get_stack("grinder_input", 1)
    local recipe = grinding_registry:find_grinding_recipe(input_stack)

    if recipe then
      meta:set_string("active_recipe", recipe.name)
      meta:set_float("duration", recipe.duration)
      meta:set_float("work_time", recipe.duration)
      local processing_stack, rest = itemstack_split(input_stack, 1)
      inv:add_item("grinder_processing", processing_stack)
      inv:set_stack("grinder_input", 1, rest)

      yatm.queue_refresh_infotext(pos, node)
    else
      -- to idle
      yatm.devices.set_idle(meta, 1)
    end
  else
    local work_time = meta:get_float("work_time")
    work_time = work_time - dtime
    if work_time > 0 then
      meta:set_float("work_time", work_time)
      -- should probably be optional
      yatm.queue_refresh_infotext(pos, node)
      consumed = consumed + 10
    else
      local input_stack = inv:get_stack("grinder_processing", 1)
      local recipe = grinding_registry:find_grinding_recipe(input_stack)
      if recipe then
        local room_for_all = true
        for _,item_stack in ipairs(recipe.output_item_stacks) do
          room_for_all = room_for_all and
                         inv:room_for_item("grinder_output", item_stack)
        end

        if room_for_all then
          for _,item_stack in ipairs(recipe.output_item_stacks) do
            inv:add_item("grinder_output", item_stack)
          end

          inv:remove_item("grinder_processing", input_stack)

          meta:set_string("active_recipe", nil)
          meta:set_string("error", nil)
          meta:set_float("duration", 0)
          meta:set_float("work_time", 0)

          yatm.queue_refresh_infotext(pos, node)
        else
          meta:set_string("error", "output full")
          yatm.devices.set_idle(meta, 1)

          yatm.queue_refresh_infotext(pos, node)
        end
      else
        inv:add_item("grinder_rejected", input_stack)
        inv:remove_item("grinder_processing", input_stack)

        meta:set_string("active_recipe", nil)
        meta:set_string("error", nil)
        meta:set_float("duration", 0)
        meta:set_float("work_time", 0)

        yatm.queue_refresh_infotext(pos, node)
      end
    end
  end

  return consumed
end

local function auto_grinder_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local recipe_name = meta:get_string("active_recipe") or ""
  local work_time = meta:get_float("work_time")
  local duration = meta:get_float("duration")

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Recipe: " .. recipe_name .. "\n" ..
    "Time: " .. format_pretty_time(work_time) .. " / " .. format_pretty_time(duration)

  meta:set_string("infotext", infotext)
end

local function auto_grinder_on_construct(pos)
  yatm.devices.device_on_construct(pos)
  --
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  --
  inv:set_size("grinder_input", 1)
  inv:set_size("grinder_processing", 1)
  inv:set_size("grinder_rejected", 1)
  inv:set_size("grinder_output", 4)
end

local function auto_grinder_on_rightclick(pos, node, user)
  minetest.show_formspec(
    user:get_player_name(),
    "yatm_machines:auto_grinder",
    get_auto_grinder_formspec(pos, user)
  )
end

local groups = {
  cracky = 1,
  yatm_energy_device = 1,
  item_interface_in = 1,
  item_interface_out = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:auto_grinder",

  description = "Auto Grinder",

  groups = groups,

  drop = auto_grinder_yatm_network.states.off,

  tiles = {
    "yatm_auto_grinder_top.off.png",
    "yatm_auto_grinder_bottom.png",
    "yatm_auto_grinder_side.off.png",
    "yatm_auto_grinder_side.off.png^[transformFX",
    "yatm_auto_grinder_back.off.png",
    "yatm_auto_grinder_front.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  on_construct = auto_grinder_on_construct,
  on_rightclick = auto_grinder_on_rightclick,

  yatm_network = auto_grinder_yatm_network,
  item_interface = item_interface,
  refresh_infotext = auto_grinder_refresh_infotext,
}, {
  on = {
    tiles = {
      "yatm_auto_grinder_top.on.png",
      "yatm_auto_grinder_bottom.png",
      "yatm_auto_grinder_side.on.png",
      "yatm_auto_grinder_side.on.png^[transformFX",
      "yatm_auto_grinder_back.on.png",
      -- "yatm_auto_grinder_front.off.png"
      {
        name = "yatm_auto_grinder_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.25
        },
      },
    },
  },
  error = {
    tiles = {
      "yatm_auto_grinder_top.error.png",
      "yatm_auto_grinder_bottom.png",
      "yatm_auto_grinder_side.error.png",
      "yatm_auto_grinder_side.error.png^[transformFX",
      "yatm_auto_grinder_back.error.png",
      "yatm_auto_grinder_front.error.png",
    },
  },
})
