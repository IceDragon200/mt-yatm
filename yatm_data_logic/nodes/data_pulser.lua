local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local sounds = assert(yatm_core.sounds)
local data_network = assert(yatm.data_network)
local is_table_empty = assert(foundation.com.is_table_empty)
local fspec = assert(foundation.com.formspec.api)

local function on_node_pulsed(pos, node)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef.next_step then
    local new_node = {
      name = nodedef.next_step,
      param1 = node.param1,
      param2 = node.param2,
    }

    minetest.swap_node(pos, new_node)
    data_network:upsert_member(pos, new_node)
  end
end

yatm.register_stateful_node("yatm_data_logic:data_pulser", {
  basename = "yatm_data_logic:data_pulser",
  description = "Data Pulser",

  codex_entry_id = "yatm_data_logic:data_pulser",

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
    },
  },

  tiles = {
    "yatm_data_pulser_top.png",
    "yatm_data_pulser_bottom.png",
    "yatm_data_pulser_side.png",
    "yatm_data_pulser_side.png",
    "yatm_data_pulser_side.png",
    "yatm_data_pulser_side.png",
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
        if yatm_data_logic.emit_output_data(pos, "pulse") then
          sounds:play("blip1", { pos = pos, max_hear_distance = 32, pitch_variance = 0.025 })
        end
        on_node_pulsed(pos, node)

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
      -- pulsers don't need to bind listeners of any sorts
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      --
    end,

    get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)
      assigns.tab = assigns.tab or 1

      local formspec =
        yatm_data_logic.layout_formspec() ..
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
        local data_pulse = meta:get_string("data_pulse") or ""

        local interval_id = 1
        local interval = yatm_data_logic.INTERVALS[meta:get_string("interval_option")]
        if interval then
          interval_id = interval.id
        end

        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "dropdown[0.25,1;8,1;interval_option;" .. yatm_data_logic.INTERVAL_STRING .. ";" .. interval_id .. "]" ..
          "label[0,2;On Trigger]" ..
          "field[0.25,3;8,1;data_pulse;Data;" .. minetest.formspec_escape(data_pulse) .. "]"
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

      local _ic, ochg = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "o")

      if not is_table_empty(ochg) then
        needs_refresh = true
      end

      if fields["data_pulse"] then
        meta:set_string("data_pulse", fields["data_pulse"])
      end

      if fields["interval_option"] then
        meta:set_string("interval_option", fields["interval_option"])
      end

      return true, needs_refresh
    end,
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
}, {
  off = {
    next_step = "yatm_data_logic:data_pulser_step_0",
  },
  step_0 = {
    next_step = "yatm_data_logic:data_pulser_step_1",
    tiles = {
      "yatm_data_pulser_top.pulse.0.png",
      "yatm_data_pulser_bottom.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
    },
  },
  step_1 = {
    next_step = "yatm_data_logic:data_pulser_step_0",
    tiles = {
      "yatm_data_pulser_top.pulse.1.png",
      "yatm_data_pulser_bottom.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
      "yatm_data_pulser_side.png",
    },
  }
})
