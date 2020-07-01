--[[
Fluid Teleporters behave slightly different from pipes, they will have a 1-frame delay since they will
take fluids into their internal inventory, and then teleport them to a connected teleporter.

Like all other wireless devices, it has it's own address scheme and registration process.
]]
local cluster_devices = assert(yatm.cluster.devices)
local SpacetimeNetwork = assert(yatm.spacetime.network)
local SpacetimeMeta = assert(yatm.spacetime.SpacetimeMeta)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local Energy = assert(yatm.energy)

local fluid_interface = FluidInterface.new_simple("tank", 16000)

function fluid_interface:on_fluid_changed(pos, dir, _fluid_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

local function fluid_teleporter_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "S.Address: " .. SpacetimeMeta.to_infotext(meta) .. "\n" ..
    "Tank: " .. FluidMeta.to_infotext(meta, "tank", fluid_interface.capacity)

  meta:set_string("infotext", infotext)
end

local fluid_teleporter_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    off = "yatm_fluid_teleporters:fluid_teleporter_off",
    on = "yatm_fluid_teleporters:fluid_teleporter_on",
    error = "yatm_fluid_teleporters:fluid_teleporter_error",
    conflict = "yatm_fluid_teleporters:fluid_teleporter_error",
  },
  energy = {
    passive_lost = 0,
    network_charge_bandwidth = 200,
    capacity = 10000,
    startup_threshold = 100,
  },
}

function fluid_teleporter_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  local energy_consumed = 0
  local meta = minetest.get_meta(pos)
  local address = SpacetimeMeta.get_address(meta)

  if not yatm_core.is_blank(address) then
    local wildcard_stack = FluidStack.new_wildcard(1000)
    local fluid_stack = FluidMeta.drain_fluid(meta, "tank",
      wildcard_stack, fluid_interface.capacity, fluid_interface.capacity,
      false)

    if fluid_stack and fluid_stack.amount > 0 then
      local remaining_stack = FluidStack.copy(fluid_stack)

      SpacetimeNetwork:each_member_in_group_by_address("fluid_receiver", address, function (sp_hash, member)
        local filled_stack, error_message = FluidTanks.fill_fluid(member.pos, yatm_core.D_NONE, remaining_stack, true)
        if filled_stack and filled_stack.amount > 0 then
          remaining_stack.amount = remaining_stack.amount - filled_stack.amount
        end
        return remaining_stack.amount > 0
      end)

      local drained_stack = FluidStack.set_amount(fluid_stack, fluid_stack.amount - remaining_stack.amount)
      local actual_drained = FluidMeta.drain_fluid(meta, "tank", drained_stack, fluid_interface.capacity, fluid_interface.capacity, true)
      if actual_drained and actual_drained.amount > 0 then
        energy_consumed = energy_consumed + actual_drained.amount / 10
        yatm.queue_refresh_infotext(pos, node)
      end
    end
  end
  return energy_consumed
end

local function fluid_teleporter_after_place_node(pos, _placer, itemstack, _pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()
  SpacetimeMeta.copy_address(old_meta, new_meta)
  local address = SpacetimeMeta.patch_address(new_meta)

  local node = minetest.get_node(pos)
  SpacetimeNetwork:maybe_register_node(pos, node)

  yatm.devices.device_after_place_node(pos, placer, itemstack, pointed_thing)
  assert(yatm.queue_refresh_infotext(pos))
end

local function fluid_teleporter_on_destruct(pos)
  yatm.devices.device_on_destruct(pos)
end

local function fluid_teleporter_after_destruct(pos, old_node)
  SpacetimeNetwork:unregister_device(pos, old_node)
  yatm.devices.device_after_destruct(pos, old_node)
end

local function fluid_teleporter_change_spacetime_address(pos, node, new_address)
  local meta = minetest.get_meta(pos)

  SpacetimeMeta.set_address(meta, new_address)
  SpacetimeNetwork:maybe_update_node(pos, node)

  local nodedef = minetest.registered_nodes[node.name]
  if yatm_core.is_blank(new_address) then
    node.name = fluid_teleporter_yatm_network.states.off
    minetest.swap_node(pos, node)
  else
    node.name = fluid_teleporter_yatm_network.states.on
    minetest.swap_node(pos, node)
  end
  yatm.queue_refresh_infotext(pos, node)
  return new_address
end

local node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, 0.375, 0.5}, -- NodeBox1
    {-0.375, 0.375, -0.375, 0.375, 0.5, 0.375}, -- NodeBox2
  }
}

local groups = {
  cracky = 1,
  fluid_interface_in = 1,
  addressable_spacetime_device = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_fluid_teleporters:fluid_teleporter",

  description = "Fluid Teleporter",

  codex_entry_id = "yatm_fluid_teleporters:fluid_teleporter",

  drop = fluid_teleporter_yatm_network.states.off,

  groups = groups,

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  tiles = {
    "yatm_fluid_teleporter_top.teleporter.off.png",
    "yatm_fluid_teleporter_top.teleporter.off.png",
    "yatm_fluid_teleporter_side.teleporter.off.png",
    "yatm_fluid_teleporter_side.teleporter.off.png",
    "yatm_fluid_teleporter_side.teleporter.off.png",
    "yatm_fluid_teleporter_side.teleporter.off.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  fluid_interface = fluid_interface,

  yatm_network = fluid_teleporter_yatm_network,
  yatm_spacetime = {
    groups = {fluid_teleporter = 1},
  },

  after_place_node = fluid_teleporter_after_place_node,
  on_destruct = fluid_teleporter_on_destruct,
  after_destruct = fluid_teleporter_after_destruct,

  change_spacetime_address = fluid_teleporter_change_spacetime_address,

  refresh_infotext = fluid_teleporter_refresh_infotext,
}, {
  on = {
    tiles = {
      "yatm_fluid_teleporter_top.teleporter.on.png",
      "yatm_fluid_teleporter_top.teleporter.on.png",
      "yatm_fluid_teleporter_side.teleporter.on.png",
      "yatm_fluid_teleporter_side.teleporter.on.png",
      "yatm_fluid_teleporter_side.teleporter.on.png",
      "yatm_fluid_teleporter_side.teleporter.on.png",
    },
  },
  error = {
    tiles = {
      "yatm_fluid_teleporter_top.teleporter.error.png",
      "yatm_fluid_teleporter_top.teleporter.error.png",
      "yatm_fluid_teleporter_side.teleporter.error.png",
      "yatm_fluid_teleporter_side.teleporter.error.png",
      "yatm_fluid_teleporter_side.teleporter.error.png",
      "yatm_fluid_teleporter_side.teleporter.error.png",
    }
  },
})
