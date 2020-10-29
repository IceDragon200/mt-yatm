local Cuboid = assert(foundation.com.Cuboid)
local is_table_empty = assert(foundation.com.is_table_empty)
local ng = Cuboid.new_fast_node_box
local sounds = assert(yatm_core.sounds)
local data_network = assert(yatm.data_network)
local fspec = assert(foundation.com.formspec.api)

local function create_token_inventory(user)
  local name = foundation.com.make_string_ref("ydlds")

  local inv =
    minetest.create_detached_inventory(name, {
      allow_move = function (inv, from_list, from_index, to_list, to_index, count, player)
        print("allow_move", "from_list", from_list, "to_list", to_list)

        return 0
      end,

      allow_put = function (inv, listname, index, stack, player)
        return 0
      end,

      allow_take = function (inv, listname, index, stack, player)
        return -1
      end,

      on_move = function (inv, from_list, from_index, to_list, to_index, count, player)
        print("on_move", "from_list", from_list, "to_list", to_list)
        --
      end,

      on_put = function (inv, listname, index, stack, player)
        --
      end,

      on_take = function (inv, listname, index, stack, player)
        --
      end,
    }, user:get_player_name())

  inv:set_size("main", #yatm.colors+1)

  for _,row in ipairs(yatm.colors) do
    local stack = ItemStack("yatm_data_logic:token_"..row.name.." 1")

    inv:add_item("main", stack)
  end

  return name
end

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
      local meta = minetest.get_meta(pos)

      local inv = meta:get_inventory()

      inv:set_size("sequence", 64)
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
    end,

    on_programmer_formspec_quit = function (self, pos, user, assigns)
      minetest.remove_detached_inventory(assigns.token_inventory_name)
    end,

    get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)
      assigns.tab = assigns.tab or 1

      if not assigns.initialized then
        assigns.token_inventory_name = create_token_inventory(user)

        assigns.initialized = true
      end

      local formspec =
        yatm_data_logic.layout_formspec() ..
        yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
        fspec.tabheader(0, 0, nil, nil, "tab", {"Ports", "Data", "Sequence"}, assigns.tab)

      if assigns.tab == 1 then
        formspec =
          formspec ..
          "label[0.5,0.75;Port Configuration]"

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
          fspec.label(0.5, 0.75, "Data Configuration") ..
          fspec.label(0.5, 1.25, "Interval (Seconds)") ..
          "dropdown[0.5,2;8,1;interval_option;" .. yatm_data_logic.INTERVAL_STRING .. ";" .. interval_id .. "]"

      elseif assigns.tab == 3 then
        formspec =
          formspec ..
          fspec.label(0.5, 0.75, "Sequence") ..
          fspec.list("detached:"..assigns.token_inventory_name, "main", 0.5, 1.5, 1, 8) ..
          fspec.list("detached:"..assigns.token_inventory_name, "main", 5.5, 1.5, 1, 8, 8)

        for c = 0,15 do
          local i = c + 1
          local x = math.floor(c / 8)
          local y = c % 8
          formspec =
            formspec ..
            fspec.field_area(2 + x * 4.75, 1.5 + y * 1.25, 3, 1,
                             "data_seq"..i, "",
                             meta:get_string("data_seq" .. i))
        end

        local spos = pos.x .. "," .. pos.y .. "," .. pos.z
        formspec =
          formspec ..
          fspec.list("nodemeta:"..spos, "sequence", 10, 1.5, 8, 8)

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

      local _ichg, ochg = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "o")

      if not is_table_empty(ochg) then
        needs_refresh = true
      end

      for i = 1,16 do
        local seq_data = fields["data_seq" .. i]
        if seq_data then
          meta:set_string("data_seq" .. i, seq_data)
        end
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
})
