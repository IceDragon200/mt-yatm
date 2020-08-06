-- TODO: Drive memory needs to be written back to floppy disk before being removed from inventory
--
--
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local random_string = assert(foundation.com.random_string)
local random_string62 = assert(foundation.com.random_string62)
local string_hex_unescape = assert(foundation.com.string_hex_unescape)
local string_hex_escape = assert(foundation.com.string_hex_escape)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local data_network = assert(yatm.data_network)
local Energy = assert(yatm.energy)
local ByteDecoder = yatm.ByteDecoder

if not ByteDecoder then
  minetest.log("warning", "Memory module requires yatm.ByteDecoder")
  return
end

local MAX_DISK_SIZE = 0x4000

local function get_floppy_disk_drive_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local meta = minetest.get_meta(pos)
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "computer")

  formspec =
    formspec ..
    "list[nodemeta:" .. spos .. ";floppy_disk;0,1;1,1;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";floppy_disk]" ..
    default.get_hotbar_bg(0,4.85)

  return formspec
end

local function floppy_disk_drive_on_receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)

  return true
end

local function floppy_disk_drive_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local function floppy_disk_drive_on_construct(pos)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()
  inv:set_size("floppy_disk", 1)

  data_network:add_node(pos, node)
  yatm.devices.device_on_construct(pos)

  local secret = random_string(8)
  meta:set_string("secret", "flpd." .. secret)

  yatm.computers:create_computer(pos, node, secret, {
    memory_size = MAX_DISK_SIZE, -- 64k
  })
end

local function floppy_disk_drive_after_place_node(pos, _placer, _item_stack, _pointed_thing)
  local node = minetest.get_node(pos)
  yatm.devices.device_after_place_node(pos, node)
end

local function floppy_disk_drive_on_destruct(pos)
  yatm.devices.device_on_destruct(pos)
end

local function floppy_disk_drive_after_destruct(pos, old_node)
  data_network:remove_node(pos, old_node)
  -- no this is not a typo, the floppy disk drive is using the computers API
  -- for its memory module, AND only for the memory.
  yatm.computers:destroy_computer(pos, old_node)
  yatm.devices.device_after_destruct(pos, old_node)
end

