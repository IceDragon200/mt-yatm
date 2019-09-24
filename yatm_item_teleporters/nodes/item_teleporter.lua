--[[

  Item Teleporters behave slightly different from ducts, they will have a 1-frame delay since they will
  take items into their internal inventory, and then teleport them to a connected teleporter.

  Like all other wireless devices, it has it's own address scheme and registration process.

]]
local SpacetimeNetwork = assert(yatm.spacetime.Network)
local SpacetimeMeta = assert(yatm.spacetime.SpacetimeMeta)
local YATM_NetworkMeta = assert(yatm.network)
local Energy = assert(yatm.energy)
local ItemInterface = assert(yatm.items.ItemInterface)
local ItemDevice = assert(yatm.items.ItemDevice)

local item_interface = ItemInterface.new_simple("main")

local function item_teleporter_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local stack = inv:get_stack("main", 1)

  local infotext =
    "Net.ID: " .. YATM_NetworkMeta.to_infotext(meta) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "S.Address: " .. SpacetimeMeta.to_infotext(meta) .. "\n" ..
    "Item: " .. yatm_core.itemstack_inspect(stack)

  meta:set_string("infotext", infotext)
end

local item_teleporter_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    off = "yatm_item_teleporters:item_teleporter_off",
    on = "yatm_item_teleporters:item_teleporter_on",
    error = "yatm_item_teleporters:item_teleporter_error",
    conflict = "yatm_item_teleporters:item_teleporter_error",
  },
  energy = {
    passive_lost = 0,
    network_charge_bandwidth = 200,
    capacity = 10000,
    startup_threshold = 100,
  },
}

function item_teleporter_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  local energy_consumed = 0
  local meta = minetest.get_meta(pos)
  local address = SpacetimeMeta.get_address(meta)

  if not yatm_core.is_blank(address) then
    local inv = meta:get_inventory()

    local stack = inv:get_stack("main", 1)

    if not yatm_core.itemstack_is_blank(stack) then
      SpacetimeNetwork:each_member_in_group_by_address("item_receiver", address, function (sp_hash, member)
        local remaining_stack, error_message = ItemDevice.insert_item(member.pos, yatm_core.D_NONE, stack, true)
        if not error_message then
          -- TODO: improve upon this, it should check if the stack was
          --       was actually consumed
          energy_consumed = energy_consumed + 10
        end
        stack = remaining_stack
        return not yatm_core.itemstack_is_blank(stack)
      end)
    end

    inv:set_stack("main", 1, stack)
  end
  return energy_consumed
end

local function teleporter_after_place_node(pos, _placer, itemstack, _pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()
  SpacetimeMeta.copy_address(old_meta, new_meta)
  local address = SpacetimeMeta.patch_address(new_meta)

  local node = minetest.get_node(pos)
  SpacetimeNetwork:maybe_register_node(pos, node)

  yatm.devices.device_after_place_node(pos, placer, itemstack, pointed_thing)
  assert(yatm_core.queue_refresh_infotext(pos))
end

local function teleporter_on_construct(pos)
  yatm.devices.device_on_construct(pos)

  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  inv:set_size("main", 1)
end

local function teleporter_on_destruct(pos)
  yatm.devices.device_on_destruct(pos)
end

local function teleporter_after_destruct(pos, old_node)
  SpacetimeNetwork:unregister_device(pos, old_node)
  yatm.devices.device_after_destruct(pos, old_node)
end

local function item_teleporter_change_spacetime_address(pos, node, new_address)
  local meta = minetest.get_meta(pos)

  SpacetimeMeta.set_address(meta, new_address)
  SpacetimeNetwork:maybe_update_node(pos, node)

  local nodedef = minetest.registered_nodes[node.name]
  if yatm_core.is_blank(new_address) then
    node.name = item_teleporter_yatm_network.states.off
    minetest.swap_node(pos, node)
  else
    node.name = item_teleporter_yatm_network.states.on
    minetest.swap_node(pos, node)
  end
  assert(yatm_core.queue_refresh_infotext(pos))
  return new_address
end

local teleporter_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, 0.375, 0.5}, -- NodeBox1
    {-0.375, 0.375, -0.375, 0.375, 0.5, 0.375}, -- NodeBox2
  }
}

local groups = {
  cracky = 1,
  item_interface_in = 1,
  addressable_spacetime_device = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Item Teleporter",
  drop = item_teleporter_yatm_network.states.off,

  groups = groups,

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_glass_defaults(),

  tiles = {
    "yatm_item_teleporter_top.teleporter.off.png",
    "yatm_item_teleporter_top.teleporter.off.png",
    "yatm_item_teleporter_side.teleporter.off.png",
    "yatm_item_teleporter_side.teleporter.off.png",
    "yatm_item_teleporter_side.teleporter.off.png",
    "yatm_item_teleporter_side.teleporter.off.png",
  },

  drawtype = "nodebox",
  node_box = teleporter_node_box,

  yatm_network = item_teleporter_yatm_network,
  yatm_spacetime = {
    groups = {item_teleporter = 1},
  },
  item_interface = item_interface,

  after_place_node = teleporter_after_place_node,

  on_construct = teleporter_on_construct,
  on_destruct = teleporter_on_destruct,
  after_destruct = teleporter_after_destruct,

  change_spacetime_address = item_teleporter_change_spacetime_address,

  refresh_infotext = item_teleporter_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_item_teleporter_top.teleporter.error.png",
      "yatm_item_teleporter_top.teleporter.error.png",
      "yatm_item_teleporter_side.teleporter.error.png",
      "yatm_item_teleporter_side.teleporter.error.png",
      "yatm_item_teleporter_side.teleporter.error.png",
      "yatm_item_teleporter_side.teleporter.error.png",
    }
  },
  on = {
    tiles = {
      "yatm_item_teleporter_top.teleporter.on.png",
      "yatm_item_teleporter_top.teleporter.on.png",
      "yatm_item_teleporter_side.teleporter.on.png",
      "yatm_item_teleporter_side.teleporter.on.png",
      "yatm_item_teleporter_side.teleporter.on.png",
      "yatm_item_teleporter_side.teleporter.on.png",
    },
  }
})
