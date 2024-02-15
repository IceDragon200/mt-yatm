local mod = yatm_foundry
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)
local Vector3 = assert(foundation.com.Vector3)
local ItemInterface = assert(yatm.items.ItemInterface)

local STATE_NEW = 0
local STATE_CRAFTING = 1
local STATE_OUTPUT = 2

local ERROR_OK = 0
local ERROR_INPUT_IS_EMPTY = 10
local ERROR_OUTPUT_IS_FULL = 20
local ERROR_LEFTOVER_IS_FULL = 30
local ERROR_NOT_ENOUGH_ENERGY = 40

--- Ensures that the inventory is up to date, triggered on construction and whenever the
--- formspec is shown.
local function upsert_inventory_by_meta(meta)
  local inv = meta:get_inventory()
  inv:set_size("input_slot", 1)
  inv:set_size("processing_slot", 1)
  inv:set_size("output_slot", 1)
  inv:set_size("leftover_slot", 1)
end

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
    item_consumer = 1,
    item_producer = 1,
    -- heat_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = mod:make_name("electric_furnace_error"),
    error = mod:make_name("electric_furnace_error"),
    idle = mod:make_name("electric_furnace_idle"),
    off = mod:make_name("electric_furnace_off"),
    on = mod:make_name("electric_furnace_on"),
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 400,
  },
}

--- @spec yatm_network#work(ctx: WorkContext): (energy_consumed: Integer)
function yatm_network:work(ctx)
  local dtime = ctx.dtime
  local energy_consumed = 0
  local node = ctx.node
  local meta = ctx.meta
  local inv = meta:get_inventory()

  local time = meta:get_float("time")
  local time_max = meta:get_float("time_max")
  local craft_state = meta:get_int("craft_state")
  local craft_error = meta:get_int("craft_error")

  while true do
    if craft_state == STATE_NEW then
      local input_list = inv:get_list("input_slot")
      local leftover_list = inv:get_list("leftover_slot")

      local result, leftovers =
        minetest.get_craft_result({
          method = "cooking",
          width = 1,
          items = input_list
        })

      if result.item:is_empty() then
        craft_error = ERROR_INPUT_IS_EMPTY
        break
      else
        local leftover_stack = result.replacements[1]
        if next(result.replacements) then
          if inv:room_for_item("leftover_slot", leftover_stack) then
            inv:add_item("leftover_slot", leftover_stack)
          else
            -- revert
            inv:set_list("leftover_slot", leftover_list)
            craft_error = ERROR_LEFTOVER_IS_FULL
            break
          end
        end

        inv:set_list("input_slot", leftovers.items)

        inv:set_stack("processing_slot", 1, result.item)

        craft_error = ERROR_OK
        time_max = result.time
        time = time_max
        craft_state = STATE_CRAFTING
      end

    elseif craft_state == STATE_CRAFTING then
      if ctx.energy_available >= 0 then
        if time > 0 then
          time = time - dtime
        end
        craft_error = ERROR_OK
      else
        craft_error = ERROR_NOT_ENOUGH_ENERGY
      end

      if time <= 0 then
        craft_state = STATE_OUTPUT
      else
        break
      end

    elseif craft_state == STATE_OUTPUT then
      local stack = inv:get_stack("processing_slot", 1)

      if inv:room_for_item("output_slot", stack) then
        inv:set_stack("processing_slot", 1, ItemStack())
        inv:add_item("output_slot", stack)
        craft_state = STATE_NEW
        craft_error = ERROR_OK
      else
        craft_error = ERROR_OUTPUT_IS_FULL
        break
      end

    else
      minetest.log("warning", "unexpected electric furnace state=" .. craft_state)
      craft_state = STATE_NEW
    end
  end

  meta:set_float("time", time)
  meta:set_float("time_max", time_max)
  meta:set_int("craft_state", craft_state)
  meta:set_int("craft_error", craft_error)

  -- ctx:set_up_state("idle")

  return energy_consumed
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_heated" }, function (loc, rect)
    if loc == "main_body" then
      return ""
        .. fspec.list(
          node_inv_name,
          "input_slot",
          rect.x,
          rect.y,
          1,
          1
        )
        .. fspec.list(
          node_inv_name,
          "processing_slot",
          rect.x + cio(2),
          rect.y,
          1,
          1
        )
        .. fspec.list(
          node_inv_name,
          "output_slot",
          rect.x + cio(3),
          rect.y,
          1,
          1
        )
        .. fspec.list(
          node_inv_name,
          "leftover_slot",
          rect.x + cio(3),
          rect.y + cio(1),
          1,
          1
        )
        .. yatm_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cio(1),
          rect.y,
          1,
          rect.h,
          meta,
          yatm.devices.ENERGY_BUFFER_KEY,
          yatm.devices.get_energy_capacity(pos, state.node)
        )
    elseif loc == "footer" then
      return fspec.list_ring(node_inv_name, "input_slot")
        .. fspec.list_ring("current_player", "main")
        .. fspec.list_ring(node_inv_name, "output_slot")
        .. fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_foundry:electric_furnace:"..Vector3.to_string(pos)
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

