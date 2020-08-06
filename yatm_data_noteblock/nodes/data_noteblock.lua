local Cuboid = yatm_core.Cuboid
local ng = Cuboid.new_fast_node_box

local data_network = assert(yatm.data_network)

-- Just like a mesecon noteblock, except triggered by data events
minetest.register_node("yatm_data_noteblock:data_noteblock", {
  description = "Data Note Block",

  codex_entry_id = "yatm_data_noteblock:data_noteblock",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "none",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 5, 16),
      ng(2, 5, 2, 12,10, 12),
      ng( 0,14, 0, 16, 2, 2),
      ng( 0,14,14, 16, 2, 2),
      ng( 0,14, 0,  2, 2, 16),
      ng(14,14, 0,  2, 2, 16),
    },
  },

  tiles = {
    "yatm_data_noteblock_top.png",
    "yatm_data_noteblock_bottom.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_int("damper", 0)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,

  data_network_device = {
    type = "device",
  },
  data_interface = {
    on_load = function (self, pos, node)
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (self, pos, node, dir, local_port, value)
      --print("receive_pdu", minetest.pos_to_string(pos), node.name, dir, local_port, dump(value))
      local meta = minetest.get_meta(pos)
      local payload = yatm_core.string_hex_unescape(value)
      local key = string.byte(payload, 1)
      if key then
        key = key + meta:get_int("offset")
        local damper = meta:get_int("damper")
        yatm.noteblock.play_note(pos, node, key, math.max(0, 127 - damper))
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
          yatm_data_logic.get_io_port_formspec(pos, meta, "i")

      elseif assigns.tab == 2 then
        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "field[0.25,1;8,1;offset;Note Offset;" .. meta:get_int("offset") .. "]" ..
          "field[0.25,2;8,1;damper;Damper;" .. meta:get_int("damper") .. "]"
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

      local inputs_changed = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "i")

      if not yatm_core.is_table_empty(inputs_changed) then
        yatm_data_logic.unmark_all_receive(assigns.pos)
        yatm_data_logic.mark_all_inputs_for_active_receive(assigns.pos)
      end

      if fields["offset"] then
        local offset = math.floor(tonumber(fields["offset"]))
        meta:set_int("offset", offset)
      end

      if fields["damper"] then
        local damper = math.floor(tonumber(fields["damper"]))
        meta:set_int("damper", damper)
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
