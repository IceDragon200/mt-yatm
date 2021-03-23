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
      while time <= 0 do
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

      local _old_version = meta:get_int("version")

      meta:set_int("version", 2)
      local inv = meta:get_inventory()

      inv:set_size("sequence", 64)
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      --
    end,

    on_programmer_formspec_quit = function (self, pos, user, assigns)
      if assigns.token_inventory_name then
        minetest.remove_detached_inventory(assigns.token_inventory_name)
      end
    end,

    get_programmer_formspec = {
      default_tab = "ports",
      tabs = {
        {
          tab_id = "ports",
          title = "Ports",
          header = "Port Configuration",
          render = {
            {
              component = "io_ports",
              mode = "o",
            }
          },
        },
        {
          tab_id = "data",
          title = "Data",
          header = "Data Configuration",
          render = {
            {
              component = "row",
              items = {
                {
                  component = "dropdown",
                  label = "Interval (Seconds)",
                  name = "interval_option",
                  items = yatm_data_logic.INTERVAL_ITEMS,
                  index = yatm_data_logic.INTERVAL_NAME_TO_INDEX,
                  type = "string",
                  meta = true,
                },
              }
            }
          }
        },
        {
          tab_id = "sequence",
          title = "Sequence",
          header = "Sequence",
          render = function (rect, pos, player, pointed_thing, assigns)
            if not assigns.initialized then
              assigns.token_inventory_name = create_token_inventory(player)

              assigns.initialized = true
            end

            local meta = minetest.get_meta(pos)

            local blob =
              fspec.list("detached:"..assigns.token_inventory_name, "main", 0.5, 1.5, 1, 8) ..
              fspec.list("detached:"..assigns.token_inventory_name, "main", 5.5, 1.5, 1, 8, 8)

            for c = 0,15 do
              local i = c + 1
              local x = math.floor(c / 8)
              local y = c % 8
              blob =
                blob ..
                fspec.field_area(2 + x * 4.75, 1.5 + y * 1.25, 3, 1,
                                 "data_seq"..i, "",
                                 meta:get_string("data_seq" .. i))
            end

            local spos = pos.x .. "," .. pos.y .. "," .. pos.z
            blob =
              blob ..
              fspec.list("nodemeta:"..spos, "sequence", 10, 1.5, 8, 8)

            return blob, rect
          end
        }
      }
    },

    receive_programmer_fields = {
      tabbed = true, -- notify the solver that tabs are in use
      tabs = {
        {
          components = {
            {component = "io_ports", mode = "o"}
          }
        },
        {
          components = {
            {
              component = "field",
              name = "interval_option",
              type = "string",
              meta = true,
            }
          }
        },
        {
          components = {}
        }
      }
    }
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