local function on_construct(pos)
  yatm.devices.device_on_construct(pos)

  local meta = minetest.get_meta(pos)
  upsert_inventory_by_meta(meta)
end

local function on_rightclick(pos, node, user)
  local meta = minetest.get_meta(pos)
  upsert_inventory_by_meta(meta)

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

local item_interface =
  ItemInterface.new_directional(function (self, pos, dir)
    local node = minetest.get_node(pos)
    local new_dir = Directions.facedir_to_face(node.param2, dir)

    if new_dir == Directions.D_DOWN then
      return "leftover_slot"
    elseif new_dir == Directions.D_UP then
      return "input_slot"
    else
      return "output_slot"
    end
  end)

function item_interface:allow_insert_item(pos, dir, item_stack)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)

  if new_dir == Directions.D_UP then
    -- input_slot
    local result, leftovers =
      minetest.get_craft_result({
        method = "cooking",
        width = 1,
        items = {item_stack}
      })

    return not result.item:is_empty()
  end

  -- only the input can be inserted to
  return false
end

function item_interface:allow_extract_item(pos, dir, item_stack)
  -- All directions can be extracted from
  return true
end

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  item_interface_in = 1,
  item_interface_out = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = mod:make_name("electric_furnace"),

  description = mod.S("Electric Furnace"),

  codex_entry_id = mod:make_name("electric_furnace"),

  groups = groups,

  drop = yatm_network.states.off,

  tiles = {
    "yatm_electric_furnace_top.off.png",
    "yatm_electric_furnace_bottom.png",
    "yatm_electric_furnace_side.off.png",
    "yatm_electric_furnace_side.off.png^[transformFX",
    "yatm_electric_furnace_back.png",
    "yatm_electric_furnace_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = yatm_network,

  refresh_infotext = refresh_infotext,

  on_construct = on_construct,

  on_rightclick = on_rightclick,

  item_interface = item_interface,
}, {
  error = {
    tiles = {
      "yatm_electric_furnace_top.error.png",
      "yatm_electric_furnace_bottom.png",
      "yatm_electric_furnace_side.error.png",
      "yatm_electric_furnace_side.error.png^[transformFX",
      "yatm_electric_furnace_back.png",
      "yatm_electric_furnace_front.error.png"
    },
  },
  idle = {
    tiles = {
      "yatm_electric_furnace_top.idle.png",
      "yatm_electric_furnace_bottom.png",
      "yatm_electric_furnace_side.idle.png",
      "yatm_electric_furnace_side.idle.png^[transformFX",
      "yatm_electric_furnace_back.png",
      "yatm_electric_furnace_front.idle.png"
    },
  },
  on = {
    tiles = {
      "yatm_electric_furnace_top.on.png",
      "yatm_electric_furnace_bottom.png",
      "yatm_electric_furnace_side.on.png",
      "yatm_electric_furnace_side.on.png^[transformFX",
      "yatm_electric_furnace_back.png",
      "yatm_electric_furnace_front.on.png"
    },
    light_source = 7,
  },
})

