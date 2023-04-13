local Vector3 = assert(foundation.com.Vector3)
local fparser = assert(foundation.com.formspec.parser)

local function refresh_formspec_tabs(state)
  local form = assert(get_player_current_formspec(state.player:get_player_name()))

  state.form = form

  local items = fparser.parse(assert(form.spec))

  local tabheader = assert(items:find(nil, function (item)
    return item.name == "tabheader"
  end), "expected tabheader")

  assert(tabheader.attrs:size() == 7, "expected tab header to have 7 attributes")
  do
    -- 1 = x,y
    -- 2 = h
    local name = tabheader.attrs:get(3):get(1) -- 3 = name
    local headers = tabheader.attrs:get(4) -- 4 = headers
    local tabindex = tonumber(tabheader.attrs:get(5):get(1)) -- 5 = tabindex

    state.tabs = {
      name = name,
      index = tabindex,
      tab = headers:get(tabindex),
      items = headers,
      header_index = headers:reduce({}, function (item, idx, acc)
        acc[item] = idx
        return acc
      end),
    }
  end

  print(dump(items))
end

local function open_data_programming_formspec(pos, state)
  local inv = state.player:get_inventory()

  inv:set_stack("main", 1, ItemStack("yatm_data_logic:data_programmer"))
  state.player.hotbar_index = 1

  assert(trigger_rightclick_on_pos(state.pos, state.player))

  refresh_formspec_tabs(state)
end

yatm_data_network.autotest_suite:define_property("load_test", {
  description = "load_test",
  detail = [[
  Not so much a property, but rather a massive test suite that will try to benchmark network behaviour
  ]],

  setup = function (suite, state)
    local player = assert(minetest.get_player_by_name("singleplayer"))

    state.player = player

    state.pos = Vector3.new(0, 0, 0)
    suite:clear_test_area(state.pos)

    return state
  end,

  tests = {
    ["Pulsing network"] = function (suite, state)
      --
      local pulser_node_name = "yatm_data_logic:data_pulser_off"
      local cable_name = "yatm_data_cables:data_cable_white"
      local cable_bus_name = "yatm_data_cables:data_cable_bus_white"

      local lamp_name = "yatm_data_logic:data_levelled_lamp_0"

      local pulser_node = {
        name = pulser_node_name,
      }

      local cable_bus_node = {
        name = cable_bus_name,
      }

      local cable_node = {
        name = cable_name,
      }

      local lamp_node = {
        name = lamp_name,
      }

      local point = Point(state.pos.x, state.pos.y, state.pos.z)

      --- Setup network
      minetest.set_node(point:to_vector3(), pulser_node)
      point:east()
      minetest.set_node(point:to_vector3(), cable_bus_node)
      point:east()
      minetest.set_node(point:to_vector3(), cable_node)
      point:east()
      minetest.set_node(point:to_vector3(), cable_node)
      point:east()
      minetest.set_node(point:to_vector3(), cable_bus_node)
      point:east()
      minetest.set_node(point:to_vector3(), lamp_node)

      suite:yield()

      --- Open Programming Formspec
      open_data_programming_formspec(state.pos, state)

      suite:yield()

      --- Configure ports
      trigger_on_player_receive_fields(
        state.player,
        assert(state.form.name),
        {
          ["output_bit_2_4"] = {}
        }
      )

      suite:yield()

      --- Get updated formspec
      refresh_formspec_tabs(state)

      --- Switch tabs to Data
      print(dump(state))
      trigger_on_player_receive_fields(
        state.player,
        assert(state.form.name),
        {
          [state.tabs.name] = assert(
            state.tabs.header_index["Data"],
            "expected Data tab"
          )
        }
      )

      --- Get updated formspec
      refresh_formspec_tabs(state)
    end,
  },

  teardown = function (suite, state)
    suite:clear_test_area(state.pos)
  end,
})
