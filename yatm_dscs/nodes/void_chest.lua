--
-- Void chests can view the contents of an item drive.
-- And only an item drive.
--
local Energy = assert(yatm.energy)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local player_service = assert(nokore.player_service)
local fspec = assert(foundation.com.formspec.api)

local function get_formspec_name(pos)
  return "yatm_dscs:void_chest:" .. minetest.pos_to_string(pos)
end

local function get_formspec(pos, user, assigns)
  assert(pos, "expected a node position")
  assert(user, "expected a user")
  assert(assigns, "expected assigns")

  local meta = minetest.get_meta(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local inv = meta:get_inventory()
  local stack = inv:get_stack("drive_slot", 1)
  local label = ""
  local capacity = 0

  local cols = yatm.get_player_hotbar_size(user)
  local rows = 4

  local page_size = rows * cols
  local row_count = math.ceil(capacity / page_size)

  assigns.drive_contents_offset = assigns.drive_contents_offset or 0
  assigns.drive_contents_offset =
    math.max(math.min(assigns.drive_contents_offset, row_count - 1), 0)

  local row_offset = assigns.drive_contents_offset * page_size

  if yatm.dscs.is_item_stack_item_drive(stack) then
    capacity = stack:get_definition().drive_capacity
    label = stack:get_meta():get_string("drive_label")
  end

  return yatm.formspec_render_split_inv_panel(user, cols + 1, rows + 1, { bg = "dscs" }, function (loc, rect)
    if loc == "main_body" then
      local blob = fspec.list(node_inv_name, "drive_slot", rect.x, rect.y, 1, 1)

      if capacity > 0 then
        local fw = rect.w - 1
        local fh = 1

        blob =
          blob ..
          fspec.field_area(rect.x + 1, rect.y, fw, fh, "drive_label", "Drive Label", label) ..
          fspec.list(node_inv_name, "drive_contents", rect.x, rect.y + cio(1), cols, rows, row_offset)
      end

      if row_count > 1 then
        local px = rect.x + w - 1

        blob =
          blob ..
          fspec.button(px, rect.y + cio(1), 1, 1, "pgup", "Up") ..
          fspec.label(px, rect.y + cio(2), (assigns.drive_contents_offset + 1) .. "/" .. row_count) ..
          fspec.button(px, rect.y + cio(3), 1, 1, "pgdown", "Down")
      end

      return blob
    elseif loc == "footer" then
      if capacity > 0 then
        return fspec.list_ring("nodemeta:"..spos, "drive_contents") ..
               fspec.list_ring("current_player", "main")
      end
    end
    return ""
  end)
end

local function refresh_formspec(pos)
  nokore.formspec_bindings:refresh_formspecs(get_formspec_name(pos), function (player_name, assigns)
    local player = player_service:get_player_by_name(player_name)
    return get_formspec(pos, player, assigns)
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

local function on_metadata_inventory_put(pos, listname, index, item_stack, player)
  if listname == "drive_slot" then
    if yatm.dscs.is_item_stack_item_drive(item_stack) then
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()

      local list, capacity = yatm.dscs.load_inventory_list_from_drive(item_stack)

      inv:set_size("drive_contents", capacity)
      inv:set_list("drive_contents", list)
      meta:set_string("drive_label", yatm.dscs.get_drive_label(item_stack))

      refresh_formspec(pos)

      minetest.log("action", player:get_player_name() .. " installed a drive")
    end
  elseif listname == "drive_contents" then
    persist_drive_contents(pos)
  end
end

local function on_metadata_inventory_take(pos, listname, index, item_stack, player)
  if listname == "drive_slot" then
    if yatm.dscs.is_item_stack_item_drive(item_stack) then
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()

      inv:set_size("drive_contents", 0)
      meta:set_string("drive_label", "")

      refresh_formspec(pos)

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

  if fields["pgup"] then
    assigns.drive_contents_offset = assigns.drive_contents_offset - 1
    needs_refresh = true
  end

  if fields["pgdown"] then
    assigns.drive_contents_offset = assigns.drive_contents_offset + 1
    needs_refresh = true
  end

  if needs_refresh then
    return true, get_formspec(assigns.pos, player, assigns)
  else
    return true
  end
end

local function on_rightclick(pos, node, user, item_stack, pointed_thing)
  local assigns = { pos = pos, node = node }
  local formspec = get_formspec(pos, user, assigns)
  local formspec_name = get_formspec_name(pos)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    formspec_name,
    formspec,
    {
      state = assigns,
      on_receive_fields = receive_fields
    }
  )
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:void_chest",

  codex_entry_id = "yatm_dscs:void_chest",
  description = "Void Chest\nInstall a Item Drive to access it's contents.",

  groups = groups,

  drop = void_chest_yatm_network.states.off,

  use_texture_alpha = "opaque",
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

  on_rightclick = on_rightclick,

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
