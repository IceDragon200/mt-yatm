--
-- Void crates can view the contents of a fluid drive, and only a fluid drive.
--
local mod = assert(yatm_dscs)
local Energy = assert(yatm.energy)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local Vector3 = assert(foundation.com.Vector3)

local VSN = 2

local function migrate(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  -- This is the locked slot - the drive cannot be removed normally from this slot
  inv:set_size("drive_slot", 1)
  -- This is the open slot, while a drive is present here its contents are accessible
  inv:set_size("drive_slot_input", 1)

  meta:set_int("vsn", VSN)

  return true
end

--- @spec.private refresh_infotext(pos: Vector3): void
local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local infotext =
    mod.S("Void Crate") .. "\n" ..
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. " [" .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "]\n"

  local stack = inv:get_stack("drive_slot", 1)

  if not stack:is_empty() then
    local label = stack:get_meta():get_string("drive_label")
    infotext = infotext .. "Drive Label: " .. label
  end

  meta:set_string("infotext", infotext)
end

--- @spec.private persist_drive_contents(pos: Vector3): void
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

--- @spec.private get_fluid_inventory_name(pos: Vector3): String
local function get_fluid_inventory_name(pos)
  return "yatm_dscs:drive_case_fluid_drive_contents:" .. Vector3.to_string(pos, "_")
end

--- @spec.private get_formspec_name(pos: Vector3): String
local function get_formspec_name(pos)
  return "yatm_dscs:void_crate:" .. minetest.pos_to_string(pos)
end

local function refresh_fluid_inventory(pos)
  --
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local stack = inv:get_stack("drive_slot", 1)

  local fluid_inventory_name = get_fluid_inventory_name(pos)
  if yatm.dscs.is_item_stack_fluid_drive(stack) then
    local fluid_inventory = yatm.dscs.load_fluid_inventory_from_drive(fluid_inventory_name, stack)

    meta:set_string("fluid_drive_contents", fluid_inventory:serialize())
  else
    yatm.fluids.fluid_inventories:destroy_fluid_inventory(fluid_inventory_name)

    meta:set_string("fluid_drive_contents", "")
  end
end

--- @spec.private destroy_fluid_inventory(pos: Vector3): void
local function destroy_fluid_inventory(pos)
  local fluid_inventory_name = get_fluid_inventory_name(pos)
  yatm.fluids.fluid_inventories:destroy_fluid_inventory(fluid_inventory_name)
end

--- @spec.private get_fluid_inventory(pos: Vector3): void
local function get_fluid_inventory(pos)
  local fluid_inventory_name = get_fluid_inventory_name(pos)
  return yatm.fluids.fluid_inventories:get_fluid_inventory(fluid_inventory_name)
end

--- @spec.private swap_drives(pos: Vector3): void
local function swap_drives(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local installed_stack = inv:get_stack("drive_slot", 1)
  local input_stack = inv:get_stack("drive_slot_input", 1)

  local can_swap =
    (installed_stack:is_empty() or yatm.dscs.is_item_stack_fluid_drive(installed_stack)) and
    (input_stack:is_empty() or yatm.dscs.is_item_stack_fluid_drive(input_stack))

  if can_swap then
    --- persist existing drive (if applicable)
    persist_drive_contents(pos)
    --- destroy the existing fluid inventory
    destroy_fluid_inventory(pos)

    -- swap the drives
    inv:set_stack("drive_slot", 1, input_stack)
    inv:set_stack("drive_slot_input", 1, installed_stack)

    -- rebuild the fluid inventory using the new drive (if possible)
    refresh_fluid_inventory(pos)
  else
    minetest.log("error", "cannot swap drives must be an empty item stack or inventory drive")
  end
end

--- @spec.private set_drive_label(pos: Vector3, label: String): void
local function set_drive_label(pos, label)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local stack = inv:get_stack("drive_slot", 1)
  if not stack:is_empty() then
    if yatm.dscs.is_item_stack_item_drive(stack) then
      yatm.dscs.set_drive_label(stack, label)

      inv:set_stack("drive_slot", 1, stack)
    end
  end
end

--- @spec.private refresh_formspec(pos: Vector3): void
local function refresh_formspec(pos)
  nokore.formspec_bindings:refresh_formspecs(get_formspec_name(pos), function (player_name, assigns)
    local player = player_service:get_player_by_name(player_name)
    return render_formspec(pos, player, assigns)
  end)
end

--- @spec.private render_formspec(pos: Vector3, user: PlayerRef, assigns: Table): String
local function render_formspec(pos, user, assigns)
  assert(pos, "expected a node position")
  assert(user, "expected a user")
  assert(assigns, "expected assigns")

  local meta = minetest.get_meta(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local inv = meta:get_inventory()
  local finv = get_fluid_inventory(pos)

  local capacity = 0
  local cols = yatm.get_player_hotbar_size(user)
  local rows = 4

  local label = ""

  local drive_stack = inv:get_stack("drive_slot", 1)
  if drive_stack and not drive_stack:is_empty() then
    label = yatm.dscs.get_drive_label(drive_stack)
  end

  if finv then
    capacity = finv:get_size("main")
  end

  local page_size = rows * cols
  local row_count = math.ceil(capacity / page_size)

  assigns.drive_contents_offset = assigns.drive_contents_offset or 0
  local row_offset = assigns.drive_contents_offset * page_size

  -- cols + 1 - 1 column for paging controls
  -- rows + 1 - 1 row for the title and drive slot
  return yatm.formspec_render_split_inv_panel(user, cols + 2, rows + 1, { bg = "dscs" }, function (loc, rect)
    if loc == "main_body" then
      local blob =
        fspec.list(node_inv_name, "drive_slot_input", rect.x, rect.y, 1, 1)
        .. fspec.button(rect.x + cio(1), rect.y, cis(1), cis(1), "swap_drives", "<->")
        .. fspec.list(node_inv_name, "drive_slot", rect.x + cio(2), rect.y, 1, 1)

      if drive_stack and not drive_stack:is_empty() then
        --- The drive label is only available when a drive is installed actively
        blob =
          blob
          .. fspec.field_area(
            rect.x + cio(3),
            rect.y,
            rect.w - cio(4),
            cis(1),
            "drive_label",
            "Drive Label",
            label
          )

        if finv then
          blob =
            blob
            .. yatm_fspec.render_fluid_inventory(
              finv,
              "main",
              false, -- is_horz
              rect.x, -- x
              rect.y + cio(1),
              cis(1),
              cis(1),
              cols, -- cols
              rows, -- rows
              row_offset
            )
        end
      end

      if row_count > 1 then
        local px = rect.x + rect.w - cis(1)

        blob =
          blob
          .. fspec.button(px, rect.y + cio(1), 1, 1, "pgup", "Up")
          .. fspec.label(px, rect.y + cio(2), (assigns.drive_contents_offset + 1) .. "/" .. row_count)
          .. fspec.button(px, rect.y + cio(3), 1, 1, "pgdown", "Down")
      end

      blob =
        blob
        .. yatm_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cio(1),
          rect.y,
          cis(1),
          rect.h,
          meta,
          yatm.devices.ENERGY_BUFFER_KEY,
          yatm.devices.get_energy_capacity(pos, assigns.node)
        )

      return blob
    elseif loc == "footer" then
      if capacity > 0 then
        return fspec.list_ring(node_inv_name, "drive_slot_input") ..
               fspec.list_ring("current_player", "main")
      end
    end
    return ""
  end)
end

--- @spec.private receive_fields(
---   player: PlayerRef,
---   formname: String,
---   fields: Table,
---   assigns: Table
--- ): (keep_bubbling: Boolean, new_formspec: String)
local function receive_fields(player, formname, fields, assigns)
  local needs_refresh = false

  if fields["drive_label"] then
    set_drive_label(assigns.pos, fields["drive_label"])
    -- needs_refresh = true
  end

  if fields["swap_drives"] then
    swap_drives(assigns.pos)
    needs_refresh = true
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
    return true, render_formspec(assigns.pos, player, assigns)
  else
    return true
  end
end

local function on_rightclick(pos, node, user)
  migrate(pos)

  local assigns = {
    pos = pos,
    node = node
  }
  local formspec = render_formspec(pos, user, assigns)
  local formspec_name = get_formspec_name(pos)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    formspec_name,
    formspec,
    {
      state = assigns,
      on_receive_fields = assert(receive_fields)
    }
  )
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  if from_list == "drive_slot_input" and to_list == "drive_slot_input" then
    return 1
  end
  return 0
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "drive_slot_input" then
    if yatm.dscs.is_item_stack_fluid_drive(stack) then
      return 1
    end
  end
  return 0
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "drive_slot_input" then
    return 1
  end
  return 0
end

local function on_metadata_inventory_put(pos, listname, _index, stack, player)
  if listname == "drive_slot" then
    local meta = minetest.get_meta(pos)

    if yatm.dscs.is_item_stack_fluid_drive(stack) then
      refresh_fluid_inventory(pos)

      refresh_formspec(pos, player)

      minetest.log("action", player:get_player_name() .. " installed a fluid drive")
    end
  end
end

local function on_metadata_inventory_take(pos, listname, _index, stack, player)
  if listname == "drive_slot" then
    if yatm.dscs.is_item_stack_fluid_drive(stack) then
      destroy_fluid_inventory(pos)

      refresh_formspec(pos, player)

      minetest.log("action", player:get_player_name() .. " removed a fluid drive")
    end
  end
end

local function on_dig(pos, node, digger)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  if inv:is_empty("drive_slot") then
    return minetest.node_dig(pos, node, digger)
  end

  return false
end

local function on_blast(pos, node, digger)
  local drops = {}
  persist_drive_contents(pos)
  foundation.com.get_inventory_drops(pos, "drive_slot_input", drops)
  foundation.com.get_inventory_drops(pos, "drive_slot", drops)
  table.insert(drops, mod:make_name("void_crate_off"))
  minetest.remove_node(pos)
  return drops
end

local yatm_network = {
  kind = "machine",
  groups = {
    dscs_device = 1,
    dscs_storage_module = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = mod:make_name("void_crate_error"),
    error = mod:make_name("void_crate_error"),
    off = mod:make_name("void_crate_off"),
    on = mod:make_name("void_crate_on"),
  },
  energy = {
    capacity = 4000,
    passive_lost = 1,
    network_charge_bandwidth = 400,
    startup_threshold = 100,
  },
}

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  dscs_fluid_storage = 1,
  dscs_fluid_provider = 1,
  yatm_dscs_device = 1,
  yatm_energy_device = 1,
  yatm_network_device = 1,
}

