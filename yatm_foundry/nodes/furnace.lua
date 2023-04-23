local mod = assert(yatm_foundry)

local fspec = assert(foundation.com.formspec.api)
local table_merge = assert(foundation.com.table_merge)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local cluster_thermal = assert(yatm.cluster.thermal)
local Vector3 = assert(foundation.com.Vector3)
local ItemInterface = assert(yatm.items.ItemInterface)
local player_service = assert(nokore.player_service)

--- @spec refresh_infotext(Vector3): void
local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local heat = meta:get_float("heat")

  meta:set_string("infotext",
    cluster_thermal:get_node_infotext(pos) .. "\n" ..
    "Heat: " .. math.floor(heat)
  )
end

--- @spec maybe_initialize_inventory(MetaRef): void
local function maybe_initialize_inventory(meta)
  local inv = meta:get_inventory()

  inv:set_size("input_slot", 1)
  inv:set_size("processing_slot", 1)
  inv:set_size("output_slot", 1)
  inv:set_size("leftover_slot", 1)
end

--- @spec on_construct(Vector3): void
local function on_construct(pos)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)

  cluster_thermal:schedule_add_node(pos, node)
  maybe_initialize_inventory(meta)
end

local function after_destruct(pos, old_node)
  cluster_thermal:schedule_remove_node(pos, old_node)
end

local STATE_NEW = 0
local STATE_CRAFTING = 1
local STATE_OUTPUT = 2

local ERROR_OK = 0
local ERROR_INPUT_IS_EMPTY = 10
local ERROR_OUTPUT_IS_FULL = 20
local ERROR_LEFTOVER_IS_FULL = 30
local ERROR_NOT_ENOUGH_HEAT = 40

--- @spec on_timer(Vector3, dt: Float): Boolean
local function on_timer(pos, dt)
  local node = minetest.get_node_or_nil(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local time = meta:get_float("time")
  local time_max = meta:get_float("time_max")
  local heat = meta:get_float("heat")
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
      if heat > 100 then
        if time > 0 then
          time = time - dt
        end
        craft_error = ERROR_OK
      else
        craft_error = ERROR_NOT_ENOUGH_HEAT
      end

      if time < 0 then
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
      minetest.log("warning", "unexpected furnace state=" .. craft_state)
      craft_state = STATE_NEW
    end
  end

  meta:set_float("time", time)
  meta:set_float("time_max", time_max)
  meta:set_int("craft_state", craft_state)
  meta:set_int("craft_error", craft_error)

  return true
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local meta = minetest.get_meta(pos)
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size

  return yatm.formspec_render_split_inv_panel(user, 4, 4, { bg = "machine_heated" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(
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
  return "yatm_foundry:furnace:"..Vector3.to_string(pos)
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
    return true
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
  heatable_device = 1,
  yatm_cluster_thermal = 1,
}

yatm.register_stateful_node(mod:make_name("furnace"), {
  basename = mod:make_name("furnace"),

  base_description = mod.S("Furnace"),
  description = mod.S("Furnace"),

  codex_entry_id = mod:make_name("furnace"),

  groups = groups,

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("stone"),

  on_construct = on_construct,
  after_destruct = after_destruct,
  on_timer = on_timer,

  refresh_infotext = refresh_infotext,

  on_rightclick = on_rightclick,

  item_interface = item_interface,

  thermal_interface = {
    groups = {
      heater = 1,
      thermal_user = 1,
    },

    update_heat = function (self, pos, node, heat, dtime)
      local meta = minetest.get_meta(pos)

      if yatm.thermal.update_heat(meta, "heat", heat, 10, dtime) then
        local new_name
        if math.floor(heat) > 0 then
          new_name = "yatm_foundry:furnace_on"
        else
          new_name = "yatm_foundry:furnace_off"
        end
        if new_name ~= node.name then
          node.name = new_name
          minetest.swap_node(pos, node)
        end

        maybe_start_node_timer(pos, 1.0)
        yatm.queue_refresh_infotext(pos, node)
      end
    end,
  },
}, {
  off = {
    tiles = {
      "yatm_furnace_top.off.png",
      "yatm_furnace_bottom.off.png",
      "yatm_furnace_side.off.png",
      "yatm_furnace_side.off.png^[transformFX",
      "yatm_furnace_back.off.png",
      "yatm_furnace_front.off.png"
    },

  },
  on = {
    groups = table_merge(groups, {
      not_in_creative_inventory = 1
    }),

    tiles = {
      "yatm_furnace_top.on.png",
      "yatm_furnace_bottom.on.png",
      "yatm_furnace_side.on.png",
      "yatm_furnace_side.on.png^[transformFX",
      "yatm_furnace_back.on.png",
      "yatm_furnace_front.on.png"
    },
  }
})
