--
-- The Roller, or Metal Former, takes various metals or plates and forms them into other shapes.
--
local cluster_devices = assert(yatm.cluster.devices)
local Energy = assert(yatm.energy)
local ItemInterface = assert(yatm.items.ItemInterface)
local rolling_registry = assert(yatm.rolling.rolling_registry)

local function get_roller_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "machine") ..
    "list[nodemeta:" .. spos .. ";roller_input;0,0.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";roller_processing;1.5,0.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";roller_output;3,0.3;1,1;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";roller_input]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";roller_output]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)
  return formspec
end

function roller_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local recipe_time = meta:get_float("recipe_time")
  local recipe_time_max = meta:get_float("recipe_time_max")

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Time Remaining: " .. yatm_core.format_pretty_time(recipe_time) .. " / " .. yatm_core.format_pretty_time(recipe_time_max)

  meta:set_string("infotext", infotext)
end

local roller_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:roller_error",
    error = "yatm_machines:roller_error",
    off = "yatm_machines:roller_off",
    on = "yatm_machines:roller_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 200,
    passive_lost = 0,
    startup_threshold = 100,
  }
}

function roller_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  local energy_consumed = 0
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  do
    local processing_stack = inv:get_stack("roller_processing", 1)
    if yatm_core.itemstack_is_blank(processing_stack) then
      local input_stack = inv:get_stack("roller_input", 1)
      if not yatm_core.itemstack_is_blank(input_stack) then
        local recipe = RollerRegistry:get_roller_recipe(input_stack)
        if recipe then
          local consumed_stack = input_stack:peek_item(recipe.required_count)
          print("Taking", consumed_stack:to_string(), "for recipe", recipe.result:to_string())
          -- FIXME: once the deltas are being used instead of fixed time, this can be changed
          meta:set_float("recipe_time", recipe.duration)
          meta:set_float("recipe_time_max", recipe.duration)
          inv:remove_item("roller_input", consumed_stack)
          inv:set_stack("roller_processing", 1, consumed_stack)
        else
          yatm.devices.set_idle(meta, 2)
        end
      end
    end
  end

  do
    local processing_stack = inv:get_stack("roller_processing", 1)
    if not yatm_core.itemstack_is_blank(processing_stack) then
      if yatm_core.metaref_dec_float(meta, "recipe_time", dtime) <= 0 then
        local recipe = RollerRegistry:get_roller_recipe(processing_stack)
        if recipe then
          if inv:room_for_item("roller_output", recipe.result) then
            print("Adding to roller_output", recipe.result:to_string())
            inv:add_item("roller_output", recipe.result)
            inv:set_stack("roller_processing", 1, ItemStack(nil))
            meta:set_float("recipe_time", 0)
            meta:set_float("recipe_time_max", 0)
            yatm.queue_refresh_infotext(pos, node)
          end
        end
      else
        energy_consumed = energy_consumed + 5
      end
    end
  end

  return energy_consumed
end

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_UP or new_dir == yatm_core.D_DOWN then
    return "roller_output"
  end
  return "roller_input"
end)

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:roller",

  description = "Roller",
  groups = {
    cracky = 1,
    item_interface_in = 1,
    item_interface_out = 1,
    yatm_energy_device = 1,
  },
  drop = roller_yatm_network.states.off,

  sounds = default.node_sound_metal_defaults(),

  tiles = {
    "yatm_roller_top.off.png",
    "yatm_roller_bottom.png",
    "yatm_roller_side.off.png",
    "yatm_roller_side.off.png^[transformFX",
    "yatm_roller_back.off.png",
    "yatm_roller_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = function (pos)
    yatm.devices.device_on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("roller_input", 1)
    inv:set_size("roller_processing", 1)
    inv:set_size("roller_output", 1)
  end,

  on_rightclick = function (pos, node, user)
    minetest.show_formspec(
      user:get_player_name(),
      "yatm_machines:roller",
      get_roller_formspec(pos)
    )
  end,

  can_dig = function (pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    return inv:is_empty("roller_input") and
      inv:is_empty("roller_processing") and
      inv:is_empty("roller_output")
  end,

  yatm_network = roller_yatm_network,

  item_interface = item_interface,

  refresh_infotext = roller_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_roller_top.error.png",
      "yatm_roller_bottom.png",
      "yatm_roller_side.error.png",
      "yatm_roller_side.error.png^[transformFX",
      "yatm_roller_back.error.png",
      "yatm_roller_front.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_roller_top.on.png",
      "yatm_roller_bottom.png",
      "yatm_roller_side.on.png",
      "yatm_roller_side.on.png^[transformFX",
      "yatm_roller_back.on.png",
      {
        name = "yatm_roller_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.25
        },
      },
    },
  }
})
