local Directions = assert(foundation.com.Directions)
local Vector3 = assert(foundation.com.Vector3)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local fluid_registry = assert(yatm.fluids.fluid_registry)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local Energy = assert(yatm.energy)
local distillation_registry = assert(yatm.refinery.distillation_registry)
local FluidExchange = assert(yatm.fluids.FluidExchange)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)

local distillation_unit_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    fluid_consumer = 1,
    fluid_producer = 1,
    distillation_unit = 1,
  },

  default_state = "off",
  states = {
    on = "yatm_refinery:distillation_unit_on",
    off = "yatm_refinery:distillation_unit_off",
    error = "yatm_refinery:distillation_unit_error",
    conflict = "yatm_refinery:distillation_unit_conflict",
  },

  energy = {
    capacity = 4000,
    passive_energy_lost = 0,
    network_charge_bandwidth = 1000,
    startup_threshold = 100,
  },
}

local OUTPUT_STEAM_TANK = "output_steam_tank"
local INPUT_STEAM_TANK = "input_steam_tank"
local DISTILLED_TANK = "distilled_tank"

local TANK_CAPACITY = 16000

local function get_fluid_tank_name(self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_UP then
    return OUTPUT_STEAM_TANK, self._private.capacity
  elseif new_dir == Directions.D_DOWN then
    return INPUT_STEAM_TANK, self._private.capacity
  else
    return DISTILLED_TANK, self._private.capacity
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

function fluid_interface:allow_fill(pos, dir, fluid_stack)
  if fluid_stack then
    local name, _capacity = self:get_fluid_tank_name(pos, dir)
    if name == INPUT_STEAM_TANK then
      local fluid = fluid_registry.get_fluid(fluid_stack.name)
      if fluid then
        -- only vapours
        if fluid.groups.vapourized then
          return true
        end
      end
    end
  end
  return false
end

function distillation_unit_yatm_network:work(ctx)
  local pos = ctx.pos
  local meta = ctx.meta
  local node = ctx.node

  local energy_consumed = 0
  local need_refresh = false
  meta:set_int("work_counter", (meta:get_int("work_counter") or 0) + 1)

  local fluid_stack = FluidMeta.get_fluid_stack(meta, INPUT_STEAM_TANK)

  if not FluidStack.is_empty(fluid_stack) then
    -- limit the stack to only 100 units of fluid
    fluid_stack.amount = math.min(fluid_stack.amount, 100)
    local fluid_name = fluid_stack.name
    local recipe = distillation_registry:find_distillation_recipe(fluid_name)

    if recipe then
      local input_vapour_ratio = recipe.ratios[1]
      local distill_ratio = recipe.ratios[2]
      local output_vapour_ratio = recipe.ratios[3]
      -- how many units or blocks of fluid can be converted at the moment
      local units = math.floor(fluid_stack.amount / input_vapour_ratio)

      local distilled_fluid_stack = FluidStack.new(recipe.distilled_fluid_name, units * distill_ratio)
      local output_vapour_fluid_stack = FluidStack.new(recipe.output_vapour_name, units * output_vapour_ratio)

      -- Since the distillation unit has to deal with multiple fluids, the filling is not committed but instead done as a kind of transaction
      -- Where we simulate adding the fluid
      local used_distilled_stack, new_distilled_stack =
        FluidMeta.fill_fluid(meta, DISTILLED_TANK, distilled_fluid_stack, fluid_interface._private.capacity, fluid_interface._private.capacity, false)
      local used_output_stack, new_output_stack =
        FluidMeta.fill_fluid(meta, OUTPUT_STEAM_TANK, output_vapour_fluid_stack, fluid_interface._private.capacity, fluid_interface._private.capacity, false)

      if used_output_stack and used_distilled_stack then
        -- All the fluid must be used
        if used_distilled_stack.amount == distilled_fluid_stack.amount and
           used_output_stack.amount == output_vapour_fluid_stack.amount then
          local used_amount = units * input_vapour_ratio
          local new_input_stack = FluidStack.set_amount(fluid_stack, fluid_stack.amount - used_amount)
          FluidMeta.set_fluid(meta, INPUT_STEAM_TANK, new_input_stack, true)
          FluidMeta.set_fluid(meta, DISTILLED_TANK, new_distilled_stack, true)
          FluidMeta.set_fluid(meta, OUTPUT_STEAM_TANK, new_output_stack, true)

          energy_consumed = energy_consumed + math.max(used_amount / 100, 1)

          meta:set_string("error_text", nil)
          need_refresh = true
        else
          meta:set_string("error_text", "distilled output amount mismatch")
          need_refresh = true
        end
      else
        meta:set_string("error_text", "no output or distilled fluid")
        need_refresh = true
      end
    else
      meta:set_string("error_text", "no recipe")
      need_refresh = true
      yatm.devices.set_idle(meta, 3)
    end
  end

  do -- output new vapour
    local output_tank_dir = Directions.facedir_to_face(node.param2, Directions.D_UP)
    local output_tank_pos = vector.add(pos, Directions.DIR6_TO_VEC3[output_tank_dir])

    fluid_stack = FluidExchange.transfer_from_meta_to_tank(
      meta, { tank_name = OUTPUT_STEAM_TANK, capacity = fluid_interface._private.capacity, bandwidth = fluid_interface._private.capacity },
      FluidStack.new_wildcard(100),
      output_tank_pos, Directions.invert_dir(output_tank_dir),
      true
    )

    if fluid_stack and fluid_stack.amount > 0 then
      need_refresh = true
    end
  end

  do -- output distilled fluids
    local output_tank_dir
    local output_tank_pos

    for _,dir_code in pairs(Directions.DIR4) do
      output_tank_dir = Directions.facedir_to_face(node.param2, dir_code)
      output_tank_pos = vector.add(pos, Directions.DIR6_TO_VEC3[output_tank_dir])

      fluid_stack = FluidExchange.transfer_from_meta_to_tank(
        meta, { tank_name = DISTILLED_TANK, capacity = fluid_interface._private.capacity, bandwidth = fluid_interface._private.capacity },
        FluidStack.new_wildcard(100),
        output_tank_pos, Directions.invert_dir(output_tank_dir),
        true
      )

      if fluid_stack and fluid_stack.amount > 0 then
        need_refresh = true
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

  local output_steam_fluid_stack = FluidMeta.get_fluid_stack(meta, OUTPUT_STEAM_TANK)
  local input_steam_fluid_stack = FluidMeta.get_fluid_stack(meta, INPUT_STEAM_TANK)
  local distilled_fluid_stack = FluidMeta.get_fluid_stack(meta, DISTILLED_TANK)

  local error_text = meta:get_string("error_text")
  local work_counter = meta:get_int("work_counter")

  local infotext =
    cluster_devices:get_node_infotext(pos) .. " [" .. work_counter .. "]"

  if error_text then
    infotext = infotext .. " (" .. error_text .. ")"
  end

  local capacity = fluid_interface._private.capacity

  infotext =
    infotext .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "(" .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. " E)" .. "\n" ..
    "I.Steam Tank: " .. FluidStack.pretty_format(input_steam_fluid_stack, capacity) .. "\n" ..
    "O.Steam Tank: " .. FluidStack.pretty_format(output_steam_fluid_stack, capacity) .. "\n" ..
    "Distilled Tank: " .. FluidStack.pretty_format(distilled_fluid_stack, capacity)

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
      local output_steam_fluid_stack = FluidMeta.get_fluid_stack(meta, OUTPUT_STEAM_TANK)
      local input_steam_fluid_stack = FluidMeta.get_fluid_stack(meta, INPUT_STEAM_TANK)
      local distilled_fluid_stack = FluidMeta.get_fluid_stack(meta, DISTILLED_TANK)

      return yatm_fspec.render_fluid_stack(
          rect.x,
          rect.y,
          1,
          rect.h,
          input_steam_fluid_stack,
          TANK_CAPACITY
        ) ..
        yatm_fspec.render_fluid_stack(
          rect.x + rect.w - cio(3),
          rect.y,
          1,
          rect.h,
          output_steam_fluid_stack,
          TANK_CAPACITY
        ) ..
        yatm_fspec.render_fluid_stack(
          rect.x + rect.w - cio(2),
          rect.y,
          1,
          rect.h,
          distilled_fluid_stack,
          TANK_CAPACITY
        ) ..
        yatm_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cis(1),
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
  basename = "yatm_refinery:distillation_unit",

  description = "Distillation Unit",

  codex_entry_id = "yatm_refinery:distillation_unit",

  drop = distillation_unit_yatm_network.states.off,

  groups = {
    cracky = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
    yatm_energy_device = 1,
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_distillation_unit_top.off.png",
    "yatm_distillation_unit_bottom.off.png",
    "yatm_distillation_unit_side.off.png",
    "yatm_distillation_unit_side.off.png",
    "yatm_distillation_unit_side.off.png",
    "yatm_distillation_unit_side.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
      {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, -- NodeBox2
      {-0.4375, -0.25, -0.4375, 0.4375, 0.3125, 0.4375}, -- NodeBox3
      {-0.5, -0.25, -0.25, 0.5, 0.25, 0.25}, -- NodeBox4
      {-0.25, -0.25, -0.5, 0.25, 0.25, 0.5}, -- NodeBox5
    }
  },

  yatm_network = distillation_unit_yatm_network,

  fluid_interface = fluid_interface,

  refresh_infotext = refresh_infotext,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_distillation_unit_top.error.png",
      "yatm_distillation_unit_bottom.error.png",
      "yatm_distillation_unit_side.error.png",
      "yatm_distillation_unit_side.error.png",
      "yatm_distillation_unit_side.error.png",
      "yatm_distillation_unit_side.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_distillation_unit_top.on.png",
      "yatm_distillation_unit_bottom.on.png",
      "yatm_distillation_unit_side.on.png",
      "yatm_distillation_unit_side.on.png",
      "yatm_distillation_unit_side.on.png",
      "yatm_distillation_unit_side.on.png",
    },
    light_source = 7,
  }
})