function yatm_network.on_load(pos, node)
  -- reload fluid inventories
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local stack = inv:get_stack("drive_slot", 1)
  if yatm.dscs.is_item_stack_fluid_drive(stack) then
    local fluid_inventory_name = get_fluid_inventory_name(pos)
    local fluid_inventory = yatm.dscs.overload_fluid_inventory_from_drive(fluid_inventory_name, stack)
    meta:set_string("fluid_drive_contents", fluid_inventory:serialize())
  end
end

function yatm_network.on_unload(pos, node)
  -- unload fluid inventories
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local stack = inv:get_stack("drive_slot", 1)
  if yatm.dscs.is_item_stack_fluid_drive(stack) then
    local fluid_inventory_name = get_fluid_inventory_name(pos)
    local fluid_inventory = yatm.fluid.fluid_inventories:get_fluid_inventory(fluid_inventory_name)
    if fluid_inventory then
      meta:set_string("fluid_drive_contents", fluid_inventory:serialize())
    end
    yatm.fluids.fluid_inventories:destroy_fluid_inventory(fluid_inventory_name)
  end
end

yatm.devices.register_stateful_network_device({
  basename = mod:make_name("void_crate"),

  codex_entry_id = mod:make_name("void_crate"),

  base_description = mod.S("Void Crate"),
  description = mod.S("Void Crate") .. "\nInstall a fluid drive to access it's contents.",

  groups = groups,

  drop = yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_void_crate_top.off.png",
    "yatm_void_crate_bottom.png",
    "yatm_void_crate_side.off.png",
    "yatm_void_crate_side.off.png^[transformFX",
    "yatm_void_crate_back.off.png",
    "yatm_void_crate_front.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  on_construct = function (pos)
    local node = minetest.get_node(pos)

    yatm.devices.device_on_construct(pos)
    migrate(pos)
  end,

  yatm_network = yatm_network,

  on_rightclick = on_rightclick,

  refresh_infotext = refresh_infotext,

  allow_metadata_inventory_move = allow_metadata_inventory_move,
  allow_metadata_inventory_put = allow_metadata_inventory_put,
  allow_metadata_inventory_take = allow_metadata_inventory_take,
  -- on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,

  on_dig = on_dig,
}, {
  error = {
    tiles = {
      "yatm_void_crate_top.error.png",
      "yatm_void_crate_bottom.png",
      "yatm_void_crate_side.error.png",
      "yatm_void_crate_side.error.png^[transformFX",
      "yatm_void_crate_back.error.png",
      "yatm_void_crate_front.error.png",
    },
  },

  on = {
    tiles = {
      "yatm_void_crate_top.on.png",
      "yatm_void_crate_bottom.png",
      {
        name = "yatm_void_crate_side.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2
        },
      },
      {
        name = "yatm_void_crate_side.on.png^[transformFX",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2
        },
      },
      "yatm_void_crate_back.on.png",
      "yatm_void_crate_front.on.png",
    },
  }
})
