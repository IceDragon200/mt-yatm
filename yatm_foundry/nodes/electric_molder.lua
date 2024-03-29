local Directions = assert(foundation.com.Directions)
local itemstack_is_blank = assert(foundation.com.itemstack_is_blank)
local itemstack_copy = assert(foundation.com.itemstack_copy)
local format_pretty_time = assert(foundation.com.format_pretty_time)
local cluster_devices = assert(yatm.cluster.devices)
local Energy = assert(yatm.energy)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local ItemInterface = assert(yatm.items.ItemInterface)
local molding_registry = assert(yatm.molding.molding_registry)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)
local Vector3 = assert(foundation.com.Vector3)

local yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
    -- heat_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_foundry:electric_molder_error",
    error = "yatm_foundry:electric_molder_error",
    idle = "yatm_foundry:electric_molder_idle",
    off = "yatm_foundry:electric_molder_off",
    on = "yatm_foundry:electric_molder_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 400,
  },
}

local TANK_CAPACITY = 8000
local fluid_interface = FluidInterface.new_simple("molten_tank", TANK_CAPACITY)

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

function fluid_interface:allow_replace(pos, dir, fluid_stack)
  -- If the fluid is molten, then it can be replaced
  if FluidStack.is_member_of_group(fluid_stack, "molten") then
    return true
  else
    return false, "fluid is not molten"
  end
end

fluid_interface.allow_fill = fluid_interface.allow_replace
fluid_interface.allow_drain = fluid_interface.allow_replace

local item_interface =
  ItemInterface.new_directional(function (self, pos, dir)
    local node = minetest.get_node(pos)
    local new_dir = Directions.facedir_to_face(node.param2, dir)
    if new_dir == Directions.D_UP or new_dir == Directions.D_DOWN then
      return "mold_slot"
    end
    return "output_slot"
  end)

local function electric_molder_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)

  local molten_tank_fluid_stack = FluidMeta.get_fluid_stack(meta, "molten_tank")
  local molding_tank_fluid_stack = FluidMeta.get_fluid_stack(meta, "molding_tank")
  local recipe_name = meta:get_string("recipe_name")
  local recipe_time = meta:get_float("recipe_time")
  local recipe_time_max = meta:get_float("recipe_time_max")

  local capacity = fluid_interface:get_capacity(pos, 0)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Recipe: " .. recipe_name .. "\n" ..
    "Molten Tank: " .. FluidStack.pretty_format(molten_tank_fluid_stack, capacity) .. "\n" ..
    "Molding Tank: " .. FluidStack.pretty_format(molding_tank_fluid_stack, capacity) .. "\n" ..
    "Time Remaining: " .. format_pretty_time(recipe_time) .. " / " .. format_pretty_time(recipe_time_max)

  meta:set_string("infotext", infotext)
end

