local Directions = assert(foundation.com.Directions)
local Vector3 = assert(foundation.com.Vector3)
local Groups = assert(foundation.com.Groups)
local table_merge = assert(foundation.com.table_merge)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidExchange = assert(yatm.fluids.FluidExchange)
local Energy = assert(yatm.energy)
local vapour_registry = assert(yatm.refinery.vapour_registry)
local fspec = assert(foundation.com.formspec.api)
local energy_fspec = assert(yatm.energy.formspec)
local fluid_fspec = assert(yatm.fluids.formspec)
local player_service = assert(nokore.player_service)

local vapourizer_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1, -- Use the machine worker behaviour
    energy_consumer = 1, -- This device consumes energy on the network
  },
  default_state = "off",
  states = {
    conflict = "yatm_refinery:vapourizer_error",
    error = "yatm_refinery:vapourizer_error",
    off = "yatm_refinery:vapourizer_off",
    on = "yatm_refinery:vapourizer_on",
    idle = "yatm_refinery:vapourizer_idle",
  },
  energy = {
    passive_lost = 0,
    startup_threshold = 0,
    capacity = 16000,
    network_charge_bandwidth = 1000,
  },
}

local VAPOUR_TANK = "vapour_tank"
local FLUID_TANK = "fluid_tank"
local TANK_CAPACITY = 16000

