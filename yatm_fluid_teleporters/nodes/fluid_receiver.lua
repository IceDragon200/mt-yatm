--[[
Fluid Teleporters behave slightly different from pipes, they will have a 1-frame delay since they will
take fluids into their internal inventory, and then teleport them to a connected teleporter.

Like all other wireless devices, it has it's own address scheme and registration process.
]]
local SpacetimeNetwork = assert(yatm.spacetime.Network)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local SpacetimeMeta = assert(yatm.spacetime.SpacetimeMeta)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local YATM_NetworkMeta = assert(yatm.network)

local fluid_receiver_yatm_network = {
  kind = "machine",
  groups = {
    energy_consumer = 1,
  },
  states = {
    off = "yatm_fluid_teleporters:fluid_receiver_off",
    inactive = "yatm_fluid_teleporters:fluid_receiver_inactive",
    on = "yatm_fluid_teleporters:fluid_receiver_on",
    error = "yatm_fluid_teleporters:fluid_receiver_error",
    conflict = "yatm_fluid_teleporters:fluid_receiver_error",
  }
}

local function teleporter_after_place_node(pos, _placer, itemstack, _pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()
  SpacetimeMeta.copy_address(old_meta, new_meta)
  local address = SpacetimeMeta.patch_address(new_meta)

  local node = minetest.get_node(pos)
  SpacetimeNetwork:maybe_register_node(pos, node)

  yatm.devices.device_after_place_node(pos, placer, itemstack, pointed_thing)
  assert(yatm_core.trigger_refresh_infotext(pos))
end

local function teleporter_on_destruct(pos)
  yatm.devices.device_on_destruct(pos)
end

local function teleporter_after_destruct(pos, old_node)
  SpacetimeNetwork:unregister_device(pos, old_node)
  yatm.devices.device_after_destruct(pos, old_node)
end

local function teleporter_change_spacetime_address(pos, node, new_address)
  local meta = minetest.get_meta(pos)

  SpacetimeMeta.set_address(meta, new_address)
  SpacetimeNetwork:maybe_update_node(pos, node)

  local nodedef = minetest.registered_nodes[node.name]
  if yatm_core.is_blank(new_address) then
    node.name = fluid_receiver_yatm_network.states.off
    minetest.swap_node(pos, node)
  else
    node.name = fluid_receiver_yatm_network.states.on
    minetest.swap_node(pos, node)
  end
  assert(yatm_core.trigger_refresh_infotext(pos))
  return new_address
end

local fluid_interface = FluidInterface.new_simple("tank", 16000)

function fluid_interface:on_fluid_changed(pos, dir, _fluid_stack)
  assert(yatm_core.trigger_refresh_infotext(pos))
end

local function teleporter_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    "Net.ID: " .. YATM_NetworkMeta.to_infotext(meta) .. "\n" ..
    "S.Address: " .. SpacetimeMeta.to_infotext(meta) .. "\n" ..
    "Tank: " .. FluidMeta.to_infotext(meta, "tank", fluid_interface.capacity)

  meta:set_string("infotext", infotext)
end

local yatm_spacetime_device = {
  groups = {fluid_receiver = 1},
}

local groups = {
  cracky = 1,
  fluid_interface_out = 1,
  addressable_spacetime_device = 1,
}

yatm.devices.register_network_device(fluid_receiver_yatm_network.states.off, {
  description = "Fluid Receiver",
  drop = fluid_receiver_yatm_network.states.off,

  groups = groups,

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    "yatm_fluid_teleporter_top.receiver.off.png",
    "yatm_fluid_teleporter_top.receiver.off.png",
    "yatm_fluid_teleporter_side.receiver.off.png",
    "yatm_fluid_teleporter_side.receiver.off.png",
    "yatm_fluid_teleporter_side.receiver.off.png",
    "yatm_fluid_teleporter_side.receiver.off.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, -0.5, -0.5, 0.5, 0.375, 0.5}, -- NodeBox1
      {-0.375, 0.375, -0.375, 0.375, 0.5, 0.375}, -- NodeBox2
    }
  },

  fluid_interface = fluid_interface,

  yatm_network = fluid_receiver_yatm_network,
  yatm_spacetime = yatm_spacetime_device,

  on_destruct = teleporter_on_destruct,

  after_place_node = teleporter_after_place_node,
  after_destruct = teleporter_after_destruct,

  change_spacetime_address = teleporter_change_spacetime_address,

  refresh_infotext = teleporter_refresh_infotext,
})

yatm.devices.register_network_device(fluid_receiver_yatm_network.states.error, {
  description = "Fluid Receiver",
  drop = fluid_receiver_yatm_network.states.off,

  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    "yatm_fluid_teleporter_top.receiver.error.png",
    "yatm_fluid_teleporter_top.receiver.error.png",
    "yatm_fluid_teleporter_side.receiver.error.png",
    "yatm_fluid_teleporter_side.receiver.error.png",
    "yatm_fluid_teleporter_side.receiver.error.png",
    "yatm_fluid_teleporter_side.receiver.error.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, -0.5, -0.5, 0.5, 0.375, 0.5}, -- NodeBox1
      {-0.375, 0.375, -0.375, 0.375, 0.5, 0.375}, -- NodeBox2
    }
  },

  fluid_interface = fluid_interface,

  yatm_network = fluid_receiver_yatm_network,
  yatm_spacetime = yatm_spacetime_device,

  on_destruct = teleporter_on_destruct,

  after_place_node = teleporter_after_place_node,
  after_destruct = teleporter_after_destruct,

  change_spacetime_address = teleporter_change_spacetime_address,

  refresh_infotext = teleporter_refresh_infotext,
})

yatm.devices.register_network_device(fluid_receiver_yatm_network.states.on, {
  description = "Fluid Receiver",
  drop = fluid_receiver_yatm_network.states.off,

  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    "yatm_fluid_teleporter_top.receiver.on.png",
    "yatm_fluid_teleporter_top.receiver.on.png",
    "yatm_fluid_teleporter_side.receiver.on.png",
    "yatm_fluid_teleporter_side.receiver.on.png",
    "yatm_fluid_teleporter_side.receiver.on.png",
    "yatm_fluid_teleporter_side.receiver.on.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, -0.5, -0.5, 0.5, 0.375, 0.5}, -- NodeBox1
      {-0.375, 0.375, -0.375, 0.375, 0.5, 0.375}, -- NodeBox2
    }
  },

  fluid_interface = fluid_interface,

  yatm_network = fluid_receiver_yatm_network,
  yatm_spacetime = yatm_spacetime_device,


  after_place_node = teleporter_after_place_node,
  on_destruct = teleporter_on_destruct,
  after_destruct = teleporter_after_destruct,

  change_spacetime_address = teleporter_change_spacetime_address,

  refresh_infotext = teleporter_refresh_infotext,
})
