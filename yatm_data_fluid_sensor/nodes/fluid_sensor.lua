--
-- Fluid Sensor
--
-- A multipurpose sensor block that can be attached to a tank and communicate over the yatm data network.
-- The sensor can be configured to monitor the level and output different signals unto the network.
--
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local metaref_merge_fields_from_table = assert(foundation.com.metaref_merge_fields_from_table)
local Directions = assert(foundation.com.Directions)
local data_network = assert(yatm.data_network)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidStack = assert(yatm.fluids.FluidStack)
local Changeset = assert(yatm_core.Changeset)

local function get_fluid_sensor_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local meta = minetest.get_meta(pos)
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "data") ..
    "field[0.5,0.5;4,1;capacity_port;Capacity Port;" .. meta:get_int("capacity_port") .. "]" ..
    "field[4.5,0.5;4,1;amount_port;Amount Port;" .. meta:get_int("amount_port") .. "]" ..
    "field[0.5,1.5;4,1;remaining_capacity_port;Remaining Capacity Port;" .. meta:get_int("remaining_capacity_port") .. "]" ..
    "field[0.5,2.5;4,1;fluid_test_port;Fluid Test Port;" .. meta:get_int("fluid_test_port") .. "]" ..
    "field[4.5,2.5;4,1;empty_test_port;EMpty Test Port;" .. meta:get_int("empty_test_port") .. "]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]"

  return formspec
end

local FieldsSchema = {
  capacity_port = {
    type = "integer"
  },
  amount_port = {
    type = "integer"
  },
  remaining_capacity_port = {
    type = "integer"
  },
  fluid_test_port = {
    type = "integer"
  },
  empty_test_port = {
    type = "integer"
  }
}

local function fluid_sensor_on_receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)

  local changeset = Changeset:new(FieldsSchema, {})
  changeset:cast(
    fields,
    {
      "capacity_port",
      "amount_port",
      "remaining_capacity_port",
      "fluid_test_port",
      "empty_test_port"
    }
  )

  if changeset.is_valid then
    local new_fields = changeset:apply_changes()
    print("New Fields", dump(new_fields))
    metaref_merge_fields_from_table(meta, new_fields)

    print("New Meta", dump(meta:to_table()))
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

function fluid_sensor_data_interface:update(pos, node, dt)
  --
  -- TODO: Allow configuring a sampling interval for the sensor
  --print("FluidSensor", "data update", minetest.pos_to_string(pos), node.name)
  local meta = minetest.get_meta(pos)

  local capacity_port = meta:get_int("capacity_port")
  local amount_port = meta:get_int("amount_port")
  local remaining_capacity_port = meta:get_int("remaining_capacity_port")
  local fluid_test_port = meta:get_int("fluid_test_port")
  local empty_test_port = meta:get_int("empty_test_port")

  for d6, v3 in pairs(Directions.DIR6_TO_VEC3) do
    local new_pos = vector.add(pos, v3)
    local node = minetest.get_node(new_pos)

    if node.name ~= "air" then
      local id6 = Directions.invert_dir(d6)

      if FluidTanks.has_fluid_interface(new_pos, id6) then
        local fluid_stack = FluidStack.presence(FluidTanks.get_fluid(new_pos, id6))
        local capacity, err = FluidTanks.get_capacity(new_pos, id6)

        if capacity_port > 0 then
          if capacity then
            --print("Reporting capacity to port", capacity_port, minetest.pos_to_string(new_pos), capacity)
            data_network:send_value(pos, node, capacity_port, capacity)
          else
            --print("no capacity", minetest.pos_to_string(new_pos), id6, node.name, err)
            data_network:send_value(pos, node, capacity_port, 0)
          end
        end

        if amount_port > 0 then
          if fluid_stack then
            --print("Reporting fluid_stack.amount to port 2", minetest.pos_to_string(new_pos), fluid_stack.amount)
            data_network:send_value(pos, node, amount_port, fluid_stack.amount)
          else
            data_network:send_value(pos, node, amount_port, 0)
          end
        end

        if remaining_capacity_port > 0 then
          if capacity then
            if fluid_stack then
              local remaining_capacity = capacity - fluid_stack.amount
              data_network:send_value(pos, node, remaining_capacity_port, remaining_capacity)
            else
              data_network:send_value(pos, node, remaining_capacity_port, capacity)
            end
          else
            data_network:send_value(pos, node, remaining_capacity_port, 0)
          end
        end

        if fluid_test_port > 0 then
          if fluid_stack then
            data_network:send_value(pos, node, fluid_test_port, 1)
          else
            data_network:send_value(pos, node, fluid_test_port, 0)
          end
        end

        if empty_test_port > 0 then
          if fluid_stack then
            data_network:send_value(pos, node, empty_test_port, 0)
          else
            data_network:send_value(pos, node, empty_test_port, 1)
          end
        end

        -- Only the first fluid interface is interacted with
        break
      end
    end
  end
end

function fluid_sensor_data_interface:on_load(pos, node)
end

function fluid_sensor_data_interface:receive_pdu(pos, node, dir, port, value)
end

local function fluid_sensor_on_construct(pos)
  --
  local meta = minetest.get_meta(pos)

  meta:set_int("capacity_port", 0)
  meta:set_int("amount_port", 0)
  meta:set_int("remaining_capacity_port", 0)
  meta:set_int("fluid_test_port", 0)
  meta:set_int("empty_test_port", 0)
end

local function fluid_sensor_after_place_node(pos, _placer, _item_stack, _pointed_thin)
  print("fluid_sensor_after_place_node", minetest.pos_to_string(pos))
  local node = minetest.get_node(pos)
  data_network:add_node(pos, node)
end

local function fluid_sensor_on_destruct(pos, old_node)
  print("fluid_sensor_on_destruct", minetest.pos_to_string(pos))
  --
  data_network:unregister_member(pos, old_node)
end

local function fluid_sensor_after_destruct(pos, old_node)
  data_network:unregister_member(pos, old_node)
end

local fluid_sensor_node_box = {
  type = "connected",
  fixed          = ng(3, 3, 3,10,10,10),
  connect_top    = ng(2,13, 2,12, 3,12), -- y+
  connect_bottom = ng(2, 0, 2,12, 3,12), -- y-
  connect_front  = ng(4, 0, 0, 8,13, 3), -- z-
  connect_back   = ng(4, 0,13, 8,13, 3), -- z+
  connect_left   = ng(0, 0, 4, 3,13, 8), -- x-
  connect_right  = ng(13,0, 4, 3,13, 8), -- x+
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

minetest.register_node("yatm_data_fluid_sensor:fluid_sensor", {
  codex_entry_id = "yatm_data_fluid_sensor:fluid_sensor",

  description = "Fluid Sensor",

  groups = groups,

  tiles = {
    "yatm_fluid_sensor_side.png",
  },

  paramtype = "none",
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

  on_rightclick = function (pos, node, user)
    local formspec_name = "yatm_data_fluid_sensor:fluid_sensor:" .. minetest.pos_to_string(pos)
    local formspec = get_fluid_sensor_formspec(pos, user)

    yatm_core.show_bound_formspec(user:get_player_name(), formspec_name, formspec, {
      state = { pos = pos, node = node },
      on_receive_fields = fluid_sensor_on_receive_fields
    })
  end,
})
