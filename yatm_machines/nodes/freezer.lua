--[[

  Freezers solidify liquids, primarily water into ice for transport

  Can also freeze some items, just be careful with glass.

]]
local mod = yatm_machines
local Directions = assert(foundation.com.Directions)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidStack = assert(yatm.fluids.FluidStack)
local ItemInterface = assert(yatm.items.ItemInterface)
local Vector3 = assert(foundation.com.Vector3)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)
local freezing_registry = assert(yatm.freezing.freezing_registry)

local ITEM_INV_SIZE = 9

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
  local node = minetest.get_node(pos)

  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_UP or
     new_dir == Directions.D_DOWN then
    return "output_items"
  else
    return "input_items"
  end
end)

local fluid_interface = FluidInterface.new_simple("tank", 4000)

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:freezer_error",
    error = "yatm_machines:freezer_error",
    off = "yatm_machines:freezer_off",
    on = "yatm_machines:freezer_on",
  },
  energy = {
    capacity = 8000,
    passive_lost = 0,
    network_charge_bandwidth = 200,
    startup_threshold = 100,
  },
}

function yatm_network:work(ctx)
  --
  -- So the freezer takes either fluids or input items and then, well freezes them
  -- In the case of fluids, they need to be registered with a transition fluid
  -- And a duration, since the freezer accepts up to 9 items (and 1 fluid),
  -- it can operate on 10 elements at a time, BUT, it can only store the result of
  -- 9 of those, so be careful.
  --
  local span

  local pos = ctx.pos
  local meta = ctx.meta
  local node = ctx.node
  local dtime = ctx.dtime

  local inv = meta:get_inventory()

  if ctx.trace then
    span = ctx.trace:span_start("fluid")
  end
  -- input0 is reserved for the fluid
  do
    local remaining_dtime = dtime
    local fluid_stack
    local recipe
    local recipe_name
    local item_time
    local item_duration
    local new_item_time

    fluid_stack = FluidMeta.get_fluid_stack(meta, "tank")

    if not FluidStack.is_empty(fluid_stack) then
      while remaining_dtime > 0 do
        fluid_stack = FluidMeta.get_fluid_stack(meta, "tank")

        recipe = freezing_registry:find_fluid_freezing_recipe(fluid_stack)

        if recipe then
          recipe_name = meta:get_string("recipe_name_0")

          if recipe.name ~= recipe_name then
            meta:set_string("recipe_name_0", recipe.name)
            meta:set_float("input_time_0", recipe.duration)
            meta:set_float("input_duration_0", recipe.duration)
          end

          item_time = meta:get_int("input_time_0")
          item_duration = meta:get_int("input_duration_0")

          new_item_time = math.max(item_time - remaining_dtime, 0)

          meta:set_float("input_time_0", new_item_time)
          remaining_dtime = remaining_dtime - (item_time - new_item_time)

          item_time = meta:get_float("input_time_0")

          if item_time <= 0 then
            -- try adding the result
            if inv:room_for_item(recipe.output_item_stack) then
              item_stack:take_item(recipe.input_item_stack:get_count())
              inv:set_stack("input_items", i, item_stack)
              inv:add_item("output_items", recipe.output_item_stack)

              meta:set_string("recipe_name_0", "")
              meta:set_float("input_time_0", -1)
              meta:set_float("input_duration_0", -1)
            else
              -- hold the items until the next work step
              break
            end
          else
            break
          end
        else
          meta:set_string("recipe_name_0", "")
          meta:set_float("input_time_0", -1)
          meta:set_float("input_duration_0", -1)
          break
        end
      end
    end
  end
  if span then
    span:span_end()
  end

  if ctx.trace then
    span = ctx.trace:span_start("items")
  end
  -- input1..(ITEM_INV_SIZE) is for items
  if not inv:is_empty("input_items") then
    local item_stack
    local recipe
    local recipe_name
    local item_time
    local item_duration
    local new_item_time
    local remaining_dtime

    for i = 1,ITEM_INV_SIZE do
      remaining_dtime = dtime

      while remaining_dtime > 0 do
        item_stack = inv:get_stack("input_items", i)

        if item_stack:is_empty() then
          meta:set_string("recipe_name_" .. i, "")
          meta:set_float("input_time_" .. i, -1)
          meta:set_float("input_duration_" .. i, -1)
          break
        else
          recipe = freezing_registry:find_item_freezing_recipe(item_stack)

          if recipe then
            recipe_name = meta:get_string("recipe_name_" .. i)

            if recipe.name ~= recipe_name then
              meta:set_string("recipe_name_" .. i, recipe.name)
              meta:set_float("input_time_" .. i, recipe.duration)
              meta:set_float("input_duration_" .. i, recipe.duration)
            end

            item_time = meta:get_int("input_time_" .. i)
            item_duration = meta:get_int("input_duration_" .. i)

            new_item_time = math.max(item_time - remaining_dtime, 0)

            meta:set_float("input_time_" .. i, new_item_time)
            remaining_dtime = remaining_dtime - (item_time - new_item_time)

            item_time = meta:get_float("input_time_" .. i)

            if item_time <= 0 then
              -- try adding the result
              if inv:room_for_item(recipe.output_item_stack) then
                item_stack:take_item(recipe.input_item_stack:get_count())
                inv:set_stack("input_items", i, item_stack)
                inv:add_item("output_items", recipe.output_item_stack)

                meta:set_string("recipe_name_" .. i, "")
                meta:set_float("input_time_" .. i, -1)
                meta:set_float("input_duration_" .. i, -1)
              else
                -- hold the items until the next work step
                break
              end
            else
              break
            end
          else
            meta:set_string("recipe_name_" .. i, "")
            meta:set_float("input_time_" .. i, -1)
            meta:set_float("input_duration_" .. i, -1)
            break
          end
        end
      end
    end
  end
  if span then
    span:span_end()
  end

  -- yeah 100 units, regardless
  return 100 * dtime
