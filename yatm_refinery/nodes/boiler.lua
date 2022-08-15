local mod = assert(yatm_refinery)
local fspec = assert(foundation.com.formspec.api)
local fluid_fspec = assert(yatm.fluids.formspec)
local Groups = assert(foundation.com.Groups)
local Directions = assert(foundation.com.Directions)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local Energy = assert(yatm.energy)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

local boiler_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1, -- Use the machine worker behaviour
    energy_consumer = 1, -- This device consumes energy on the network
  },
  default_state = "off",
  states = {
    conflict = "yatm_refinery:boiler_error",
    error = "yatm_refinery:boiler_error",
    idle = "yatm_refinery:boiler_idle",
    off = "yatm_refinery:boiler_off",
    on = "yatm_refinery:boiler_on",
  },
  energy = {
    passive_lost = 0,
    startup_threshold = 0,
    capacity = 16000,
    network_charge_bandwidth  = 1000,
  },
}

local STEAM_TANK = "steam_tank"
local WATER_TANK = "water_tank"
local TANK_CAPACITY = 16000

local function get_fluid_tank_name(self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_UP then
    return STEAM_TANK, self._private.capacity
  else
    return WATER_TANK, self._private.capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface._private.capacity = TANK_CAPACITY
fluid_interface._private.bandwidth = fluid_interface._private.capacity

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

local function boiler_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local steam_fluid_stack = FluidMeta.get_fluid_stack(meta, STEAM_TANK)
  local water_fluid_stack = FluidMeta.get_fluid_stack(meta, WATER_TANK)

  local infotext =
    string.format(
      "%s\n%s\nEnergy: %s\nSteam Tank: %s\nWater Tank: %s",
      cluster_devices:get_node_infotext(pos),
      cluster_energy:get_node_infotext(pos),
      Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY),
      FluidStack.pretty_format(steam_fluid_stack, fluid_interface._private.capacity),
      FluidStack.pretty_format(water_fluid_stack, fluid_interface._private.capacity)
    )

  meta:set_string("infotext", infotext)
end

