local itemstack_inspect = assert(foundation.com.itemstack_inspect)
local itemstack_is_blank = assert(foundation.com.itemstack_is_blank)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
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

local function get_item_replicator_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "machine") ..
    "list[nodemeta:" .. spos .. ";input_slot;0,0.3;1,1;]" ..
    "list[nodemeta:" .. spos .. ";output_slot;2,0.3;1,1;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";input_slot]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";output_slot]" ..
    "listring[current_player;main]"

  return formspec
end

function item_replicator_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local stack = inv:get_stack("input_slot", 1)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Replicating: " .. itemstack_inspect(stack)

  meta:set_string("infotext", infotext)
end

function item_replicator_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  local energy_consumed = 0
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  local stack = inv:get_stack("input_slot", 1)
  if not itemstack_is_blank(stack) then
    local replicate_stack = stack:peek_item(1)
    if inv:room_for_item("output_slot", replicate_stack) then
      inv:add_item("output_slot", replicate_stack)
      energy_consumed = energy_consumed + 10
      yatm.queue_refresh_infotext(pos, node)
    else
      yatm.devices.set_idle(meta, 1)
      --print("WARN", minetest.pos_to_string(pos), "No room for stack in output", itemstack_inspect(replicate_stack))
    end
  else
    yatm.devices.set_idle(meta, 1)
    --print("WARN", minetest.pos_to_string(pos), "No stack to replicate")
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
  basename = "yatm_machines:item_replicator",

  description = "Item Replicator",

  drop = item_replicator_yatm_network.states.off,

  groups = groups,

  tiles = {
    "yatm_item_replicator_top.off.png",
    "yatm_item_replicator_bottom.png",
    "yatm_item_replicator_side.off.png",
    "yatm_item_replicator_side.off.png^[transformFX",
    "yatm_item_replicator_back.off.png",
    "yatm_item_replicator_front.off.png",
  },
  paramtype = "none",
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

  on_rightclick = function (pos, node, user)
    minetest.show_formspec(
      user:get_player_name(),
      "yatm_machines:item_replicator",
      get_item_replicator_formspec(pos, user)
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