function yatm_network:work(ctx)
  local pos = ctx.pos
  local meta = ctx.meta
  local node = ctx.node

  local energy_consumed = 0
  local inv = meta:get_inventory()

  local molding_fluid = FluidMeta.get_fluid_stack(meta, "molding_tank")
  if not FluidStack.presence(molding_fluid) then
    local mold_item_stack = inv:get_stack("mold_slot",  1)

    if not itemstack_is_blank(mold_item_stack) then
      local molten_fluid = FluidMeta.get_fluid_stack(meta, "molten_tank")
      local recipe = molding_registry:get_molding_recipe(mold_item_stack, molten_fluid)
      if recipe then
        local drained_fluid = FluidMeta.drain_fluid(meta, "molten_tank", recipe.molten_fluid, TANK_CAPACITY, TANK_CAPACITY, false)
        if FluidMeta.room_for_fluid(meta, "molding_tank", drained_fluid, TANK_CAPACITY, TANK_CAPACITY) then
          meta:set_float("recipe_time", recipe.duration)
          meta:set_float("recipe_time_max", recipe.duration)
          meta:set_string("recipe_name", recipe.name)
          inv:add_item("molding_slot", mold_item_stack)
          inv:remove_item("mold_slot", mold_item_stack)
          local filled_fluid = FluidMeta.fill_fluid(meta, "molding_tank", drained_fluid, TANK_CAPACITY, TANK_CAPACITY, true)
          local drained_fluid = FluidMeta.drain_fluid(meta, "molten_tank", filled_fluid, TANK_CAPACITY, TANK_CAPACITY, true)
          --print("filled fluid in molten tank", minetest.pos_to_string(pos), FluidStack.pretty_format(filled_fluid))
          yatm.queue_refresh_infotext(pos)
        end
      else
        yatm.devices.set_sleep(meta, 5)
      end
    end
  end

  local molding_fluid = FluidMeta.get_fluid_stack(meta, "molding_tank")
  if FluidStack.presence(molding_fluid) then
    local recipe_time = meta:get_float("recipe_time")
    recipe_time = math.max(recipe_time - dtime, 0)
    meta:set_float("recipe_time", recipe_time)
    if recipe_time == 0 then
      local mold_item_stack = inv:get_stack("molding_slot",  1)
      local recipe = molding_registry:get_molding_recipe(mold_item_stack, molding_fluid)

      if recipe and inv:room_for_item("output_slot", recipe.result_item_stack) then
        local drained_fluid = FluidMeta.drain_fluid(meta, "molding_tank", recipe.molten_fluid, TANK_CAPACITY, TANK_CAPACITY, false)
        if drained_fluid and drained_fluid.amount == recipe.molten_fluid.amount then
          local drained_fluid = FluidMeta.drain_fluid(meta, "molding_tank", recipe.molten_fluid, TANK_CAPACITY, TANK_CAPACITY, true)
          local result = itemstack_copy(recipe.result_item_stack)
          --print("drained fluid from molten tank", minetest.pos_to_string(pos), FluidStack.pretty_format(drained_fluid))
          inv:add_item("output_slot", result)
          inv:add_item("mold_slot", mold_item_stack)
          inv:remove_item("molding_slot", mold_item_stack)
          meta:set_string("recipe_name", "")
          meta:set_float("recipe_time", 0)
          meta:set_float("recipe_time_max", 0)
          yatm.queue_refresh_infotext(pos)
        end
      end
    else
      energy_consumed = energy_consumed + 5
    end
  else
    ctx:set_up_state("idle")
  end

  return energy_consumed
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local meta = minetest.get_meta(pos)
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_heated" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(
          node_inv_name,
          "mold_slot",
          rect.x,
          rect.y,
          1,
          1
        ) ..
        fspec.list(
          node_inv_name,
          "molding_slot",
          rect.x + cio(2),
          rect.y,
          1,
          1
        ) ..
        fspec.list(
          node_inv_name,
          "output_slot",
          rect.x + cio(4),
          rect.y,
          1,
          1
        ) ..
        yatm_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cio(1),
          rect.y,
          1,
          rect.h,
          meta,
          yatm.devices.ENERGY_BUFFER_KEY,
          yatm.devices.get_energy_capacity(pos, state.node)
        )
    elseif loc == "footer" then
      return fspec.list_ring(node_inv_name, "mold_slot") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(node_inv_name, "output_slot") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_foundry:electric_molder:"..Vector3.to_string(pos)
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

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  fluid_interface_in = 1,
  item_interface_in = 1,
  item_interface_out = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_foundry:electric_molder",

  description = "Electric Molder",

  codex_entry_id = "yatm_foundry:electric_molder",

  groups = groups,

  drop = yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_electric_molder_top.off.png",
    "yatm_electric_molder_bottom.off.png",
    "yatm_electric_molder_side.off.png",
    "yatm_electric_molder_side.off.png",
    "yatm_electric_molder_side.off.png",
    "yatm_electric_molder_side.off.png"
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, -0.5, -0.5, 0.5, (12 / 16.0) - 0.5, 0.5}, -- Base
      {-0.5, (15 / 16.0) - 0.5, -0.5, 0.5, 0.5, 0.5}, -- Cap
      -- Columns
      {(1 / 16.0) - 0.5, (12 / 16.0) - 0.5, (1 / 16.0) - 0.5, (3 / 16.0) - 0.5, (15 / 16.0) - 0.5, (3 / 16.0) - 0.5},
      {(1 / 16.0) - 0.5, (12 / 16.0) - 0.5, (13 / 16.0) - 0.5, (3 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5},
      {(13 / 16.0) - 0.5, (12 / 16.0) - 0.5, (1 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5, (3 / 16.0) - 0.5},
      {(13 / 16.0) - 0.5, (12 / 16.0) - 0.5, (13 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5},
    },
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = yatm_network,
  fluid_interface = fluid_interface,
  item_interface = item_interface,

  refresh_infotext = electric_molder_refresh_infotext,

  on_construct = function (pos)
    yatm.devices.device_on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("mold_slot", 1)
    inv:set_size("molding_slot", 1)
    inv:set_size("output_slot", 1)
  end,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_electric_molder_top.error.png",
      "yatm_electric_molder_bottom.error.png",
      "yatm_electric_molder_side.error.png",
      "yatm_electric_molder_side.error.png",
      "yatm_electric_molder_side.error.png",
      "yatm_electric_molder_side.error.png"
    },
  },
  idle = {
    tiles = {
      "yatm_electric_molder_top.idle.png",
      "yatm_electric_molder_bottom.idle.png",
      "yatm_electric_molder_side.idle.png",
      "yatm_electric_molder_side.idle.png",
      "yatm_electric_molder_side.idle.png",
      "yatm_electric_molder_side.idle.png"
    },
  },
  on = {
    tiles = {
      "yatm_electric_molder_top.on.png",
      "yatm_electric_molder_bottom.on.png",
      "yatm_electric_molder_side.on.png",
      "yatm_electric_molder_side.on.png",
      "yatm_electric_molder_side.on.png",
      "yatm_electric_molder_side.on.png"
    },
  },
})

