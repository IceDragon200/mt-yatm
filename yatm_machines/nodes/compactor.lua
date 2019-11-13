local ItemInterface = assert(yatm.items.ItemInterface)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local compacting_registry = assert(yatm.compacting.compacting_registry)

local function get_compactor_formspec(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    "label[0,0;Compactor]" ..
    "list[nodemeta:" .. spos .. ";input_items;0,0.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";processing_items;2,0.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";output_items;4,0.3;2,2;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";input_items]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";output_items]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)
  return formspec
end

local function compactor_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Recipe: " .. (meta:get_string("recipe_name") or "") .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local compactor_yatm_network = {
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
    --idle = "yatm_machines:compactor_idle",
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

function compactor_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local remaining_dtime = dtime

  local energy_used = 0
  while remaining_dtime > 0 and energy_used < energy_available do
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

      energy_to_use = math.min(energy_available - energy_used, used_time * 400)
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

local function compactor_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  inv:set_size("input_items", 1)
  inv:set_size("processing_items", 1)
  inv:set_size("output_items", 1)

  yatm.devices.device_on_construct(pos)
end

local function compactor_on_rightclick(pos, node, clicker, item_stack, pointed_thing)
  minetest.show_formspec(
    clicker:get_player_name(),
    "yatm_machines:compactor",
    get_compactor_formspec(pos)
  )
end

local compactor_item_interface =
  ItemInterface.new_directional(function (self, pos, dir)
    local node = minetest.get_node(pos)
    local new_dir = yatm_core.facedir_to_face(node.param2, dir)
    if new_dir == yatm_core.D_UP or new_dir == yatm_core.D_DOWN then
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
  basename = "yatm_machines:compactor",

  description = "Compactor",
  groups = groups,

  drop = compactor_yatm_network.states.off,

  tiles = {
    "yatm_compactor_top.off.png",
    "yatm_compactor_bottom.png",
    "yatm_compactor_side.off.png",
    "yatm_compactor_side.off.png^[transformFX",
    "yatm_compactor_back.off.png",
    "yatm_compactor_front.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = compactor_on_construct,
  on_rightclick = compactor_on_rightclick,

  yatm_network = compactor_yatm_network,

  item_interface = compactor_item_interface,

  refresh_infotext = compactor_refresh_infotext,
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
