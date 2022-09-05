local mod = yatm_machines
local Directions = assert(foundation.com.Directions)
local is_blank = assert(foundation.com.is_blank)
local itemstack_split = assert(foundation.com.itemstack_split)
local format_pretty_time = assert(foundation.com.format_pretty_time)
local cluster_devices = assert(yatm.cluster.devices)
local ItemInterface = assert(yatm.items.ItemInterface)
local Energy = assert(yatm.energy)
local grinding_registry = assert(yatm.grinding.grinding_registry)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)
local Vector3 = assert(foundation.com.Vector3)

local yatm_network = {
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
    idle = "yatm_machines:auto_grinder_idle",
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

function yatm_network:work(ctx)
  local pos = ctx.pos
  local meta = ctx.meta
  local node = ctx.node
  local dtime = ctx.dtime

  local inv = meta:get_inventory()

  local energy_consumed = 0

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
      ctx:set_up_state("on")
    else
      -- to idle
      yatm.devices.set_idle(meta, 1)
      ctx:set_up_state("idle")
    end
  else
    ctx:set_up_state("on")
    local work_time = meta:get_float("work_time")
    work_time = work_time - dtime
    if work_time > 0 then
      meta:set_float("work_time", work_time)
      -- should probably be optional
      yatm.queue_refresh_infotext(pos, node)
      energy_consumed = energy_consumed + 10
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

          meta:set_string("active_recipe", "")
          meta:set_string("error", "")
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

        meta:set_string("active_recipe", "")
        meta:set_string("error", "")
        meta:set_float("duration", 0)
        meta:set_float("work_time", 0)

        yatm.queue_refresh_infotext(pos, node)
      end
    end
  end

  return energy_consumed
end

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local recipe_name = meta:get_string("active_recipe") or ""
  local work_time = meta:get_float("work_time")
  local duration = meta:get_float("duration")

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Recipe: " .. recipe_name .. "\n" ..
    "Time: " .. format_pretty_time(work_time) .. " / " .. format_pretty_time(duration)

  meta:set_string("infotext", infotext)
end

local function on_construct(pos)
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

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(node_inv_name, "grinder_input", rect.x, rect.y, 1, 1) ..
        fspec.list(node_inv_name, "grinder_processing", rect.x + cio(2), rect.y, 1, 1) ..
        fspec.list(node_inv_name, "grinder_output", rect.x + cio(4), rect.y, 2, 2) ..
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
      return fspec.list_ring(node_inv_name, "grinder_input") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(node_inv_name, "grinder_output") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_machines:auto_grinder:"..Vector3.to_string(pos)
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

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  yatm_energy_device = 1,
  item_interface_in = 1,
  item_interface_out = 1,
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("auto_grinder"),

  basename = mod:make_name("auto_grinder"),

  description = mod.S("Auto Grinder"),

  groups = groups,

  drop = yatm_network.states.off,

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

  on_construct = on_construct,
  on_rightclick = on_rightclick,

  yatm_network = yatm_network,
  item_interface = item_interface,
  refresh_infotext = refresh_infotext,
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
  idle = {
    tiles = {
      "yatm_auto_grinder_top.idle.png",
      "yatm_auto_grinder_bottom.png",
      "yatm_auto_grinder_side.idle.png",
      "yatm_auto_grinder_side.idle.png^[transformFX",
      "yatm_auto_grinder_back.idle.png",
      "yatm_auto_grinder_front.idle.png",
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
