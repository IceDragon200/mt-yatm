--[[

  DSCS Drive Case - or Drive Rack, if you'd like

  Actually that gives me an idea, a drive rack!

]]
local Energy = assert(yatm.energy)
local Vector3 = assert(foundation.com.Vector3)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)

local DRIVE_BAY_SIZE = 8

-- @spec.private render_formspec(pos: Vector3, user: PlayerRef, state: Table): String
local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "dscs" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(node_inv_name, "drive_bay", rect.x, rect.y, 2, 4) ..
        yatm.dscs.formspec.render_inventory_controller_at{
          pos = pos,
          node = state.node,
          x = rect.x + cio(3),
          y = rect.y,
          w = 1,
          h = 1
        } ..
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
      return fspec.list_ring(node_inv_name, "drive_bay") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)
  local inv = meta:get_inventory()
  local needs_refresh = false

  -- TODO: do stuff

  return true
end

local function make_formspec_name(pos)
  return "yatm_dscs:drive_case:" .. minetest.pos_to_string(pos)
end

local function refresh_formspec(pos, _player)
  nokore.formspec_bindings:trigger_form_timer(make_formspec_name(pos), "refresh")
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

-- @spec.private on_rightclick(
--   pos: Vector3,
--   node: NodeRef,
--   user: PlayerRef,
--   item_stack: ItemStack,
--   pointed_thing: PointedThing
-- ): void
local function on_rightclick(pos, node, user, item_stack, pointed_thing)
  local state = {
    pos = pos,
    node = node
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

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    "Drive Case\n" ..
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local drive_case_yatm_network = {
  kind = "machine",

  groups = {
    drive_case = 1,
    energy_consumer = 1,
    dscs_storage_module = 1,
  },

  default_state = "off",
  states = {
    conflict = "yatm_dscs:drive_case_error",
    error = "yatm_dscs:drive_case_error",
    idle = "yatm_dscs:drive_case_idle",
    off = "yatm_dscs:drive_case_off",
    on = "yatm_dscs:drive_case_on",
  },

  energy = {
    capacity = 4000,
    network_charge_bandwidth = 100,
    passive_lost = 10,
  },
}

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  if from_list == "drive_bay" and to_list == "drive_bay" then
    return 1
  end
  return 0
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "drive_bay" then
    if yatm.dscs.is_item_stack_inventory_drive(stack) then
      return 1
    end
  end
  return 0
end

local function persist_drive_contents(pos, index)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local drive_stack = inv:get_stack("drive_bay", index)
  if not drive_stack:is_empty() then
    local list = inv:get_list("drive_contents_" .. index)
    drive_stack = yatm.dscs.persist_inventory_list_to_drive(drive_stack, list)
    inv:set_stack("drive_bay", index, drive_stack)
  end
end

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  print("Moving stack from " .. from_list .. " to " .. to_list)

  if from_list == "drive_bay" or to_list == "drive_bay" then
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    local from_stack = inv:get_stack("drive_bay", from_index)
    local to_stack = inv:get_stack("drive_bay", to_index)

    if yatm.dscs.is_item_stack_item_drive(from_stack) and
       yatm.dscs.is_item_stack_item_drive(to_stack) then
      -- if both drives are inventory drives, swap around their drive contents

      local from_list = inv:get_list("drive_contents_" .. from_index)
      local to_list = inv:get_list("drive_contents_" .. to_index)

      inv:set_list("drive_contents_" .. to_index, from_list)
      inv:set_list("drive_contents_" .. from_index, to_list)
    else
      if yatm.dscs.is_item_stack_item_drive(from_stack) then
        local to_list = inv:get_list("drive_contents_" .. to_index)
        inv:set_list("drive_contents_" .. from_index, to_list)
        inv:set_size("drive_contents_" .. to_index, 0)
      end

      if yatm.dscs.is_item_stack_item_drive(to_stack) then
        local from_list = inv:get_list("drive_contents_" .. from_index)
        inv:set_list("drive_contents_" .. to_index, from_list)
        inv:set_size("drive_contents_" .. from_index, 0)
      end
    end

    persist_drive_contents(pos, from_index)
    persist_drive_contents(pos, to_index)
  end
end

local function get_fluid_inventory_name(pos, index)
  return "yatm_dscs:drive_case_fluid_drive_contents_" .. index .. "_" .. Vector3.to_string(pos, "_")
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "drive_bay" then
    local meta = minetest.get_meta(pos)

    if yatm.dscs.is_item_stack_item_drive(stack) then
      local inv = meta:get_inventory()

      local list, capacity = yatm.dscs.load_inventory_list_from_drive(stack)

      inv:set_size("drive_contents_" .. index, capacity)
      inv:set_list("drive_contents_" .. index, list)

      refresh_formspec(pos, player)

      minetest.log("action", player:get_player_name() .. " installed an item drive")
    elseif yatm.dscs.is_item_stack_fluid_drive(stack) then
      --
      local fluid_inventory_name = get_fluid_inventory_name(pos, index)
      local fluid_inventory = yatm.dscs.load_fluid_inventory_from_drive(fluid_inventory_name, stack)
      meta:set_string("fluid_drive_contents_" .. index, fluid_inventory:serialize())

      refresh_formspec(pos, player)

      minetest.log("action", player:get_player_name() .. " installed a fluid drive")
    end
  end
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "drive_bay" then
    if yatm.dscs.is_item_stack_item_drive(stack) then
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()

      inv:set_size("drive_contents_" .. index, 0)

      refresh_formspec(pos, player)

      minetest.log("action", player:get_player_name() .. " removed a drive")
    elseif yatm.dscs.is_item_stack_fluid_drive(stack) then
      local fluid_inventory_name = get_fluid_inventory_name(pos, index)
      yatm.fluids.fluid_inventories:destroy_fluid_inventory(fluid_inventory_name)

      refresh_formspec(pos, player)

      minetest.log("action", player:get_player_name() .. " removed a drive")
    end
  end
end

function drive_case_yatm_network.on_load(pos, node)
  -- reload fluid inventories
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  for i = 1,DRIVE_BAY_SIZE do
    local stack = inv:get_stack("drive_bay", i)
    if yatm.dscs.is_item_stack_fluid_drive(stack) then
      local fluid_inventory_name = get_fluid_inventory_name(pos, i)
      local fluid_inventory = yatm.dscs.overload_fluid_inventory_from_drive(fluid_inventory_name, stack)
      meta:set_string("fluid_drive_contents_" .. i, fluid_inventory:serialize())
    end
  end
end

function drive_case_yatm_network.on_unload(pos, node)
  -- unload fluid inventories
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  for i = 1,DRIVE_BAY_SIZE do
    local stack = inv:get_stack("drive_bay", i)
    if yatm.dscs.is_item_stack_fluid_drive(stack) then
      local fluid_inventory_name = get_fluid_inventory_name(pos, i)
      local fluid_inventory = yatm.fluid.fluid_inventories:get_fluid_inventory(fluid_inventory_name)
      if fluid_inventory then
        meta:set_string("fluid_drive_contents_" .. i, fluid_inventory:serialize())
      end
      yatm.fluids.fluid_inventories:destroy_fluid_inventory(fluid_inventory_name)
    end
  end
end

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  yatm_dscs_device = 1,
  yatm_energy_device = 1,
  yatm_network_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:drive_case",

  codex_entry_id = "yatm_dscs:drive_case",
  description = "Drive Case",

  groups = groups,

  drop = drive_case_yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_drive_case_top.off.png",
    "yatm_drive_case_bottom.png",
    "yatm_drive_case_side.off.png",
    "yatm_drive_case_side.off.png^[transformFX",
    "yatm_drive_case_back.off.png",
    "yatm_drive_case_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = drive_case_yatm_network,

  refresh_infotext = refresh_infotext,

  on_construct = function (pos)
    yatm.devices.device_on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("drive_bay", DRIVE_BAY_SIZE)
  end,

  on_rightclick = on_rightclick,

  allow_metadata_inventory_move = allow_metadata_inventory_move,
  allow_metadata_inventory_put = allow_metadata_inventory_put,
  on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,

  on_dig = function (pos, node, digger)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    if inv:is_empty("drive_bay") then
      return minetest.node_dig(pos, node, digger)
    end

    return false
  end,
}, {
  on = {
    tiles = {
      "yatm_drive_case_top.on.png",
      "yatm_drive_case_bottom.png",
      "yatm_drive_case_side.on.png",
      "yatm_drive_case_side.on.png^[transformFX",
      "yatm_drive_case_back.on.png",
      "yatm_drive_case_front.on.png"
    },
  },
  idle = {
    tiles = {
      "yatm_drive_case_top.idle.png",
      "yatm_drive_case_bottom.png",
      "yatm_drive_case_side.idle.png",
      "yatm_drive_case_side.idle.png^[transformFX",
      "yatm_drive_case_back.idle.png",
      "yatm_drive_case_front.idle.png"
    },
  },
  error = {
    tiles = {
      "yatm_drive_case_top.error.png",
      "yatm_drive_case_bottom.png",
      "yatm_drive_case_side.error.png",
      "yatm_drive_case_side.error.png^[transformFX",
      "yatm_drive_case_back.error.png",
      "yatm_drive_case_front.error.png"
    },
  }
})
