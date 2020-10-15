--
-- Void chests can view the contents of an item drive.
-- And only an item drive.
--
local Energy = assert(yatm.energy)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local fspec = assert(foundation.com.formspec.api)

local function get_formspec_name(pos)
  return "yatm_dscs:void_chest:" .. minetest.pos_to_string(pos)
end

local function get_void_chest_formspec(pos, entity, assigns)
  local meta = minetest.get_meta(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local inv = meta:get_inventory()
  local stack = inv:get_stack("drive_slot", 1)
  local label = ""
  local capacity = 0
  assigns.drive_contents_offset = assigns.drive_contents_offset or 0

  if yatm.dscs.is_item_stack_item_drive(stack) then
    capacity = stack:get_definition().drive_capacity
    label = stack:get_meta():get_string("drive_label")
  end

  local cols = yatm.get_player_hotbar_size(entity)
  local rows = 4

  local w = yatm.get_player_hotbar_size(entity)
  local h = 10

  local page_size = rows * cols

  local formspec =
    fspec.size(w, h) ..
    yatm.formspec_bg_for_player(entity:get_player_name(), "dscs")

  local row_count = math.ceil(capacity / page_size)
  assigns.drive_contents_offset = math.min(math.max(assigns.drive_contents_offset, 0), row_count - 1)
  local row_offset = assigns.drive_contents_offset * page_size

  formspec =
    formspec ..
    fspec.label(0, 0, "Void Chest") ..
    fspec.list("nodemeta:"..spos, "drive_slot", 0, 0.5, 1, 1)

  if capacity > 0 then
    formspec =
      formspec ..
      fspec.field_area(1.25, 1, w - 1, 1, "drive_label", "Drive Label", label) ..
      fspec.list("nodemeta:"..spos, "drive_contents", 0, 1.5, cols, rows, row_offset)
  end

  formspec =
    formspec ..
    yatm.player_inventory_lists_fragment(entity, 0, 5.85) ..
    fspec.list_ring("current_player", "main")

  if capacity > 0 then
    formspec =
      formspec ..
      fspec.list_ring("nodemeta:"..spos, "drive_contents") ..
      fspec.list_ring("current_player", "main")
  end

  if row_count > 1 then
    formspec =
      formspec ..
      fspec.button(w - 1, 1.5, 1, 1, "up", "Up") ..
      fspec.label(w - 1, 3.5, (assigns.drive_contents_offset + 1) .. "/" .. row_count) ..
      fspec.button(w - 1, 4.5, 1, 1, "down", "Down")
  end

  return formspec
end

local function refresh_formspec(pos, player)
  minetest.after(0, function ()
    yatm_core.refresh_player_formspec(player, get_formspec_name(pos), function (ply, assigns)
      return get_void_chest_formspec(assigns.pos, ply, assigns)
    end)
  end)
end

local void_chest_yatm_network = {
  kind = "machine",
  groups = {
    dscs_device = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:void_chest_error",
    error = "yatm_dscs:void_chest_error",
    off = "yatm_dscs:void_chest_off",
    on = "yatm_dscs:void_chest_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 1,
    network_charge_bandwidth = 400,
    startup_threshold = 100,
  },
}

local groups = {
  cracky = 1,
  item_interface_out = 1,
  item_interface_in = 1,
  yatm_energy_device = 1,
  yatm_network_device = 1,
}

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  if from_list == "drive_slot" then
    if to_list == "drive_contents" then
      return 0
    end
    return count
  elseif from_list == "drive_contents" then
    if to_list == "drive_slot" then
      return 0
    end
    return count
  end
  return count
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "drive_slot" then
    if yatm.dscs.is_item_stack_item_drive(stack) then
      return 1
    end
  elseif listname == "drive_contents" then
    return stack:get_count()
  end
  return 0
end

local function persist_drive_contents(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local drive_stack = inv:get_stack("drive_slot", 1)
  if not drive_stack:is_empty() then
    local list = inv:get_list("drive_contents")
    drive_stack = yatm.dscs.persist_inventory_list_to_drive(drive_stack, list)
    inv:set_stack("drive_slot", 1, drive_stack)
  end
end

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  if from_list == "drive_contents" or to_list == "drive_contents" then
    persist_drive_contents(pos)
  end
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "drive_slot" then
    if yatm.dscs.is_item_stack_item_drive(stack) then
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()

      local list, capacity = yatm.dscs.load_inventory_list_from_drive(stack)

      inv:set_size("drive_contents", capacity)
      inv:set_list("drive_contents", list)

      refresh_formspec(pos, player)

      minetest.log("action", player:get_player_name() .. " installed a drive")
    end
  elseif listname == "drive_contents" then
    persist_drive_contents(pos)
  end
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "drive_slot" then
    if yatm.dscs.is_item_stack_item_drive(stack) then
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()

      inv:set_size("drive_contents", 0)

      refresh_formspec(pos, player)

      minetest.log("action", player:get_player_name() .. " removed a drive")
    end
  end
end

local function receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)
  local inv = meta:get_inventory()
  local needs_refresh = false

  if fields["drive_label"] then
    local stack = inv:get_stack("drive_slot", 1)
    if not stack:is_empty() then
      if yatm.dscs.is_item_stack_item_drive(stack) then
        yatm.dscs.set_drive_label(stack, fields["drive_label"])

        inv:set_stack("drive_slot", 1, stack)
      end
    end
  end

  if fields["up"] then
    assigns.drive_contents_offset = assigns.drive_contents_offset - 1
    needs_refresh = true
  end

  if fields["down"] then
    assigns.drive_contents_offset = assigns.drive_contents_offset + 1
    needs_refresh = true
  end

  if needs_refresh then
    return true, get_void_chest_formspec(assigns.pos, player, assigns)
  else
    return true
  end
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:void_chest",

  codex_entry_id = "yatm_dscs:void_chest",
  description = "Void Chest\nInstall a Item Drive to access it's contents.",

  groups = groups,

  drop = void_chest_yatm_network.states.off,

  tiles = {
    "yatm_void_chest_top.off.png",
    "yatm_void_chest_bottom.png",
    "yatm_void_chest_side.off.png",
    "yatm_void_chest_side.off.png^[transformFX",
    "yatm_void_chest_back.off.png",
    "yatm_void_chest_front.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  on_construct = function (pos)
    local node = minetest.get_node(pos)

    yatm.devices.device_on_construct(pos)
    local meta = minetest.get_meta(pos)

    local inv = meta:get_inventory()
    inv:set_size("drive_slot", 1)
  end,

  allow_metadata_inventory_move = allow_metadata_inventory_move,
  allow_metadata_inventory_put = allow_metadata_inventory_put,

  on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,

  on_dig = function (pos, node, digger)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    if inv:is_empty("drive_slot") then
      return minetest.node_dig(pos, node, digger)
    end

    return false
  end,

  yatm_network = void_chest_yatm_network,

  on_rightclick = function (pos, node, user, item_stack, pointed_thing)
    local assigns = { pos = pos, node = node }
    local formspec = get_void_chest_formspec(pos, user, assigns)
    local formspec_name = get_formspec_name(pos)

    yatm_core.bind_on_player_receive_fields(user, formspec_name,
                                            assigns,
                                            receive_fields)

    minetest.show_formspec(
      user:get_player_name(),
      formspec_name,
      formspec
    )
  end,

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)

    local infotext =
      "Void Chest\n" ..
      cluster_devices:get_node_infotext(pos) .. "\n" ..
      cluster_energy:get_node_infotext(pos) .. " [" .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "]\n"

    meta:set_string("infotext", infotext)
  end,
}, {
  error = {
    tiles = {
      "yatm_void_chest_top.error.png",
      "yatm_void_chest_bottom.png",
      "yatm_void_chest_side.error.png",
      "yatm_void_chest_side.error.png^[transformFX",
      "yatm_void_chest_back.error.png",
      "yatm_void_chest_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_void_chest_top.on.png",
      "yatm_void_chest_bottom.png",
      {
        name = "yatm_void_chest_side.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2
        },
      },
      {
        name = "yatm_void_chest_side.on.png^[transformFX",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2
        },
      },
      "yatm_void_chest_back.on.png",
      "yatm_void_chest_front.on.png",
    },
  }
})
