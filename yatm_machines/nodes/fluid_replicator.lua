local FluidStack =  yatm.fluids.FluidStack

local fluid_replicator_yatm_network = {
  kind = "monitor",
  groups = {
    creative_replicator = 1,
    has_update = 1,
  },
  states = {
    error = "yatm_machines:fluid_replicator_error",
    conflict = "yatm_machines:fluid_replicator_error",
    off = "yatm_machines:fluid_replicator_off",
    on = "yatm_machines:fluid_replicator_on",
  },
}

local fluid_interface = {
  tank_name = "tank",
  capacity = 16000,
}

function fluid_interface:get(pos, dir)
  local meta = minetest.get_meta(pos)
  local stack = yatm_core.fluids.get_fluid(meta, self.tank_name)
  stack.amount = capacity
  return stack
end

function fluid_interface:replace(pos, dir, new_stack, commit)
  local meta = minetest.get_meta(pos)
  local stack, new_stack = yatm_core.fluids.set_fluid(meta, self.tank_name, new_stack, commit)
  if commit then
    self:on_fluid_changed(pos, dir, new_stack)
  end
  return stack
end

function fluid_interface:fill(pos, dir, new_stack, commit)
  local meta = minetest.get_meta(pos)
  local stack, new_stack = yatm_core.fluids.fill_fluid(meta,
    self.tank_name,
    FluidStack.set_amount(new_stack, capacity),
    self.capacity, self.capacity, commit)
  if commit then
    self:on_fluid_changed(pos, dir, new_stack)
  end
  return stack
end

function fluid_interface:drain(pos, dir, new_stack, commit)
  local meta = minetest.get_meta(pos)
  local stack, new_stack = yatm_core.fluids.drain_fluid(meta,
    self.tank_name,
    FluidStack.set_amount(new_stack, self.capacity),
    self.capacity, self.capacity, false)
  if commit then
    self:on_fluid_changed(pos, dir, new_stack)
  end
  return stack
end

function fluid_replicator_yatm_network.update(pos, node, ot)
  -- Drain fluid from replicator into any adjacent fluid interface
  for _, dir in ipairs(yatm_core.DIR6) do
    local target_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[dir])
    local stack = yatm_core.fluids.drain_fluid(meta,
      self.tank_name,
      FluidStack.new_wildcard(self.capacity),
      self.capacity, self.capacity, false)
    if stack then
      stack.amount = capacity
      local target_dir = yatm_core.invert_dir(dir)
      yatm_core.fluid_tanks.fill(target_pos, target_dir, stack.name, stack.amount, true)
    end
  end
end

yatm.devices.register_network_device(fluid_replicator_yatm_network.states.off, {
  description = "Fluid Replicator",
  groups = {cracky = 1},
  drop = fluid_replicator_yatm_network.states.off,
  tiles = {
    "yatm_fluid_replicator_top.off.png",
    "yatm_fluid_replicator_bottom.png",
    "yatm_fluid_replicator_side.off.png",
    "yatm_fluid_replicator_side.off.png^[transformFX",
    "yatm_fluid_replicator_back.off.png",
    "yatm_fluid_replicator_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = fluid_replicator_yatm_network,
})

yatm.devices.register_network_device(fluid_replicator_yatm_network.states.error, {
  description = "Fluid Replicator",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = fluid_replicator_yatm_network.states.off,
  tiles = {
    "yatm_fluid_replicator_top.error.png",
    "yatm_fluid_replicator_bottom.png",
    "yatm_fluid_replicator_side.error.png",
    "yatm_fluid_replicator_side.error.png^[transformFX",
    "yatm_fluid_replicator_back.error.png",
    "yatm_fluid_replicator_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = fluid_replicator_yatm_network,
})

yatm.devices.register_network_device(fluid_replicator_yatm_network.states.on, {
  description = "Fluid Replicator",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = fluid_replicator_yatm_network.states.off,
  tiles = {
    "yatm_fluid_replicator_top.on.png",
    "yatm_fluid_replicator_bottom.png",
    "yatm_fluid_replicator_side.on.png",
    "yatm_fluid_replicator_side.on.png^[transformFX",
    {
      name = "yatm_fluid_replicator_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    {
      name = "yatm_fluid_replicator_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = fluid_replicator_yatm_network,
})