local function get_floppy_disk(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()
  local stack = inv:get_stack("floppy_disk", 1)

  return stack
end

local function get_floppy_disk_size(pos)
  local stack = get_floppy_disk(pos)

  return yatm_oku.get_floppy_disk_size(stack)
end

local function has_floppy_disk(pos)
  local stack = get_floppy_disk(pos)

  return not stack:is_empty() and yatm_oku.is_stack_floppy_disk(stack)
end

local floppy_disk_drive_yatm_network = {
  kind = "machine",
  groups = {
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_oku:floppy_disk_drive_error",
    error = "yatm_oku:floppy_disk_drive_error",
    off = "yatm_oku:floppy_disk_drive_off",
    on = "yatm_oku:floppy_disk_drive_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 1,
    startup_threshold = 100,
    network_charge_bandwidth = 500,
  }
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_oku:floppy_disk_drive",

  description = "Floppy Drive",

  codex_entry_id = "yatm_oku:floppy_disk_drive",

  groups = {
    cracky = 1,
    yatm_data_device = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
    floppy_disk_drive = 1,
    data_programmable = 1,
    yatm_computer = 1,
  },

  drop = floppy_disk_drive_yatm_network.states.off,

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 8, 16),
    },
  },

  tiles = {
    "yatm_floppy_disk_drive_top.off.png",
    "yatm_floppy_disk_drive_bottom.png",
    "yatm_floppy_disk_drive_side.off.png",
    "yatm_floppy_disk_drive_side.off.png^[transformFX",
    "yatm_floppy_disk_drive_back.png",
    "yatm_floppy_disk_drive_front.off.png"
  },
  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = floppy_disk_drive_yatm_network,

  data_network_device = {
    type = "device",
  },
  data_interface = {
    on_load = function (self, pos, node)
      yatm_data_logic.bind_matrix_ports(pos, "port", "read", "active")
      yatm_data_logic.bind_matrix_ports(pos, "port", "write", "active")
      yatm_data_logic.bind_matrix_ports(pos, "port", "seek", "active")
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      local meta = minetest.get_meta(pos)
      local blob = string_hex_unescape(value)

      local disk_size = get_floppy_disk_size(pos)

      if yatm_data_logic.get_matrix_port(pos, "port", "seek", dir) == port then
        -- Seeking can work regardless of the presence of a disk
        local seek_type = string.sub(blob, 1, 1)
        local offset = string.sub(blob, 2, 3)

        seek_type = ByteDecoder:d_u8(seek_type)
        offset = ByteDecoder:d_u16(offset) -- offset is 0-offset, not 1

        if seek_type == 0 then -- SEEK_SET
          meta:set_int("seek_offset", offset)
        elseif seek_type == 1 then -- SEEK_CUR
          meta:set_int("seek_offset", meta:get_int("seek_offset", offset))
        elseif seek_type == 2 then -- SEEK_END
          meta:set_int("seek_offset", disk_size - offset)
        end
      end

      if yatm_data_logic.get_matrix_port(pos, "port", "write", dir) == port then
        -- writes can only happen if a disk is present
        if has_floppy_disk(pos) then
          -- reminder that address offset is a 0-offset
          local seek_offset = meta:get_int("seek_offset")
          local computer = yatm.computers:get_computer(pos, node)
          if computer then
            computer.oku:set_memory_circular_access(true)
            computer.oku:w_memory_blob(seek_offset, blob)
            meta:set_int("seek_offset", (seek_offset + #blob) % disk_size)

            local disk_blob = computer.oku:r_memory_blob(seek_offset, disk_size)

            local disk_stack = get_floppy_disk(pos)
            local disk_meta = disk_stack:get_meta()
            disk_meta:set_string("data", string_hex_escape(disk_blob))
          end
        end
      end

      if yatm_data_logic.get_matrix_port(pos, "port", "read", dir) == port then
        -- reads can only happen if a disk is present
        if has_floppy_disk(pos) then
          local length = ByteDecoder:d_u8(blob)
          local computer = yatm.computers:get_computer(pos, node)
          -- yet another reminder that address offset is a 0-offset
          local seek_offset = meta:get_int("seek_offset")

          computer.oku:set_memory_circular_access(true)
          local new_blob = computer.oku:r_memory_blob(seek_offset, length)
          meta:set_int("seek_offset", (seek_offset + length) % disk_size)

          yatm_data_logic.emit_matrix_port_value(pos, "port", "data", string_hex_escape(new_blob))
        end
      end
    end,

    get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)
      assigns.tab = assigns.tab or 1

      local formspec =
        "size[8,9]" ..
        yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
        "tabheader[0,0;tab;Ports,Data;" .. assigns.tab .. "]"

      if assigns.tab == 1 then
        formspec =
          formspec ..
          "label[0,0;Port Configuration]" ..
          yatm_data_logic.get_port_matrix_formspec(pos, meta, {
            width = 8,
            sections = {
              {
                name = "port",
                label = nil,
                cols = 4,
                port_count = 4,
                port_names = {"data", "read", "write", "seek"},
                port_labels = {"Data", "Read", "Write", "Seek"},
              }
            }
          })
      elseif assigns.tab == 2 then
        local seek_blob = minetest.formspec_escape(meta:get_int("seek_offset"))

        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "field[0.3,1;8,1;seek;Seek;" .. seek_blob .. "]"
      end

      return formspec
    end,

    receive_programmer_fields = function (self, player, form_name, fields, assigns)
      local meta = minetest.get_meta(assigns.pos)

      local needs_refresh = false

      if fields["tab"] then
        local tab = tonumber(fields["tab"])
        if tab ~= assigns.tab then
          assigns.tab = tab
          needs_refresh = true
        end
      end

      if fields["seek"] then
        local seek = tonumber(fields["seek"])
        meta:set_int("seek_offset", seek)
      end

      local sections_changed =
        yatm_data_logic.handle_port_matrix_fields(assigns.pos, fields, meta, {
          sections = {
            {
              name = "port",
              port_count = 4,
              port_names = {"data", "read", "write", "seek"},
            }
          }
        })

      if sections_changed.port then
        if sections_changed.port.data then
          -- this is an output port
        end

        yatm_data_logic.unmark_all_receive(assigns.pos)

        if sections_changed.port.read then
          yatm_data_logic.bind_matrix_ports(assigns.pos, "port", "read", "active")
        end

        if sections_changed.port.write then
          yatm_data_logic.bind_matrix_ports(assigns.pos, "port", "write", "active")
        end

        if sections_changed.port.seek then
          yatm_data_logic.bind_matrix_ports(assigns.pos, "port", "seek", "active")
        end
      end

      if needs_refresh then
        local formspec = self:get_programmer_formspec(assigns.pos, player, nil, assigns)
        return true, formspec
      else
        return true
      end
    end,
  },

  refresh_infotext = floppy_disk_drive_refresh_infotext,

  on_construct = floppy_disk_drive_on_construct,
  after_place_node = floppy_disk_drive_after_place_node,
  on_destruct = floppy_disk_drive_on_destruct,
  after_destruct = floppy_disk_drive_after_destruct,

  on_rightclick = function (pos, node, user)
    local formspec_name = "yatm_oku:floppy_disk_drive:" .. minetest.pos_to_string(pos)
    yatm_core.bind_on_player_receive_fields(user, formspec_name,
                                            { pos = pos, node = node },
                                            floppy_disk_drive_on_receive_fields)
    minetest.show_formspec(
      user:get_player_name(),
      formspec_name,
      get_floppy_disk_drive_formspec(pos, user)
    )
  end,

  register_computer = function (pos, node)
    local meta = minetest.get_meta(pos)
    local secret = meta:get_string("secret")
    if not secret then
      secret = random_string62(8)
      meta:set_string("secret", "flpd." .. secret)
    end
    yatm.computers:upsert_computer(pos, node, meta:get_string("secret"), {
      memory_size = MAX_DISK_SIZE,
    })
  end,

  allow_metadata_inventory_put = function (pos, listname, index, stack, player)
    if listname == "floppy_disk" then
      if yatm_oku.is_stack_floppy_disk(stack) then
        print(stack:get_name(), "is floppy")
        return 1
      else
        print(stack:get_name(), "is not a floppy")
      end
    end
    return 0
  end,

  allow_metadata_inventory_take = function (pos, listname, index, stack, player)
    if listname == "floppy_disk" then
      return stack:get_count()
    end
    return 0
  end,

  on_metadata_inventory_put = function(pos, listname, index, stack, player)
    if listname == "floppy_disk" then
      --
      local node = minetest.get_node(pos)
      local meta = stack:get_meta()
      local data = meta:get_string("data")
      local blob = string_hex_unescape(data)

      local computer = yatm.computers:get_computer(pos)
      computer.oku:fill_memory(0)
      computer.oku:w_memory_blob(0, string.sub(blob, 1, 0x10000))

      local node_meta = minetest.get_meta(pos)
      node_meta:set_int("seek_offset", 0)
    end
  end,

  on_metadata_inventory_take = function(pos, listname, index, stack, player)
    if listname == "floppy_disk" then
      local computer = yatm.computers:get_computer(pos)
      computer.oku:fill_memory(0)
    end
  end,
}, {
  error = {
    tiles = {
      "yatm_floppy_disk_drive_top.error.png",
      "yatm_floppy_disk_drive_bottom.png",
      "yatm_floppy_disk_drive_side.error.png",
      "yatm_floppy_disk_drive_side.error.png^[transformFX",
      "yatm_floppy_disk_drive_back.png",
      "yatm_floppy_disk_drive_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_floppy_disk_drive_top.on.png",
      "yatm_floppy_disk_drive_bottom.png",
      "yatm_floppy_disk_drive_side.on.png",
      "yatm_floppy_disk_drive_side.on.png^[transformFX",
      "yatm_floppy_disk_drive_back.png",
      "yatm_floppy_disk_drive_front.on.png",
    },
  }
})
