--
-- The Roller, or Metal Former, takes various metals or plates and forms them into other shapes.
--
local mod = yatm_machines
local Directions = assert(foundation.com.Directions)
local is_blank = assert(foundation.com.is_blank)
local itemstack_is_blank = assert(foundation.com.itemstack_is_blank)
local format_pretty_time = assert(foundation.com.format_pretty_time)
local metaref_dec_float = assert(foundation.com.metaref_dec_float)
local cluster_devices = assert(yatm.cluster.devices)
local Energy = assert(yatm.energy)
local ItemInterface = assert(yatm.items.ItemInterface)
local rolling_registry = assert(yatm.rolling.rolling_registry)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

local device_get_node_infotext = assert(cluster_devices.get_node_infotext)
local energy_meta_to_infotext = assert(Energy.meta_to_infotext)

local function on_construct(pos)
  yatm.devices.device_on_construct(pos)

  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  inv:set_size("roller_input", 1)
  inv:set_size("roller_processing", 1)
  inv:set_size("roller_output", 1)
end

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local recipe_time = meta:get_float("recipe_time")
  local recipe_time_max = meta:get_float("recipe_time_max")

  local infotext =
    device_get_node_infotext(cluster_devices, pos) .. "\n" ..
    "Energy: " .. energy_meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Time Remaining: " .. format_pretty_time(recipe_time) .. " / " .. format_pretty_time(recipe_time_max)

  meta:set_string("infotext", infotext)
end

local yatm_network = {
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

function yatm_network:work(ctx)
  local pos = ctx.pos
  local node = ctx.node
  local meta = ctx.meta
  local dtime = ctx.dtime

  local energy_consumed = 0
  local inv = meta:get_inventory()

  do
    local processing_stack = inv:get_stack("roller_processing", 1)
    if itemstack_is_blank(processing_stack) then
      local input_stack = inv:get_stack("roller_input", 1)
      if not itemstack_is_blank(input_stack) then
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
    if not itemstack_is_blank(processing_stack) then
      if metaref_dec_float(meta, "recipe_time", dtime) <= 0 then
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
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_UP or new_dir == Directions.D_DOWN then
    return "roller_output"
  end
  return "roller_input"
end)

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(node_inv_name, "roller_input", rect.x, rect.y, 1, 1) ..
        fspec.list(node_inv_name, "roller_processing", rect.x + cio(2), rect.y, 1, 1) ..
        fspec.list(node_inv_name, "roller_output", rect.x + cio(4), rect.y, 1, 1) ..
        yatm_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cio(1),
          rect.y,
          1,
          rect.h,
          meta,
          yatm.devices.ENERGY_BUFFER_KEY,
          yatm.devices.get_energy_capacity(pos, state.node)
        )
    elseif loc == "footer" then
      return fspec.list_ring(node_inv_name, "roller_input") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(node_inv_name, "roller_output") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_machines:roller:"..Vector3.to_string(pos)
end

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, user)
  local state = {
    pos = pos,
    node = node,
  }
  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
      timers = {
        -- routinely update the formspec
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
end

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("roller"),

  basename = mod:make_name("roller"),

  description = mod.S("Roller"),

  groups = {
    cracky = 1,
    item_interface_in = 1,
    item_interface_out = 1,
    yatm_energy_device = 1,
  },
  drop = yatm_network.states.off,

  sounds = yatm.node_sounds:build("metal"),

  tiles = {
    "yatm_roller_top.off.png",
    "yatm_roller_bottom.png",
    "yatm_roller_side.off.png",
    "yatm_roller_side.off.png^[transformFX",
    "yatm_roller_back.off.png",
    "yatm_roller_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  on_construct = on_construct,

  on_rightclick = on_rightclick,

  can_dig = function (pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    return inv:is_empty("roller_input") and
      inv:is_empty("roller_processing") and
      inv:is_empty("roller_output")
  end,

  yatm_network = yatm_network,

  item_interface = item_interface,

  refresh_infotext = refresh_infotext,
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
