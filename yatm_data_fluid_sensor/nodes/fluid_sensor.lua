--
-- Fluid Sensor
--
-- A multipurpose sensor block that can be attached to a tank and communicate over the yatm data network.
-- The sensor can be configured to monitor the level and output different signals unto the network.
--
local data_network = assert(yatm.data_network)
local FluidTanks = assert(yatm.fluids.FluidTanks)

local function get_fluid_sensor_formspec(pos)
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

local function fluid_sensor_on_receive_fields(player, formname, fields, assigns)
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

local function fluid_sensor_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local fluid_sensor_data_network_device = {
  type = "device",
  groups = {
    updatable = 1,
  }
}

local fluid_sensor_data_interface = {}

function fluid_sensor_data_interface.update(pos, node, dt)
  --
  -- TODO: Allow configuring a sampling interval for the sensor
  --print("FluidSensor", "data update", minetest.pos_to_string(pos), node.name)
  for d6, v3 in pairs(yatm_core.DIR6_TO_VEC3) do
    local new_pos = vector.add(pos, v3)
    local node = minetest.get_node(new_pos)

    if node.name ~= "air" then
      local id6 = yatm_core.invert_dir(d6)
      -- TODO: based on the configuration, values should be sent over different ports
      --   Some functions are:
      --     Report capacity (capacity)
      --     Report fluid amount (fluid_stack.amount)
      --     Report remaining capacity (capacity - fluid_stack.amount)
      --     Report has fluid (1 if has fluid, 0 otherwise)
      --     Report is empty (1 if empty, 0 otherwise)
      local fluid_stack = FluidTanks.get_fluid(new_pos, id6)
      local capacity, err = FluidTanks.get_capacity(new_pos, id6)
      if capacity then
        --print("Reporting capacity to port 1", minetest.pos_to_string(new_pos), capacity)
        data_network:send_value(pos, 1, capacity)
      else
        --print("no capacity", minetest.pos_to_string(new_pos), id6, node.name, err)
      end
      if fluid_stack then
        --print("Reporting fluid_stack.amount to port 2", minetest.pos_to_string(new_pos), fluid_stack.amount)
        data_network:send_value(pos, 2, fluid_stack.amount)
      end

      if fluid_stack or capacity then
        --print("got a capacity or fluid_stack", minetest.pos_to_string(new_pos))
        break
      end
    end
  end
end

function fluid_sensor_data_interface.receive_pdu(pos, node, port, value)
end

local function fluid_sensor_on_construct(pos)
  local node = minetest.get_node(pos)
  data_network:register_member(pos, node)
end

local function fluid_sensor_after_place_node(pos, _placer, _item_stack, _pointed_thin)
end

local function fluid_sensor_on_destruct(pos)
  --
end

local function fluid_sensor_after_destruct(pos, old_node)
  data_network:unregister_member(pos, old_node)
end

local fluid_sensor_node_box = {
  type = "connected",
  fixed          = yatm_core.Cuboid:new(3, 3, 3,10,10,10):fast_node_box(),
  connect_top    = yatm_core.Cuboid:new(2,13, 2,12, 3,12):fast_node_box(), -- y+
  connect_bottom = yatm_core.Cuboid:new(2, 0, 2,12, 3,12):fast_node_box(), -- y-
  connect_front  = yatm_core.Cuboid:new(4, 0, 0, 8,13, 3):fast_node_box(), -- z-
  connect_back   = yatm_core.Cuboid:new(4, 0,13, 8,13, 3):fast_node_box(), -- z+
  connect_left   = yatm_core.Cuboid:new(0, 0, 4, 3,13, 8):fast_node_box(), -- x-
  connect_right  = yatm_core.Cuboid:new(13,0, 4, 3,13, 8):fast_node_box(), -- x+
}

local connects_to = {
  "group:fluid_interface_in",
  "group:fluid_interface_out",
  "group:data_cable_bus",
}

local groups = {
  cracky = 1,
  yatm_data_device = 1,
}

minetest.register_node("yatm_data_fluid_sensor:fluid_sensor_off", {
  description = "Fluid Sensor (OFF)",

  groups = groups,

  tiles = {
    "yatm_fluid_sensor_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
  place_param2 = 0,

  drawtype = "nodebox",
  node_box = fluid_sensor_node_box,

  connects_to = connects_to,

  data_network_device = fluid_sensor_data_network_device,

  data_interface = fluid_sensor_data_interface,

  refresh_infotext = fluid_sensor_refresh_infotext,

  after_place_node = fluid_sensor_after_place_node,
  on_construct = fluid_sensor_on_construct,
  on_destruct = fluid_sensor_on_destruct,
  after_destruct = fluid_sensor_after_destruct,

  on_rightclick = function (pos, node, clicker)
    local formspec_name = "yatm_data_fluid_sensor:fluid_sensor:" .. minetest.pos_to_string(pos)
    yatm_core.bind_on_player_receive_fields(formspec_name,
                                            { pos = pos, node = node },
                                            fluid_sensor_on_receive_fields)
    minetest.show_formspec(
      clicker:get_player_name(),
      formspec_name,
      get_fluid_sensor_formspec(pos)
    )
  end,
})
