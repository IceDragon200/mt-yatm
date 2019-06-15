--
-- OKU Micro Controller
-- The micro controler is a limited computer, it doesn't have any extra
-- built-in memory, so the load and strore instructions are no-ops.
-- They can only execute 16 instructions, since they only have space for those 16 instructions.
-- And they can only communicate with 16 ports total, these specific 16 ports can
-- be selected in the interface, allowing the use of a multi bus.
--
-- Despite all these limitations, it doesn't require a YATM energy source.
--
-- Even the designer is baffled by that.
--
local data_network = assert(yatm.data_network)

local function get_micro_controller_formspec(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local meta = minetest.get_meta(pos)
  local formspec =
    "size[8,9]"

  for i = 0,15 do
    local x = 0.25 + math.floor(i % 4)
    local y = 0.5 + math.floor(i / 4)
    local port_id = i + 1
    local port_value = meta:get_int("p" .. port_id)
    formspec = formspec ..
      "field[" .. x .. "," .. y .. ";1,1;p" .. port_id .. ";Port " .. port_id .. ";" .. port_value .. "]" ..
      "field_close_on_enter[p" .. port_id .. ",false]"
  end

  formspec =
    formspec ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    default.get_hotbar_bg(0,4.85)

  return formspec
end

local function micro_controller_on_receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)

  for i = 1,16 do
    local field_name = "p" .. i
    if fields[field_name] then
      local port_id = math.min(256, math.max(0, math.floor(tonumber(fields[field_name]))))
      meta:set_int(field_name, port_id)
    end
  end

  return true
end

local function micro_controller_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local micro_controller_data_network_device = {
  type = "device",
  groups = {
    updatable = 1,
  }
}

local function micro_controller_on_construct(pos)
  local node = minetest.get_node(pos)
  data_network:register_member(pos, node)
end

local function micro_controller_after_place_node(pos, _placer, _item_stack, _pointed_thing)
  -- Initialize the controller ports
  local meta = minetest.get_meta(pos)
  meta:set_int("p1", 0)
  meta:set_int("p2", 0)
  meta:set_int("p3", 0)
  meta:set_int("p4", 0)
  meta:set_int("p5", 0)
  meta:set_int("p6", 0)
  meta:set_int("p7", 0)
  meta:set_int("p8", 0)
  meta:set_int("p9", 0)
  meta:set_int("p10", 0)
  meta:set_int("p11", 0)
  meta:set_int("p12", 0)
  meta:set_int("p13", 0)
  meta:set_int("p14", 0)
  meta:set_int("p15", 0)
  meta:set_int("p16", 0)
end

local function micro_controller_on_destruct(pos)
end

local function micro_controller_after_destruct(pos, old_node)
  data_network:unregister_member(pos, old_node)
end

local micro_controller_data_interface = {}

function micro_controller_data_interface.update(pos, node, dt)
  --
  --print("Executing micro controller", dt, minetest.pos_to_string(pos), node.name)
end

function micro_controller_data_interface.receive_pdu(pos, node, port, value)
end

local groups = {
  cracky = 1,
  yatm_data_device = 1,
}

local micro_controller_nodebox = {
  type = "connected",
  fixed          = yatm_core.Cuboid:new(3, 0, 3,10, 4,10):fast_node_box(),
  connect_top    = yatm_core.Cuboid:new(5, 4, 5, 6,12, 6):fast_node_box(), -- y+
  connect_bottom = yatm_core.Cuboid:new(2, 0, 2,12, 1,12):fast_node_box(), -- y-
  connect_front  = yatm_core.Cuboid:new(4, 0, 0, 8, 3, 4):fast_node_box(), -- z-
  connect_back   = yatm_core.Cuboid:new(4, 0,12, 8, 3, 4):fast_node_box(), -- z+
  connect_left   = yatm_core.Cuboid:new(0, 0, 4, 4, 3, 8):fast_node_box(), -- x-
  connect_right  = yatm_core.Cuboid:new(12,0, 4, 4, 3, 8):fast_node_box(), -- x+
}

local connects_to = {
  "group:data_cable_bus"
}

minetest.register_node("yatm_oku:oku_micro_controller", {
  description = "OKU Micro Controller",

  groups = groups,

  tiles = {
    "yatm_oku_micro_controller_top.png",
    "yatm_oku_micro_controller_bottom.png",
    "yatm_oku_micro_controller_side.png",
    "yatm_oku_micro_controller_side.png",
    "yatm_oku_micro_controller_side.png",
    "yatm_oku_micro_controller_side.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  place_param2 = 0,

  drawtype = "nodebox",
  node_box = micro_controller_nodebox,

  connects_to = connects_to,

  data_network_device = micro_controller_data_network_device,

  data_interface = micro_controller_data_interface,

  refresh_infotext = micro_controller_refresh_infotext,

  after_place_node = micro_controller_after_place_node,
  on_construct = micro_controller_on_construct,
  on_destruct = micro_controller_on_destruct,
  after_destruct = micro_controller_after_destruct,

  on_rightclick = function (pos, node, clicker)
    local formspec_name = "yatm_oku:oku_micro_controller:" .. minetest.pos_to_string(pos)
    yatm_core.bind_on_player_receive_fields(formspec_name,
                                            { pos = pos, node = node },
                                            micro_controller_on_receive_fields)
    minetest.show_formspec(
      clicker:get_player_name(),
      formspec_name,
      get_micro_controller_formspec(pos)
    )
  end,
})
