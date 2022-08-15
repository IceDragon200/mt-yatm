local mod = yatm_machines
local Vector3 = assert(foundation.com.Vector3)
local fspec = assert(foundation.com.formspec.api)
local fluid_fspec = assert(yatm.fluids.formspec)
local Directions = assert(foundation.com.Directions)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidContainers = assert(yatm.fluids.FluidContainers)
local fluid_registry = assert(yatm.fluids.fluid_registry)
local player_service = assert(nokore.player_service)

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
local TANK_CAPACITY = 16000
local fluid_interface = {
  _private = {
    tank_name = TANK_NAME,
    capacity = TANK_CAPACITY,
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
  local stack, new_stack =
    FluidMeta.fill_fluid(
      meta,
      self.tank_name,
      FluidStack.set_amount(new_stack, capacity),
      capacity,
      capacity,
      commit
    )

  if commit then
    self:on_fluid_changed(pos, dir, new_stack)
  end
  return stack
end

function fluid_interface:drain(pos, dir, new_stack, commit)
  local meta = minetest.get_meta(pos)
  local capacity = self._private.capacity
  local stack, new_stack =
    FluidMeta.drain_fluid(
      meta,
      self.tank_name,
      FluidStack.set_amount(new_stack, capacity),
      capacity,
      capacity,
      false
    )

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

  return energy_consumed
end

local function maybe_initialize_inventory(meta)
  assert(meta, "expected metaref")

  local inv = meta:get_inventory()
  -- slot used to extract duplicated fluid
  inv:set_size("ftank_extract_slot", 1)

  -- slot used to copy fluid from given item
  inv:set_size("ftank_copy_slot", 1)
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, 8, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      local fluid_stack = FluidMeta.get_fluid_stack(meta, TANK_NAME)

      return fluid_fspec.render_fluid_stack(rect.x, rect.y + cio(1), 1, cis(2), fluid_stack, TANK_CAPACITY) ..
             fspec.list(node_inv_name, "ftank_copy_slot", rect.x, rect.y, 1, 1) ..
             fspec.list(node_inv_name, "ftank_extract_slot", rect.x, rect.y + cio(3), 1, 1)
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_machines:fluid_replicator:"..Vector3.to_string(pos)
end

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, user)
  local meta = minetest.get_meta(pos)

  maybe_initialize_inventory(meta)

  local state = {
    pos = pos,
  }
  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
      timers = {
        -- steam turbines have a fluid tank, so their formspecs need to be routinely updated
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)

  maybe_initialize_inventory(meta)
end

local function on_metadata_inventory_put(pos, list, index, item_stack, player)
  if list == "ftank_copy_slot" then
    local fluid_name = nil
    -- check if the given item is a fluid container
    if FluidContainers.is_fluid_container(item_stack) then
      local fluid_stack = FluidContainers.get_fluid_stack(item_stack)
      if fluid_stack and fluid_stack.amount > 0 then
        -- only if the fluid stack is actually present
        fluid_name = fluid_stack.name
      end
    else
      -- try to get a fluid name from the given item name
      fluid_name = fluid_registry.item_name_to_fluid_name(item_stack:get_name())
    end

    local fluid_stack
    if fluid_name then
      fluid_stack = FluidStack.new(fluid_name, TANK_CAPACITY)
    else
      fluid_stack = FluidStack.new()
    end

    local meta = minetest.get_meta(pos)

    FluidMeta.set_fluid(meta, TANK_NAME, fluid_stack, true)
  end
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

  on_construct = on_construct,

  on_rightclick = on_rightclick,

  on_metadata_inventory_put = on_metadata_inventory_put,
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
