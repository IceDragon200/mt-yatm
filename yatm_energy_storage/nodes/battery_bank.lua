--
-- The battery bank acts as a both an energy storage unit and battery charger!
-- Charge up any batteries
--
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local EnergyDevices = assert(yatm.energy.EnergyDevices)

local function num_round(value)
  local d = value - math.floor(value)
  if d > 0.5 then
    return math.ceil(value)
  else
    return math.floor(value)
  end
end

local mode_to_index = {
  none = 1,
  i = 2,
  o = 3,
  io = 4
}

local function get_battery_bank_formspec(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local meta = minetest.get_meta(pos)
  local mode = meta:get_string("mode")
  local formspec =
    "size[8,9]" ..
    "label[0,0;Battery Bank]" ..
    "list[nodemeta:" .. spos .. ";batteries;0,0.5;4,4;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";batteries]" ..
    "listring[current_player;main]" ..
    "dropdown[4,0.5;4,1;mode;none,i,o,io;" .. (mode_to_index[mode] or 1) .. "]" ..
    default.get_hotbar_bg(0,4.85)

  return formspec
end

local function battery_bank_on_receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)

  if fields["mode"] then
    meta:set_string("mode", fields["mode"])
  end

  return true
end

local function battery_bank_refresh_infotext(pos)
  -- despite this saying infotext, it can also be used to refresh the node state
  -- no hard or fast rules here

  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  local capacity = meta:get_int("energy_capacity")
  local energy = meta:get_int("energy")

  local usable = EnergyDevices.get_usable_stored_energy(pos, node)

  local intended_state = meta:get_string("network_state")

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.format_string(energy, capacity) .. "\n" ..
    "Usable Energy: " .. tostring(usable)

  meta:set_string("infotext", infotext)


  local i = 0

  if capacity > 0 then
    i = math.min(math.max(num_round(4 * energy / capacity), 0), 4)
  end

  local new_node_name
  if intended_state == "down" then
    -- Ignore it
    --new_node_name = nodedef.yatm_network.states.off
    new_node_name = nodedef.yatm_network.states.off
  elseif intended_state == "up" then
    new_node_name = nodedef.yatm_network.states["on" .. i]
  elseif intended_state == "conflict" then
    new_node_name = nodedef.yatm_network.states["error" .. i]
  end

  if new_node_name then
    if node.name ~= new_node_name then
      node.name = new_node_name

      minetest.swap_node(pos, node)

      cluster_devices:schedule_update_node(pos, node)
      cluster_energy:schedule_update_node(pos, node)
    end
  end
end

local battery_bank_yatm_network = {
  kind = "energy_storage",

  groups = {
    device_controller = 2,
    energy_storage = 1,
    energy_receiver = 1,
  },

  default_state = "off",
  states = {
    off = "yatm_energy_storage:battery_bank_off",
    error0 = "yatm_energy_storage:battery_bank_error0",
    error1 = "yatm_energy_storage:battery_bank_error1",
    error2 = "yatm_energy_storage:battery_bank_error2",
    error3 = "yatm_energy_storage:battery_bank_error3",
    error4 = "yatm_energy_storage:battery_bank_error4",
    on0 = "yatm_energy_storage:battery_bank_on0",
    on1 = "yatm_energy_storage:battery_bank_on1",
    on2 = "yatm_energy_storage:battery_bank_on2",
    on3 = "yatm_energy_storage:battery_bank_on3",
    on4 = "yatm_energy_storage:battery_bank_on4",
  },

  energy = {
  },
}

local function refresh_battery_bank_capacity(pos)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)

  local inv = meta:get_inventory()
  local size = inv:get_size("batteries")

  local capacity = 0

  for i = 1,size do
    local stack = inv:get_stack("batteries", i)

    if not stack:is_empty() then
      local en = stack:get_definition().energy
      if en then
        capacity = capacity + en.get_capacity(stack)
      end
    end
  end

  meta:set_int("energy_capacity", capacity)

  yatm.queue_refresh_infotext(pos, node)
end

function battery_bank_yatm_network.energy.capacity(pos, node)
  local meta = minetest.get_meta(pos)

  -- this value gets refreshed when the inventory changes and it rescans
  return meta:get_int("energy_capacity")
end

function battery_bank_yatm_network.energy.receive_energy(pos, node, energy_left, dtime, ot)
  local meta = minetest.get_meta(pos)
  local mode = meta:get_string("mode")

  print("receive_energy", minetest.pos_to_string(pos), node.name, energy_left, dtime, ot, mode)

  if mode == "io" or mode == "i" then
    local inv = meta:get_inventory()
    local left = energy_left

    local new_energy = 0

    local size = inv:get_size("batteries")
    for i = 1,size do
      local stack = inv:get_stack("batteries", i)
      if not stack:is_empty() then
        local en = stack:get_definition().energy
        if en then
          if left > 0 then
            local used = en.receive_energy(stack, left)
            left = left - used

            inv:set_stack("batteries", i, stack)
          end

          new_energy = new_energy + en.get_stored_energy(stack)
        end
      end
    end

    print("new_energy", new_energy)
    meta:set_int("energy", new_energy)

    yatm.queue_refresh_infotext(pos, node)

    return energy_left - left
  end
  return 0
