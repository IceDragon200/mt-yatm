--
-- Proximity Sensor
--
--   Detects and or tracks entities nearby
--   It can be configured to detect or track entities with different criterias
--
--
local Vector3 = assert(foundation.com.Vector3)
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local string_hex_escape = assert(foundation.com.string_hex_escape)

local data_network = assert(yatm.data_network)
local ByteEncoder = assert(yatm.ByteEncoder)
local BELE = assert(ByteEncoder.LE)

minetest.register_node("yatm_data_logic:data_proximity_sensor", {
  description = "DATA Proximity Sensor\nDetects nearby entities.",

  codex_entry_id = "yatm_data_logic:data_proximity_sensor",

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16,  4, 16),
      ng(3, 4, 3, 10, 10, 10),
    },
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_data_proximity_sensor_top.png",
    "yatm_data_proximity_sensor_bottom.png",
    "yatm_data_proximity_sensor_side.png",
    "yatm_data_proximity_sensor_side.png",
    "yatm_data_proximity_sensor_side.png",
    "yatm_data_proximity_sensor_side.png",
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,

  data_network_device = {
    type = "device",
    groups = {
      updatable = 1,
    },
  },
  data_interface = {
    update = function (self, pos, node, dtime)
      local meta = minetest.get_meta(pos)

      local time = meta:get_float("time")
      time = time - dtime

      if time <= 0 then
        time = time + 1

        local objects = minetest.get_objects_inside_radius(pos, 32)

        local obj = objects[1]

        local exists = 0
        local x = 0
        local y = 0
        local z = 0
        local hp = 0
        local name = ""

        if obj then
          exists = 1
          local lua_entity = obj:get_luaentity()

          local object_pos = obj:get_pos()
          x = math.floor(object_pos.x)
          y = math.floor(object_pos.y)
          z = math.floor(object_pos.z)
          hp = math.floor(obj:get_hp())

          if lua_entity then
            name = lua_entity.name
          end
        end

        meta:set_int("last_exists", exists)
        meta:set_int("last_x", x)
        meta:set_int("last_y", y)
        meta:set_int("last_z", z)
        meta:set_int("last_hp", hp)
        meta:set_string("last_name", name)

        yatm_data_logic.emit_matrix_port_value(pos, "port", "exists", string_hex_escape(BELE:e_u8(exists)))
        yatm_data_logic.emit_matrix_port_value(pos, "port", "x", string_hex_escape(BELE:e_i16(x)))
        yatm_data_logic.emit_matrix_port_value(pos, "port", "y", string_hex_escape(BELE:e_i16(y)))
        yatm_data_logic.emit_matrix_port_value(pos, "port", "z", string_hex_escape(BELE:e_i16(z)))
        yatm_data_logic.emit_matrix_port_value(pos, "port", "hp", string_hex_escape(BELE:e_u16(hp)))
        yatm_data_logic.emit_matrix_port_value(pos, "port", "name", name)

        yatm.queue_refresh_infotext(pos, node)
      end

      meta:set_float("time", time)
    end,

    on_load = function (self, pos, node)
      --
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      --
    end,

    get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)

      local formspec =
        yatm_data_logic.layout_formspec() ..
        yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
        "label[0,0;Port Configuration]" ..
        yatm_data_logic.get_port_matrix_formspec(pos, meta, {
          width = 12,
          sections = {
            {
              name = "port",
              label = nil,
              cols = 3,
              port_count = 6,
              port_names = {"exists", "name", "hp", "x", "y", "z"},
              port_labels = {"Exists?", "Name", "HP", "X-Coord", "Y-Coord", "Z-Coord"},
            }
          }
        })

      return formspec
    end,

    receive_programmer_fields = function (self, player, form_name, fields, assigns)
      local meta = minetest.get_meta(assigns.pos)

      local needs_refresh = true

      yatm_data_logic.handle_port_matrix_fields(assigns.pos, fields, meta, {
        sections = {
          {
            name = "port",
            port_count = 6,
            port_names = {"exists", "name", "hp", "x", "y", "z"},
          }
        }
      })

      return true, needs_refresh
    end,
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local vec = vector.new(meta:get_int("last_x"), meta:get_int("last_y"), meta:get_int("last_z"))
    local exists_str
    if meta:get_int("last_exists") > 0 then
      exists_str = "(Exists) "
    else
      exists_str = "(Nothing)"
    end
    local infotext =
      "Last Position: " .. Vector3.to_string(vec) .. "\n" ..
      "Last HP: " .. meta:get_int("last_hp") .. "\n" ..
      "Last Entity: " .. exists_str .. meta:get_string("last_name") .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
