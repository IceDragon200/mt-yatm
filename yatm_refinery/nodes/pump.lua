local FluidStack = assert(yatm.fluids.FluidStack)
local FluidRegistry = assert(yatm.fluids.FluidRegistry)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local Network = assert(yatm.network)

local pump_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_refinery:pump_error",
    error = "yatm_refinery:pump_error",
    off = "yatm_refinery:pump_off",
    on = "yatm_refinery:pump_on",
  },
  passive_energy_lost = 0
}

local fluid_interface = yatm.fluids.FluidInterface.new_simple("tank", 16000)

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  pump_yatm_network.refresh_infotext(pos, nil, minetest.get_meta(pos), { cause = "fluid_changed" })
end

function pump_yatm_network.refresh_infotext(pos, _node, _meta, event)
  local new_node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[new_node.name]
  local meta = minetest.get_meta(pos)
  local state = nodedef.yatm_network.state
  local network_id = Network.get_meta_network_id(meta)
  local fluid_stack = FluidMeta.get_fluid(meta, nodedef.fluid_interface.tank_name)
  meta:set_string("infotext",
    "Network ID <" .. Network.format_id(network_id) .. "> " .. state .. "\n" ..
    "Tank <" .. FluidStack.to_string(fluid_stack, fluid_interface.capacity) .. "> "
  )
end

function pump_yatm_network.update(pos, node, _ot)
  local pump_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
  local target_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[pump_dir])
  local target_node = minetest.get_node(target_pos)
  local fluid_name = FluidRegistry.item_name_to_fluid_name(target_node.name)

  if fluid_name then
    local used_stack = FluidTanks.fill(pos, pump_dir, FluidStack.new(fluid_name, 1000), true)
    if used_stack and used_stack.amount > 0 then
      minetest.remove_node(target_pos)
    end
  else
    local inverted_dir = yatm_core.invert_dir(pump_dir)
    local drained_stack = FluidTanks.drain(target_pos, inverted_dir, FluidStack.new_wildcard(1000), false)
    if drained_stack and drained_stack.amount > 0 then
      local existing = FluidTanks.get(pos, pump_dir)
      local filled_stack = FluidTanks.fill(pos, pump_dir, drained_stack, true)

      if filled_stack and filled_stack.amount > 0 then
        FluidTanks.drain(target_pos,
          inverted_dir,
          filled_stack, true)
      end
    end
  end

  local meta = minetest.get_meta(pos)
  do
    local new_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_UP)
    local target_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[new_dir])
    local stack = FluidMeta.drain_fluid(meta,
      "tank",
      FluidStack.new_wildcard(1000),
      fluid_interface.capacity, fluid_interface.capacity, false)
    if stack and stack.amount > 0 then
      local target_dir = yatm_core.invert_dir(new_dir)
      local filled_stack = FluidStack.presence(FluidTanks.fill(target_pos, target_dir, stack, true))
      if filled_stack then
        FluidMeta.drain_fluid(meta,
          "tank",
          filled_stack,
          fluid_interface.capacity, fluid_interface.capacity, true)
      end
    end
  end
end

local old_fill = fluid_interface.fill
function fluid_interface:fill(pos, dir, fluid_stack, commit)
  local node = minetest.get_node(pos)
  local pump_in_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
  if dir == pump_in_dir then
    return old_fill(self, pos, dir, fluid_stack, commit)
  else
    return nil
  end
end

local groups = {
  cracky = 1, fluid_interface_out = 1, yatm_energy_device = 1,
}

yatm.devices.register_network_device(pump_yatm_network.states.off, {
  description = "Pump",
  groups = groups,
  drop = pump_yatm_network.states.off,
  tiles = {
    "yatm_pump_top.png",
    "yatm_pump_bottom.png",
    "yatm_pump_side.off.png",
    "yatm_pump_side.off.png^[transformFX",
    "yatm_pump_back.off.png",
    "yatm_pump_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(pump_yatm_network, {state = "off"}),
  fluid_interface = fluid_interface,
})

yatm.devices.register_network_device(pump_yatm_network.states.error, {
  description = "Pump",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = pump_yatm_network.states.off,
  tiles = {
    "yatm_pump_top.png",
    "yatm_pump_bottom.png",
    "yatm_pump_side.error.png",
    "yatm_pump_side.error.png^[transformFX",
    "yatm_pump_back.error.png",
    "yatm_pump_front.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(pump_yatm_network, {state = "error"}),
  fluid_interface = fluid_interface,
})

yatm.devices.register_network_device(pump_yatm_network.states.on, {
  description = "Pump",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = pump_yatm_network.states.off,
  tiles = {
    "yatm_pump_top.png",
    "yatm_pump_bottom.png",
    "yatm_pump_side.on.png",
    "yatm_pump_side.on.png^[transformFX",
    "yatm_pump_back.on.png",
    "yatm_pump_front.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(pump_yatm_network, {state = "on"}),
  fluid_interface = fluid_interface,
})