end

function battery_bank_yatm_network.energy.get_usable_stored_energy(pos, node)
  local meta = minetest.get_meta(pos)
  local mode = meta:get_string("mode")
  if mode == "io" or mode == "o" then
    return meta:get_int("energy")
  end
  return 0
end

function battery_bank_yatm_network.energy.use_stored_energy(pos, node, energy_to_use)
  local meta = minetest.get_meta(pos)
  local mode = meta:get_string("mode")

  print("use_stored_energy", minetest.pos_to_string(pos), node.name, energy_to_use, mode)

  if mode == "io" or mode == "o" then
    local inv = meta:get_inventory()

    local left = energy_to_use
    local new_energy = 0

    local size = inv:get_size("batteries")
    for i = 1,size do
      local stack = inv:get_stack("batteries", i)
      local en = stack:get_definition().energy
      if en then
        if left > 0 then
          local consumed = en.consume_energy(stack, left)
          left = left - used

          inv:set_stack("batteries", i, stack)
        end

        new_energy = new_energy + en.get_stored_energy(stack)
      end
    end

    print("new_energy", new_energy)

    meta:set_int("energy", new_energy)

    yatm.queue_refresh_infotext(pos, node)

    return energy_to_use - left
  end
  return 0
end

local function battery_bank_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  inv:set_size("batteries", 16)

  meta:set_string("mode", "io")

  yatm.devices.device_on_construct(pos)
end

local function battery_bank_on_rightclick(pos, node, clicker)
  local formspec_name = "yatm_energy_storage:battery_bank:" .. minetest.pos_to_string(pos)
  yatm_core.bind_on_player_receive_fields(formspec_name,
                                          { pos = pos, node = node },
                                          battery_bank_on_receive_fields)

  minetest.show_formspec(
    clicker:get_player_name(),
    formspec_name,
    get_battery_bank_formspec(pos)
  )
end

local function battery_bank_on_dig(pos, node, digger)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  if inv:is_empty("batteries") then
    return minetest.node_dig(pos, node, digger)
  end

  return false
end

local function battery_bank_transition_device_state(pos, node, state)
  local meta = minetest.get_meta(pos)
  meta:set_string("network_state", state)
  yatm.queue_refresh_infotext(pos, node)
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  if to_list == "batteries" then
    return 1
  else
    return count
  end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "batteries" then
    if yatm_core.groups.has_group(stack:get_definition(), "battery") then
      return 1
    end
  end
  return 0
end

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  if listname == "batteries" then
    refresh_battery_bank_capacity(pos)
  end
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "batteries" then
    refresh_battery_bank_capacity(pos)
  end
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "batteries" then
    refresh_battery_bank_capacity(pos)
  end
end

local sub_states = {}

for i = 0,4 do
  sub_states["error" .. i] = {
    tiles = {
      "yatm_battery_bank_top.error.png",
      "yatm_battery_bank_bottom.png",
      "yatm_battery_bank_side.png",
      "yatm_battery_bank_side.png^[transformFX",
      "yatm_battery_bank_back.level." .. i .. ".png",
      "yatm_battery_bank_front.level." .. i .. ".png"
    },
  }

  sub_states["on" .. i] = {
    tiles = {
      -- "yatm_battery_bank_top.on.png",
      {
        name = "yatm_battery_bank_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
      "yatm_battery_bank_bottom.png",
      "yatm_battery_bank_side.png",
      "yatm_battery_bank_side.png^[transformFX",
      "yatm_battery_bank_back.level." .. i .. ".png",
      "yatm_battery_bank_front.level."  .. i .. ".png"
    },
  }
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_energy_storage:battery_bank",

  description = "Battery Bank",

  groups = {
    cracky = 1,
    yatm_energy_device = 1,
  },

  drop = battery_bank_yatm_network.states.off,

  sounds = default.node_sound_metal_defaults(),

  tiles = {
    "yatm_battery_bank_top.off.png",
    "yatm_battery_bank_bottom.png",
    "yatm_battery_bank_side.png",
    "yatm_battery_bank_side.png^[transformFX",
    "yatm_battery_bank_back.level.0.png",
    "yatm_battery_bank_front.level.0.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = battery_bank_on_construct,
  on_rightclick = battery_bank_on_rightclick,
  on_dig = battery_bank_on_dig,

  allow_metadata_inventory_move = allow_metadata_inventory_move,
  allow_metadata_inventory_put = allow_metadata_inventory_put,

  on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,

  yatm_network = battery_bank_yatm_network,

  refresh_infotext = battery_bank_refresh_infotext,
  transition_device_state = battery_bank_transition_device_state,
}, sub_states)
