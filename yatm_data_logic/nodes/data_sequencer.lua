local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local sounds = assert(yatm_core.sounds)
local data_network = assert(yatm.data_network)

minetest.register_node("yatm_data_logic:data_sequencer", {
  description = "Data Sequencer",

  codex_entry_id = "yatm_data_logic:data_sequencer",

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
      ng(2, 4, 2, 12, 6, 12),
    },
  },

  tiles = {
    "yatm_data_sequencer_top.png",
    "yatm_data_sequencer_bottom.png",
    "yatm_data_sequencer_side.png",
    "yatm_data_sequencer_side.png",
    "yatm_data_sequencer_side.png",
    "yatm_data_sequencer_side.png",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)

    -- initialize all data_seq with an empty string
    for i = 1,16 do
      meta:set_string("data_seq" .. i, "")
    end

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
        local seq = meta:get_int("seq")
        -- emit the current data_seq
        if yatm_data_logic.emit_output_data(pos, "seq" .. (seq + 1)) then
          -- if any data was actually sent then make a beep sound
          sounds:play("blip0", { pos = pos, max_hear_distance = 32 })
        end

        seq = (seq + 1) % 16
        meta:set_int("seq", seq)

        local interval_option = meta:get_string("interval_option")
        local duration = 1
        local interval = yatm_data_logic.INTERVALS[interval_option]
        if interval then
          duration = interval.duration
        end
        time = time + duration
      end
      meta:set_float("time", time)
    end,

    on_load = function (self, pos, node)
      -- sequencers don't need to bind listeners of any sorts
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
    end,

    get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)
      assigns.tab = assigns.tab or 1

      local formspec =
        "size[8,10]" ..
        yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
        "tabheader[0,0;tab;Ports,Data;" .. assigns.tab .. "]"

      if assigns.tab == 1 then
        formspec =
          formspec ..
          "label[0,0;Port Configuration]"

        local io_formspec = yatm_data_logic.get_io_port_formspec(pos, meta, "o")

        formspec =
          formspec ..
          io_formspec

      elseif assigns.tab == 2 then
        local interval_id = 1
        local interval = yatm_data_logic.INTERVALS[meta:get_string("interval_option")]
        if interval then
          interval_id = interval.id
        end

        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "label[0,0.5;Interval (Seconds)]" ..
          "dropdown[0.25,1;8,1;interval_option;" .. yatm_data_logic.INTERVAL_STRING .. ";" .. interval_id .. "]"

        for i = 1,16 do
          local x = ((i - 1) % 2) * 4
          local y = math.floor((i - 1) / 2)
          formspec = formspec .. "field[" .. (0.25 + x) .. "," .. (2.5 + y) ..
                                        ";4,1;data_seq" .. i ..
                                        ";Sequence " .. i ..
                                        ";" .. minetest.formspec_escape(meta:get_string("data_seq" .. i)) ..
                                        "]"
        end
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

      yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "o")

      for i = 1,16 do
        local seq_data = fields["data_seq" .. i]
        if seq_data then
          meta:set_string("data_seq" .. i, seq_data)
        end
      end

      if fields["interval_option"] then
        meta:set_string("interval_option", fields["interval_option"])
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
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