function boiler_yatm_network:work(ctx)
  local pos = ctx.pos
  local node = ctx.node
  local meta = ctx.meta
  local dtime = ctx.dtime

  local energy_consumed = 0

  yatm.devices.set_idle(meta, 1)
  -- Drain water from adjacent tanks
  for _, dir in ipairs(Directions.DIR4) do
    local water_tank_dir = Directions.facedir_to_face(node.param2, dir)

    local water_tank_pos = vector.add(pos, Directions.DIR6_TO_VEC3[water_tank_dir])
    local water_tank_node = minetest.get_node(water_tank_pos)
    local water_tank_nodedef = minetest.registered_nodes[water_tank_node.name]
    if water_tank_nodedef then
      if Groups.get_item(water_tank_nodedef, "fluid_tank") then
        local target_dir = Directions.invert_dir(water_tank_dir)
        local stack = FluidTanks.drain_fluid(
          water_tank_pos,
          target_dir,
          FluidStack.new("group:water", math.floor(1000 * dtime)),
          false
        )

        if stack then
          local filled_stack = FluidTanks.fill_fluid(pos, water_tank_dir, stack, true)
          if filled_stack and filled_stack.amount > 0 then
            FluidTanks.drain_fluid(water_tank_pos, target_dir, filled_stack, true)
            energy_consumed = energy_consumed + 1
          end
        end
      end
    end
  end

  local meta = minetest.get_meta(pos)

  -- Convert water into steam
  do
    local stack =
      FluidMeta.drain_fluid(
        meta,
        WATER_TANK,
        FluidStack.new("group:water", math.floor(1000 * dtime)),
        fluid_interface._private.bandwidth,
        fluid_interface._private.capacity,
        false
      )

    if stack then
      -- TODO: yatm_core:steam should not be hardcoded
      local filled_stack =
        FluidMeta.fill_fluid(
          meta,
          STEAM_TANK,
          FluidStack.set_name(stack, "yatm_core:steam"),
          fluid_interface._private.bandwidth,
          fluid_interface._private.capacity,
          true
        )

      if filled_stack and filled_stack.amount > 0 then
        FluidMeta.drain_fluid(
          meta,
          WATER_TANK,
          FluidStack.set_amount(stack, filled_stack.amount),
          fluid_interface._private.bandwidth,
          fluid_interface._private.capacity,
          true
        )

        energy_consumed = energy_consumed + filled_stack.amount
      end
    end
  end

  -- Fill tank on the UP face of the boiler with steam, if available
  do
    local stack, _new_stack =
      FluidMeta.drain_fluid(
        meta,
        STEAM_TANK,
        FluidStack.new("group:steam", math.floor(1000 * dtime)),
        fluid_interface._private.capacity,
        fluid_interface._private.capacity,
        false
      )

    if stack then
      local steam_tank_dir = Directions.facedir_to_face(node.param2, Directions.D_UP)
      local steam_tank_pos = vector.add(pos, Directions.DIR6_TO_VEC3[steam_tank_dir])
      local steam_tank_node = minetest.get_node(steam_tank_pos)
      local steam_tank_nodedef = minetest.registered_nodes[steam_tank_node.name]

      if steam_tank_nodedef then
        local filled_stack =
          FluidTanks.fill_fluid(
            steam_tank_pos,
            Directions.invert_dir(steam_tank_dir),
            stack,
            true
          )

        if filled_stack and filled_stack.amount > 0 then
          FluidTanks.drain_fluid(pos, steam_tank_dir, filled_stack, true)
          energy_consumed = energy_consumed + 1
        end
      end
    end
  end

  return energy_consumed
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, 8, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      local steam_stack = FluidMeta.get_fluid_stack(meta, STEAM_TANK)
      local water_stack = FluidMeta.get_fluid_stack(meta, WATER_TANK)

      return fluid_fspec.render_fluid_stack(rect.x, rect.y, 1, cis(4), steam_stack, TANK_CAPACITY) ..
        fluid_fspec.render_fluid_stack(rect.x + cio(7), rect.y, 1, cis(4), water_stack, TANK_CAPACITY)
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
  return "yatm_refinery:boiler:"..Vector3.to_string(pos)
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

yatm.devices.register_stateful_network_device({
  basename = "yatm_refinery:boiler",

  description = mod.S("Boiler"),

  codex_entry_id = "yatm_refinery:boiler",

  groups = {
    cracky = 1,
    fluid_interface_out = 1,
    fluid_interface_in = 1,
    yatm_energy_device = 1,
  },

  drop = boiler_yatm_network.states.off,

  tiles = {
    "yatm_boiler_top.off.png",
    "yatm_boiler_bottom.off.png",
    "yatm_boiler_side.off.png",
    "yatm_boiler_side.off.png",
    "yatm_boiler_side.off.png",
    "yatm_boiler_side.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = boiler_yatm_network,

  fluid_interface = fluid_interface,

  refresh_infotext = boiler_refresh_infotext,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_boiler_top.error.png",
      "yatm_boiler_bottom.error.png",
      "yatm_boiler_side.error.png",
      "yatm_boiler_side.error.png",
      "yatm_boiler_side.error.png",
      "yatm_boiler_side.error.png"
    },
  },
  idle = {
    tiles = {
      "yatm_boiler_top.off.png",
      "yatm_boiler_bottom.off.png",
      "yatm_boiler_side.idle.png",
      "yatm_boiler_side.idle.png",
      "yatm_boiler_side.idle.png",
      "yatm_boiler_side.idle.png"
    },
  },
  on = {
    tiles = {
      "yatm_boiler_top.on.png",
      "yatm_boiler_bottom.on.png",
      "yatm_boiler_side.on.png",
      "yatm_boiler_side.on.png",
      "yatm_boiler_side.on.png",
      "yatm_boiler_side.on.png",
    },
    light_source = 7,
  },
})
