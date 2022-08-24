local mod = yatm_machines
local Directions = assert(foundation.com.Directions)
local ItemInterface = assert(yatm.items.ItemInterface)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local compacting_registry = assert(yatm.compacting.compacting_registry)
local fspec = assert(foundation.com.formspec.api)
local energy_fspec = assert(yatm.energy.formspec)
local player_service = assert(nokore.player_service)
local Vector3 = assert(foundation.com.Vector3)

local device_get_node_infotext = assert(cluster_devices.get_node_infotext)
local energy_get_node_infotext = assert(cluster_energy.get_node_infotext)
local energy_meta_to_infotext = assert(Energy.meta_to_infotext)

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    device_get_node_infotext(cluster_devices, pos) .. "\n" ..
    energy_get_node_infotext(cluster_energy, pos) .. "\n" ..
    "Recipe: " .. (meta:get_string("recipe_name") or "") .. "\n" ..
    "Energy: " .. energy_meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1, -- the device should be updated every network step
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:compactor_error",
    error = "yatm_machines:compactor_error",
    off = "yatm_machines:compactor_off",
    on = "yatm_machines:compactor_on",
    idle = "yatm_machines:compactor_idle",
  },
  energy = {
    -- compactors require a lot of energy and have a small capacity
    capacity = 20 * 60 * 10,
    passive_lost = 0,
    startup_threshold = 600,
    work_rate_threshold = 600,
    work_bandwidth = 100,
    network_charge_bandwidth = 1000,
  },
}

function yatm_network:work(ctx)
  local pos = ctx.pos
  local meta = ctx.meta
  local node = ctx.node
  local dtime = ctx.dtime

  local available_energy = ctx.available_energy

  local inv = meta:get_inventory()

  local remaining_dtime = dtime

  local energy_used = 0
  while remaining_dtime > 0 and energy_used < available_energy do
    local processing_item = inv:get_stack("processing_items", 1)
    if processing_item:is_empty() then
      local input_item = inv:get_stack("input_items", 1)

      if input_item:is_empty() then
        -- go idle
        yatm.devices.set_idle(meta, 1)
        break
      else
        local recipe = compacting_registry:find_compacting_recipe(input_item)
        if recipe then
          local stack = input_item:peek_item(recipe.input_item_stack:get_count())
          inv:add_item("processing_items", stack)
          inv:remove_item("input_items", stack)
          meta:set_string("recipe_name", recipe.name)
          meta:set_float("time", recipe.duration)
          meta:set_float("duration", recipe.duration)
        else
          yatm.devices.set_idle(meta, 1)
          break
        end
      end
    end

    local processing_item = inv:get_stack("processing_items", 1)
    if processing_item:is_empty() then
      -- no item to process
      break
    else
      local time = meta:get_float("time")
      local used_time = math.min(time, remaining_dtime)

      local energy_to_use = math.min(available_energy - energy_used, used_time * 400)
      used_time = energy_to_use / 400
      energy_used = energy_used + energy_to_use

      remaining_dtime = remaining_dtime - used_time
      time = math.max(time - used_time * work_rate, 0)
      meta:set_float("time", time)

      if time == 0 then
        local recipe = compacting_registry:find_compacting_recipe(processing_item)

        if recipe then
          if inv:room_for_item("output_items", recipe.output_item_stack) then
            meta:set_string("recipe_name", "")
            meta:set_float("time", -1)
            meta:set_float("duration", -1)

            inv:remove_item("processing_items", processing_item)
            inv:add_item("output_items", recipe.output_item_stack)
          else
            -- Jammed, wait a second and then try again later
            yatm.devices.set_idle(meta, 1)
            break
          end
        else
          meta:set_string("recipe_name", "")
          meta:set_float("time", -1)
          meta:set_float("duration", -1)
          if inv:room_for_item("input_items", processing_item) then
            -- refund
            inv:add_item("input_items", processing_item)
            inv:remove_item("processing_items", processing_item)
          else
            -- drop it
            inv:remove_item("processing_items", processing_item)
            minetest.add_item(pos, processing_item)
          end
        end
      else
        -- busy, stop looping now
        break
      end
    end
  end

  return energy_used
end

local function maybe_initialize_inventory(meta)
  local inv = meta:get_inventory()

  inv:set_size("input_items", 4)
  inv:set_size("processing_items", 4)
  inv:set_size("output_items", 1)
end

local function on_construct(pos)
  yatm.devices.device_on_construct(pos)

  local meta = minetest.get_meta(pos)

  maybe_initialize_inventory(meta)
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(node_inv_name, "input_items", rect.x + cio(2), rect.y, 4, 1) ..
        fspec.list(node_inv_name, "processing_items", rect.x + cio(2), rect.y + cio(1.5), 4, 1) ..
        fspec.list(node_inv_name, "output_items", rect.x + cio(3.5), rect.y + cio(3), 1, 1) ..
        energy_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cio(1),
          rect.y,
          1,
          rect.h,
          meta,
          yatm.devices.ENERGY_BUFFER_KEY,
          yatm.devices.get_energy_capacity(pos, state.node)
        )
    elseif loc == "footer" then
      return fspec.list_ring(node_inv_name, "input_items") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(node_inv_name, "output_items") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_machines:compactor:"..Vector3.to_string(pos)
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
  local meta = minetest.get_meta(pos)

  maybe_initialize_inventory(meta)

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

local item_interface =
  ItemInterface.new_directional(function (self, pos, dir)
    local node = minetest.get_node(pos)
    local new_dir = Directions.facedir_to_face(node.param2, dir)
    if new_dir == Directions.D_UP or new_dir == Directions.D_DOWN then
      return "output_items"
    end
    return "input_items"
  end)

local groups = {
  cracky = 1,
  yatm_energy_device = 1,
  item_interface_in = 1,
  item_interface_out = 1,
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("compactor"),

  basename = mod:make_name("compactor"),

  description = mod.S("Compactor"),
  groups = groups,

  drop = yatm_network.states.off,

  tiles = {
    "yatm_compactor_top.off.png",
    "yatm_compactor_bottom.png",
    "yatm_compactor_side.off.png",
    "yatm_compactor_side.off.png^[transformFX",
    "yatm_compactor_back.off.png",
    "yatm_compactor_front.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  on_construct = on_construct,
  on_rightclick = on_rightclick,

  yatm_network = yatm_network,

  item_interface = item_interface,

  refresh_infotext = refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_compactor_top.error.png",
      "yatm_compactor_bottom.png",
      "yatm_compactor_side.error.png",
      "yatm_compactor_side.error.png^[transformFX",
      "yatm_compactor_back.error.png",
      "yatm_compactor_front.error.png",
    },
  },

  idle = {
    tiles = {
      "yatm_compactor_top.idle.png",
      "yatm_compactor_bottom.png",
      "yatm_compactor_side.idle.png",
      "yatm_compactor_side.idle.png^[transformFX",
      "yatm_compactor_back.idle.png",
      "yatm_compactor_front.idle.png",
    },
  },

  on = {
    tiles = {
      "yatm_compactor_top.on.png",
      "yatm_compactor_bottom.png",
      --"yatm_compactor_side.on.png",
      --"yatm_compactor_side.on.png",
      {
        name = "yatm_compactor_side.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 4.0
        },
      },
      {
        name = "yatm_compactor_side.on.png^[transformFX",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 4.0
        },
      },
      "yatm_compactor_back.on.png",
      {
        name = "yatm_compactor_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      }
    },
  }
})
