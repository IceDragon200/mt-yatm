local Energy = assert(yatm.energy)
local Network = assert(yatm.network)
local ItemInterface = assert(yatm.items.ItemInterface)

local item_replicator_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    creative_replicator = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_machines:item_replicator_error",
    conflict = "yatm_machines:item_replicator_error",
    off = "yatm_machines:item_replicator_off",
    on = "yatm_machines:item_replicator_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 100,
  },
}

local function get_item_replicator_formspec(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    "list[nodemeta:" .. spos .. ";input_slot;0,0.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";output_slot;2,0.3;1,1;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";input_slot]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";output_slot]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)
  return formspec
end

function item_replicator_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local stack = inv:get_stack("input_slot", 1)

  local infotext =
    "Network ID: " .. Network.to_infotext(meta) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Replicating: " .. yatm_core.itemstack_inspect(stack)

  meta:set_string("infotext", infotext)
end

function item_replicator_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  local energy_consumed = 0
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  local stack = inv:get_stack("input_slot", 1)
  if not yatm_core.itemstack_is_blank(stack) then
    local replicate_stack = stack:peek_item(1)
    if inv:room_for_item("output_slot", replicate_stack) then
      inv:add_item("output_slot", replicate_stack)
      energy_consumed = energy_consumed + 10
      yatm_core.queue_refresh_infotext(pos)
    else
      yatm.devices.set_idle(meta, 1)
      print("WARN", minetest.pos_to_string(pos), "No room for stack in output", yatm_core.itemstack_inspect(replicate_stack))
    end
  else
    yatm.devices.set_idle(meta, 2)
    print("WARN", minetest.pos_to_string(pos), "No stack to replicate")
  end
  return energy_consumed
end

local item_interface = ItemInterface.new_simple("output_slot")

local groups = {
  cracky = 1,
  yatm_energy_device = 1,
  item_interface_out = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Item Replicator",

  groups = groups,

  tiles = {
    "yatm_item_replicator_top.off.png",
    "yatm_item_replicator_bottom.png",
    "yatm_item_replicator_side.off.png",
    "yatm_item_replicator_side.off.png^[transformFX",
    "yatm_item_replicator_back.off.png",
    "yatm_item_replicator_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = item_replicator_yatm_network,
  item_interface = item_interface,

  refresh_infotext = item_replicator_refresh_infotext,

  on_construct = function (pos)
    yatm.devices.device_on_construct(pos)

    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    inv:set_size("input_slot", 1)
    inv:set_size("output_slot", 1)
  end,

  on_rightclick = function (pos, node, clicker)
    minetest.show_formspec(
      clicker:get_player_name(),
      "yatm_machines:item_replicator",
      get_item_replicator_formspec(pos)
    )
  end,
}, {
  error = {
    tiles = {
      "yatm_item_replicator_top.error.png",
      "yatm_item_replicator_bottom.png",
      "yatm_item_replicator_side.error.png",
      "yatm_item_replicator_side.error.png^[transformFX",
      "yatm_item_replicator_back.error.png",
      "yatm_item_replicator_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_item_replicator_top.on.png",
      "yatm_item_replicator_bottom.png",
      "yatm_item_replicator_side.on.png",
      "yatm_item_replicator_side.on.png^[transformFX",
      {
        name = "yatm_item_replicator_back.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      {
        name = "yatm_item_replicator_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
    },
  },
})
