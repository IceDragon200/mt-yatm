local mod = yatm_machines
local Directions = assert(foundation.com.Directions)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidStack = assert(yatm.fluids.FluidStack)

local fluid_replicator_yatm_network = {
  kind = "monitor",
  groups = {
    creative_replicator = 1,
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_machines:fluid_replicator_error",
    conflict = "yatm_machines:fluid_replicator_error",
    off = "yatm_machines:fluid_replicator_off",
    on = "yatm_machines:fluid_replicator_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 100,
  },
}

local TANK_NAME = "tank"
local fluid_interface = {
  _private = {
    tank_name = TANK_NAME,
    capacity = 16000,
  }
}

function fluid_interface:get(pos, dir)
  local meta = minetest.get_meta(pos)
  local stack = FluidMeta.get_fluid_stack(meta, self.tank_name)
  stack.amount = self._private.capacity
  return stack
end

function fluid_interface:replace(pos, dir, new_stack, commit)
  local meta = minetest.get_meta(pos)
  local stack, new_stack = FluidMeta.set_fluid(meta, self.tank_name, new_stack, commit)
  if commit then
    self:on_fluid_changed(pos, dir, new_stack)
  end
  return stack
end

function fluid_interface:fill(pos, dir, new_stack, commit)
  local meta = minetest.get_meta(pos)
  local capacity = self._private.capacity
  local stack, new_stack = FluidMeta.fill_fluid(meta,
    self.tank_name,
    FluidStack.set_amount(new_stack, capacity),
    capacity, capacity, commit)
  if commit then
    self:on_fluid_changed(pos, dir, new_stack)
  end
  return stack
end

function fluid_interface:drain(pos, dir, new_stack, commit)
  local meta = minetest.get_meta(pos)
  local capacity = self._private.capacity
  local stack, new_stack = FluidMeta.drain_fluid(meta,
    self.tank_name,
    FluidStack.set_amount(new_stack, capacity),
    capacity, capacity, false)
  if commit then
    self:on_fluid_changed(pos, dir, new_stack)
  end
  return stack
end

function fluid_replicator_yatm_network:work(ctx)
  local pos = ctx.pos
  local meta = ctx.meta
  local node = ctx.node

  local energy_consumed = 0

  if not FluidMeta.is_empty(meta, TANK_NAME) then
    local capacity = fluid_interface._private.capacity
    local target_pos
    local stack
    local target_dir

    -- Drain fluid from replicator into any adjacent fluid interface
    for _, dir in ipairs(Directions.DIR6) do
      target_pos = vector.add(pos, Directions.DIR6_TO_VEC3[dir])
      stack = FluidMeta.drain_fluid(meta,
        TANK_NAME,
        FluidStack.new_wildcard(capacity),
        capacity, capacity, false)

      if stack then
        stack.amount = capacity
        target_dir = Directions.invert_dir(dir)
        yatm.fluid_tanks.fill(target_pos, target_dir, stack.name, stack.amount, true)
        energy_consumed = energy_consumed + 10
        yatm.queue_refresh_infotext(pos, node)
      end
    end
  end

  return energy_consumed
end

local groups = {
  cracky = 1,
  yatm_energy_device = 1,
  fluid_interface_out = 1,
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("fluid_replicator"),

  basename = mod:make_name("fluid_replicator"),

  description = mod.S("Fluid Replicator"),

  groups = groups,
  drop = fluid_replicator_yatm_network.states.off,
  tiles = {
    "yatm_fluid_replicator_top.off.png",
    "yatm_fluid_replicator_bottom.png",
    "yatm_fluid_replicator_side.off.png",
    "yatm_fluid_replicator_side.off.png^[transformFX",
    "yatm_fluid_replicator_back.off.png",
    "yatm_fluid_replicator_front.off.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",
  yatm_network = fluid_replicator_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_fluid_replicator_top.error.png",
      "yatm_fluid_replicator_bottom.png",
      "yatm_fluid_replicator_side.error.png",
      "yatm_fluid_replicator_side.error.png^[transformFX",
      "yatm_fluid_replicator_back.error.png",
      "yatm_fluid_replicator_front.error.png",
    },
  },
  on = {
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
  },
})