local function get_fluid_tank_name(self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_UP then
    return VAPOUR_TANK, self._private.capacity
  else
    return FLUID_TANK, self._private.capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface._private.capacity = TANK_CAPACITY
fluid_interface._private.bandwidth = fluid_interface._private.capacity

function fluid_interface:allow_fill(pos, dir, fluid_stack)
  local tank_name = get_fluid_tank_name(self, pos, dir)
  if tank_name == FLUID_TANK then
    return true
  end
  return false
end

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

-- TODO: auto_transfer shouldn't be used, instead auto-eject options should be available applicable nodes
local auto_transfer = true

function vapourizer_yatm_network:work(ctx)
  local energy_consumed = 0
  local need_refresh = false
  local meta = ctx.meta

  local pos = ctx.pos
  local node = ctx.node
  local dtime = ctx.dtime

  if auto_transfer then
    -- Fluid transfer from input
    local input_tank_dir = Directions.facedir_to_face(node.param2, Directions.D_DOWN)
    local input_tank_pos = vector.add(pos, Directions.DIR6_TO_VEC3[input_tank_dir])

    local fs = FluidExchange.transfer_from_tank_to_meta(
      input_tank_pos, Directions.invert_dir(input_tank_dir),
      FluidStack.new_wildcard(1000),
      meta, {
        tank_name = FLUID_TANK,
        capacity = fluid_interface._private.capacity,
        bandwidth = fluid_interface._private.bandwidth
      },
      true
    )

    if fs and fs.amount > 0 then
      need_refresh = true
    end
  end

  -- Conversion
  local fluid_stack = FluidMeta.get_fluid_stack(meta, FLUID_TANK)
  if fluid_stack and fluid_stack.amount > 0 then
    local fluid_name = fluid_stack.name
    local recipe = vapour_registry:find_recipe_for_fluid(fluid_name)
    if recipe then
      local vapour_stack = FluidStack.new(recipe.vapour_name, math.min(fluid_stack.amount, 100))
      fluid_stack.amount = vapour_stack.amount
      if fluid_stack.amount > 0 then
        local filled_stack =
          FluidMeta.fill_fluid(
            meta,
            VAPOUR_TANK,
            vapour_stack,
            fluid_interface._private.capacity,
            fluid_interface._private.capacity,
            true
          )

        if filled_stack and filled_stack.amount > 0 then
          fluid_stack.amount = filled_stack.amount
          local drained_stack =
            FluidMeta.drain_fluid(
              meta,
              FLUID_TANK,
              fluid_stack,
              fluid_interface._private.capacity,
              fluid_interface._private.capacity,
              true
            )

          need_refresh = true
          energy_consumed = energy_consumed + math.max(math.floor(drained_stack.amount / 100), 1)
        end
      end
      meta:set_string("error_text", nil)
    else
      meta:set_string("error_text", "no recipe")
      need_refresh = true
    end
  end

  if auto_transfer then
    -- Fluid transfer to output - and only to fluid_tanks
    local output_tank_dir = Directions.facedir_to_face(node.param2, Directions.D_UP)
    local output_tank_pos = vector.add(pos, Directions.DIR6_TO_VEC3[output_tank_dir])

    local output_tank_node = minetest.get_node_or_nil(output_tank_pos)

    if output_tank_node then
      local output_tank_nodedef = minetest.registered_nodes[output_tank_node.name]

      if Groups.has_group(output_tank_nodedef, "fluid_interface_in") then
        local fs =
          FluidExchange.transfer_from_meta_to_tank(
            meta,
            {
              tank_name = VAPOUR_TANK,
              capacity = fluid_interface._private.capacity,
              bandwidth = fluid_interface._private.capacity
            },
            FluidStack.new_wildcard(100),
            output_tank_pos,
            Directions.invert_dir(output_tank_dir),
            true
          )

        if fs and fs.amount > 0 then
          need_refresh = true
        end
      end
    end
  end

  if need_refresh then
    yatm.queue_refresh_infotext(pos, node)
  end

  return energy_consumed
end

function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local vapour_fluid_stack = FluidMeta.get_fluid_stack(meta, VAPOUR_TANK)
  local fluid_stack = FluidMeta.get_fluid_stack(meta, FLUID_TANK)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. " (" .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. " E)" .. "\n" ..
    "Vapour Tank: " .. FluidStack.pretty_format(vapour_fluid_stack, fluid_interface._private.capacity) .. "\n" ..
    "Fluid Tank: " .. FluidStack.pretty_format(fluid_stack, fluid_interface._private.capacity)

  meta:set_string("infotext", infotext)
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local meta = minetest.get_meta(pos)
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_heated" }, function (loc, rect)
    if loc == "main_body" then
      local vapour_fluid_stack = FluidMeta.get_fluid_stack(meta, VAPOUR_TANK)
      local liquid_fluid_stack = FluidMeta.get_fluid_stack(meta, FLUID_TANK)

      return fluid_fspec.render_fluid_stack(
          rect.x,
          rect.y,
          1,
          rect.h,
          liquid_fluid_stack,
          TANK_CAPACITY
        ) ..
        fluid_fspec.render_fluid_stack(
          rect.x + rect.w - cio(2),
          rect.y,
          1,
          rect.h,
          vapour_fluid_stack,
          TANK_CAPACITY
        ) ..
        energy_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cio(1),
          rect.y,
          1,
          rect.h,
          meta,
          yatm.devices.ENERGY_BUFFER_KEY,
          yatm.devices.get_energy_capacity(pos, state.node)
        )
    elseif loc == "footer" then
      return fspec.list_ring(node_inv_name, "input_slot") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_foundry:electric_smelter:"..Vector3.to_string(pos)
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
    node = node,
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
        -- routinely update the formspec
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_refinery:vapourizer",

  description = "Vapourizer",

  codex_entry_id = "yatm_refinery:vapourizer",

  groups = {
    cracky = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
    yatm_energy_device = 1,
  },

  drop = vapourizer_yatm_network.states.off,

  tiles = {
    "yatm_vapourizer_top.off.png",
    "yatm_vapourizer_bottom.off.png",
    "yatm_vapourizer_side.off.png",
    "yatm_vapourizer_side.off.png",
    "yatm_vapourizer_side.off.png",
    "yatm_vapourizer_side.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = table_merge(vapourizer_yatm_network, {state = "off"}),

  fluid_interface = fluid_interface,

  refresh_infotext = refresh_infotext,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_vapourizer_top.error.png",
      "yatm_vapourizer_bottom.error.png",
      "yatm_vapourizer_side.error.png",
      "yatm_vapourizer_side.error.png",
      "yatm_vapourizer_side.error.png",
      "yatm_vapourizer_side.error.png"
    },
  },
  idle = {
    tiles = {
      "yatm_vapourizer_top.idle.png",
      "yatm_vapourizer_bottom.idle.png",
      "yatm_vapourizer_side.idle.png",
      "yatm_vapourizer_side.idle.png",
      "yatm_vapourizer_side.idle.png",
      "yatm_vapourizer_side.idle.png"
    },
  },
  on = {
    tiles = {
      "yatm_vapourizer_top.on.png",
      "yatm_vapourizer_bottom.on.png",
      "yatm_vapourizer_side.on.png",
      "yatm_vapourizer_side.on.png",
      "yatm_vapourizer_side.on.png",
      "yatm_vapourizer_side.on.png"
    },
    light_source = 7,
  },
})