end

local function maybe_initialize_inventory(meta)
  local inv = meta:get_inventory()
  inv:set_size("input_items", ITEM_INV_SIZE)
  inv:set_size("output_items", ITEM_INV_SIZE)

  for i = 0,ITEM_INV_SIZE do
    meta:set_int("input_time_" .. i, -1)
    meta:set_int("input_duration_" .. i, -1)
  end
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)

  maybe_initialize_inventory(meta)

  yatm.devices.device_on_construct(pos)
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local meta = minetest.get_meta(pos)
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_cooled" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(node_inv_name, "input_items", rect.x, rect.y, 3, 3) ..
        fspec.list(node_inv_name, "output_items", rect.x + cio(3.5), rect.y, 3, 3) ..
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
      return fspec.list_ring(node_inv_name, "input_items") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(node_inv_name, "output_items") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_machines:freezer:"..Vector3.to_string(pos)
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
  local meta = minetest.get_meta(pos)
  maybe_initialize_inventory(meta)

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

local function on_dig(pos, node, digger)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  if inv:is_empty("input_items") and inv:is_empty("output_items") then
    return minetest.node_dig(pos, node, digger)
  end

  return false
end

local function on_blast(pos, node)

end

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  yatm_energy_device = 1,
  yatm_network_device = 1,
  fluid_interface_in = 1,
  item_interface_in = 1,
  item_interface_out = 1,
}

yatm.devices.register_stateful_network_device({
  basename = mod:make_name("freezer"),

  codex_entry_id = mod:make_name("freezer"),

  description = mod.S("Freezer"),

  groups = groups,

  drop = yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_freezer_top.off.png",
    "yatm_freezer_bottom.off.png",
    "yatm_freezer_side.off.png",
    "yatm_freezer_side.off.png",
    "yatm_freezer_side.off.png",
    "yatm_freezer_side.off.png"
  },
  paramtype = "none",
  paramtype2 = "facedir",

  on_construct = on_construct,

  yatm_network = yatm_network,
  item_interface = item_interface,
  fluid_interface = fluid_interface,

  refresh_infotext = refresh_infotext,

  on_dig = on_dig,
  -- on_blast = on_blast, -- TODO

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_freezer_top.error.png",
      "yatm_freezer_bottom.error.png",
      "yatm_freezer_side.error.png",
      "yatm_freezer_side.error.png",
      "yatm_freezer_side.error.png",
      "yatm_freezer_side.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_freezer_top.on.png",
      "yatm_freezer_bottom.on.png",
      "yatm_freezer_side.on.png",
      "yatm_freezer_side.on.png",
      "yatm_freezer_side.on.png",
      "yatm_freezer_side.on.png",
    },
  },
})
