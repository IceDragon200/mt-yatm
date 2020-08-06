local Cuboid = foundation.com.Cuboid
local ng = Cuboid.new_fast_node_box
local string_hex_escape = assert(foundation.com.string_hex_escape)
local data_network = assert(yatm.data_network)

local function scale_value(value, range)
  return math.min(math.max(math.floor(value * range), 0), range)
end

minetest.register_node("yatm_data_logic:data_clock", {
  description = "Data Clock\nReports the current time of day ranging from 0 to 255 every second",

  codex_entry_id = "yatm_data_logic:data_clock",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 4, 16),
      ng(3, 4, 3, 10, 1, 10),
    },
  },

  tiles = {
    "yatm_data_clock_top.png",
    "yatm_data_clock_bottom.png",
    "yatm_data_clock_side.png",
    "yatm_data_clock_side.png",
    "yatm_data_clock_side.png",
    "yatm_data_clock_side.png",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_int("precision", 1)
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
        local value = 0

        -- precision presents how many bytes are used to represent the time
        -- by default it is 1 byte
        local precision = meta:get_int("precision")

        local timeofday = minetest.get_timeofday()
        local output_data
        if precision == 2 then
          value = scale_value(timeofday, 0xFFFF)
          output_data = string_hex_escape(yatm_data_logic.encode_u16(value))
        elseif precision == 3 then
          value = scale_value(timeofday, 0xFFFFFF)
          output_data = string_hex_escape(yatm_data_logic.encode_u24(value))
        elseif precision == 4 then
          value = scale_value(timeofday, 0xFFFFFFFF)
          output_data = string_hex_escape(yatm_data_logic.encode_u32(value))
        else
          value = scale_value(timeofday, 0xFF)
          output_data = string_hex_escape(yatm_data_logic.encode_u8(value))
        end

        yatm_data_logic.emit_output_data_value(pos, output_data)

        meta:set_int("last_timeofday", value)
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
      assigns.tab = assigns.tab or 1

      local formspec =
        "size[8,9]" ..
        yatm.formspec_bg_for_player(user:get_player_name(), "module")

      if assigns.tab == 1 then
        formspec =
          formspec ..
          "label[0,0;Port Configuration]" ..
          yatm_data_logic.get_io_port_formspec(pos, meta, "o")
      elseif assigns.tab == 2 then
        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "field[0.5,1;8,1;precision;Byte Count;" .. meta:get_int("precision") .. "]"
      end

      return formspec
    end,

    receive_programmer_fields = function (self, player, form_name, fields, assigns)
      local meta = minetest.get_meta(assigns.pos)

      if fields["tab"] then
        local tab = tonumber(fields["tab"])
        if tab ~= assigns.tab then
          assigns.tab = tab
          needs_refresh = true
        end
      end

      yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "o")

      if fields["precision"] then
        local precision = math.max(math.min(tonumber(fields["precision"]), 4), 1)

        local old_precision = meta:get_int("precision")
        if old_precision ~= precision then
          meta:set_int("precision", precision)
          needs_refresh = true
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

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      "Time of Day: " .. meta:get_int("last_timeofday") .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
