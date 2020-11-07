--
-- ICBM Silo nodes
-- These are nodes that make up the ICBM assembly
-- The key component is just the silo node though, the guiding rings are decorative for now,
-- and are safe to use on regular builds.
--
-- The Silo has a different data behaviour from those in the data logic series of nodes.
-- While those allowed configuring ports per direction, the silo node has multiple ports for different functions
-- And ignores the origin and destination direction for it's receives and emits.
-- This simplifies the interface a bit.
--
local data_network = assert(yatm.data_network)

local Vector3 = assert(foundation.com.Vector3)
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local Directions = assert(foundation.com.Directions)
local Groups = assert(foundation.com.Groups)
local string_hex_unescape = assert(foundation.com.string_hex_unescape)

-- Deadzone
--   The Silo has a deadzone of up to 8 nodes in any direction, this it to prevent it from blowing itself up with a misconfigured ICBM.
--
-- Required Input Ports:
--   Launch Port - port which commands the silo to launch the icbm to specified offset.
--   Arming Port - port which commands the silo to arm the ICBM, this will consume items in the warhead and shell slots
--   Probing Port - port which asks the silo to report it's current status
--   Offset X Port - The relative X position from the silo to launch the ICBM
--   Offset Y Port - The relative Y position from the silo to launch the ICBM
--   Offset Z Port - The relative Z position from the silo to launch the ICBM
--
-- Optional Output Ports:
--   Error Port - any errors that are generated by the silo are sent to this port
--   Launched Port - port which reports when an ICBM is launched
--   Armed Port - port which reports when an ICBM has been armed
--
-- Values:
--   Launch Code - the launch code is a string of any length that must be matched before an ICBM can be launched
--   Offset X - little-endian i16 (signed 16 bit integer) string representing the X-coord offset from the silo position
--   Offset Y - little-endian i16 (signed 16 bit integer) string representing the Y-coord offset from the silo position
--   Offset Z - little-endian i16 (signed 16 bit integer) string representing the Z-coord offset from the silo position

local ProbeSchema = false

if yatm.BinSchema then
  ProbeSchema =
    yatm.BinSchema:new("icbm_silo.probe", {
      {"offset_x", "i16"},
      {"offset_y", "i16"},
      {"offset_z", "i16"},
      {"status", "i16"},
    })
else
  minetest.log("warning", "BinSchema is not available, ICBM probes will be disabled")
end

local function get_icbm_entity(pos, node)
  local new_dir = Directions.facedir_to_face(node.param2, Directions.D_UP)

  local entities = minetest.get_objects_inside_radius(vector.add(pos, Directions.DIR6_TO_VEC3[new_dir]), 0.9)

  for _, entity in ipairs(entities) do
    local lua_entity = entity:get_luaentity()

    if lua_entity.name == "yatm_armoury_icbm:icbm" then
      return entity
    end
  end
  return nil
end

local function launch_icbm(pos, node)
  local entity = get_icbm_entity(pos, node)
  if entity then
    entity:get_luaentity():launch_icbm()
  end
end

local function count_guiding_rings(pos, node)
  local new_dir = Directions.facedir_to_face(node.param2, Directions.D_UP)
  local up_vec = Directions.DIR6_TO_VEC3[new_dir]

  local count = 0
  local origin = pos

  while true do
    local next_pos = vector.add(origin, up_vec)
    origin = next_pos
    local gnode = minetest.get_node(next_pos)

    if Groups.has_group(gnode, "icbm_guiding_ring") then
      count = count + 1
    else
      break
    end
  end
  return count
end

local function arm_icbm(pos, node)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local warhead_stack = inv:get_stack("warhead_slot", 1)
  local shell_stack = inv:get_stack("shell_slot", 1)

  if warhead_stack:is_empty() then
    return
  end

  if shell_stack:is_empty() then
    return
  end

  local entity = get_icbm_entity(pos, node)
  local new_dir = Directions.facedir_to_face(node.param2, Directions.D_UP)
  local up_vec = Directions.DIR6_TO_VEC3[new_dir]

  if entity then
    --
  else
    entity = minetest.add_entity(vector.add(pos, up_vec), "yatm_armoury_icbm:icbm")
  end

  local params = {}
  local offset = vector.new(meta:get_int("offset_x"),
                            meta:get_int("offset_y"),
                            meta:get_int("offset_z"))
  params.target_pos = vector.add(pos, offset)
  params.origin_pos = pos
  params.origin_dir = up_vec
  params.guide_length = count_guiding_rings(pos, node)
  params.warhead_type = warhead_stack:get_definition().icbm_warhead_type

  entity:get_luaentity():arm_icbm(params)
end

local function bind_input_port(pos, name)
  local meta = minetest.get_meta(pos)
  local port = meta:get_int(name)
  if port > 0 then
    yatm_data_logic.bind_input_port(pos, port, "active")
  end
end

local function rebind_input_port(pos, name, new_port)
  local meta = minetest.get_meta(pos)
  local old_port = meta:get_int(name)

  if old_port > 0 then
    data_network:unmark_ready_to_receive(pos, 0, old_port)
  end

  meta:set_int(name, new_port)
  if new_port > 0 then
    yatm_data_logic.bind_input_port(pos, new_port, "active")
  end
end

local data_interface = {
  on_load = function (self, pos, node)
    yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    bind_input_port(pos, "launch_port")
    bind_input_port(pos, "arming_port")
    bind_input_port(pos, "probing_port")
    bind_input_port(pos, "offset_x_port")
    bind_input_port(pos, "offset_y_port")
    bind_input_port(pos, "offset_z_port")
  end,

  receive_pdu = function (self, pos, node, dir, port, value)
    local meta = minetest.get_meta(pos)

    local blob = string_hex_unescape(value)

    if port == meta:get_int("launch_port") then
      --
      local launch_code = meta:get_string("launch_code")
      if string_hex_unescape(launch_code) == blob then
        launch_icbm(pos, node)
      end
    elseif port == meta:get_int("arming_port") then
      --
      arm_icbm(pos, node)
    elseif port == meta:get_int("probing_port") then
      if ProbeSchema then
        -- Probing asks that the silo report it's current status on it's probe port
        -- This 'probe' packet includes the currently set offsets and a status flag
        local probe_packet =
          ProbeSchema:write({
            offset_x = meta:get_int("offset_x"),
            offset_y = meta:get_int("offset_y"),
            offset_z = meta:get_int("offset_z"),
            status = 0, -- FIXME: proper status codes
          })

        yatm_data_logic.emit_value(pos, meta:get_int("probe_port"), probe_packet)
      else
        minetest.log("warning", "ICBM probing is not available")
      end
    elseif port == meta:get_int("offset_x_port") then
      --
      local offset_value = yatm.ByteDecoder:d_i16(blob)
      meta:set_int("offset_x", offset_value)
      yatm.queue_refresh_infotext(pos, node)
    elseif port == meta:get_int("offset_y_port") then
      --
      local offset_value = yatm.ByteDecoder:d_i16(blob)
      meta:set_int("offset_y", offset_value)
      yatm.queue_refresh_infotext(pos, node)
    elseif port == meta:get_int("offset_z_port") then
      --
      local offset_value = yatm.ByteDecoder:d_i16(blob)
      meta:set_int("offset_z", offset_value)
      yatm.queue_refresh_infotext(pos, node)
    end

    --meta:get_int("error_port")
    --meta:get_int("launched_port")
    --meta:get_int("armed_port")
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
            component = "row",
            items = {
              {
                component = "col",
                items = {
                  {
                    component = "label",
                    label = "Inputs",
                  },
                  {
                    component = "port",
                    name = "offset_x_port",
                  },
                  {
                    component = "port",
                    name = "offset_y_port",
                  },
                  {
                    component = "port",
                    name = "offset_z_port",
                  },
                  {
                    component = "port",
                    name = "launch_port",
                  },
                  {
                    component = "port",
                    name = "arming_port",
                  },
                  {
                    component = "port",
                    name = "probing_port",
                  },
                }
              },
              {
                component = "col",
                items = {
                  {
                    component = "label",
                    label = "Outputs",
                  },
                  {
                    component = "port",
                    name = "error_port",
                  },
                  {
                    component = "port",
                    name = "launched_port",
                  },
                  {
                    component = "port",
                    name = "armed_port",
                  },
                }
              }
            },
          },
        },
      },
      {
        tab_id = "data",
        title = "Data",
        header = "Data Configuration",
        render = {
          {
            component = "field",
            label = "Launch Code",
            name = "launch_code",
            type = "string",
            meta = true,
          }
        },
      }
    }
  },

  receive_programmer_fields = {
    tabbed = true, -- notify the solver that tabs are in use
    tabs = {
      {
        components = {
          {component = "port", name = "offset_x_port", meta = true, rebind = "input", bind_mode = "active"},
          {component = "port", name = "offset_y_port", meta = true, rebind = "input", bind_mode = "active"},
          {component = "port", name = "offset_z_port", meta = true, rebind = "input", bind_mode = "active"},
          {component = "port", name = "launch_port", meta = true, rebind = "input", bind_mode = "active"},
          {component = "port", name = "arming_port", meta = true, rebind = "input", bind_mode = "active"},
          {component = "port", name = "probing_port", meta = true, rebind = "input", bind_mode = "active"},
          {component = "port", name = "error_port", meta = true},
          {component = "port", name = "launched_port", meta = true},
          {component = "port", name = "armed_port", meta = true},
        }
      },
      {
        components = {
          {
            component = "field",
            name = "data_on",
            type = "string",
            meta = true,
          },
          {
            component = "field",
            name = "data_off",
            type = "string",
            meta = true,
          }
        }
      }
    }
  }
}

local function get_formspec_name(pos)
  return "yatm_armoury_icbm:icbm_silo:" .. Vector3.to_string(pos)
end

local function get_formspec(pos, player_name, assigns)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(player_name, "machine_radioactive")

  formspec =
    formspec ..
    "label[0,0;Shell]" ..
    "list[nodemeta:" .. spos .. ";shell_slot;0,1.3;1,1;]" ..
    "label[4,0;Warhead]" ..
    "list[nodemeta:" .. spos .. ";warhead_slot;4,1.3;1,1;]"

  if inv:get_size("capsule_inv") > 0 then
    formspec =
      formspec ..
      "label[0,2.5;Capsule]" ..
      "list[nodemeta:" .. spos .. ";capsule_inv;0,3.3;8,2;]" ..
      "listring[nodemeta:" .. spos .. ";capsule_inv]" ..
      "listring[current_player;main]"
  end

  formspec =
    formspec ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";shell_slot]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";warhead_slot]" ..
    "listring[current_player;main]"

  formspec =
    formspec ..
    "field[1,3;2,1;offset_x;Offset-X;" .. meta:get_int("offset_x") .. "]" ..
    "field[3,3;2,1;offset_y;Offset-Y;" .. meta:get_int("offset_y") .. "]" ..
    "field[5,3;2,1;offset_z;Offset-Z;" .. meta:get_int("offset_z") .. "]" ..
    "field[0.5,4;8,1;launch_code;Launch Code;" .. minetest.formspec_escape(meta:get_string("launch_code")) .. "]"

  return formspec
end

function receive_fields(user, form_name, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)
  if fields["offset_x"] then
    meta:set_int("offset_x", tonumber(fields["offset_x"]))
  end

  if fields["offset_y"] then
    meta:set_int("offset_y", tonumber(fields["offset_y"]))
  end

  if fields["offset_z"] then
    meta:set_int("offset_z", tonumber(fields["offset_z"]))
  end

  if fields["launch_code"] then
    meta:set_string("launch_code", fields["launch_code"])
  end

  if fields["arm"] then
    -- create an ICBM
  elseif fields["disarm"] then
    -- remove armed ICBM
  end
  return true
end

local function refresh_formspec(pos, player)
  minetest.after(0, function ()
    yatm_core.refresh_player_formspec(player, get_formspec_name(pos), function (player_name, assigns)
      return get_formspec(assigns.pos, player_name, assigns)
    end)
  end)
end

local groups = {
  cracky = 1,
  data_programmable = 1,
  yatm_data_device = 1,
}

-- Optional fluid interface
local fluid_interface
if yatm_fluids then
  groups.fluid_interface_in = 1

  local FluidInterface = assert(yatm.fluids.FluidInterface)

  fluid_interface =
    FluidInterface.new_simple("tank", 4000)

  -- TODO: add hooks to refresh timer
end

-- Optional item interface
local item_interface
if yatm_item_storage then
  groups.item_interface_in = 1

  local ItemInterface = assert(yatm.items.ItemInterface)

  item_interface =
    ItemInterface.new_directional(function (self, pos, dir)
      local node = minetest.get_node(pos)
      local new_dir = Directions.facedir_to_face(node.param2, dir)

      if new_dir == Directions.D_DOWN then
        -- load shells from the bottom
        return "shell_slot"
      elseif new_dir == Directions.D_UP then
        -- Can't load anything from the top
        return nil, "cannot interact with top of node"
      else
        -- load warheads from anywhere else
        -- this allows you to use the other directions for cables or fluids
        return "warhead_slot"
      end
    end)

  -- TODO: add hooks to refresh timer
end

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local offset_x = meta:get_int("offset_x")
  local offset_y = meta:get_int("offset_y")
  local offset_z = meta:get_int("offset_z")

  local infotext =
    "ICBM Silo\n" ..
    "Offset: " .. Vector3.to_string(Vector3.new(offset_x, offset_y, offset_z)) .. "\n"

  if fluid_interface then
    -- has fluid interface
    infotext =
      infotext ..
      "Tank: " .. yatm.fluids.FluidMeta.to_infotext(meta, "tank", fluid_interface.capacity) .. "\n"
  end

  if item_interface then
    -- has item interface
    -- nothing to do currently
  end

  meta:set_string("infotext", infotext)
end

function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  if to_list == "warhead_slot" then
    -- FIXME: ensure that origin item is a warhead
  elseif to_list == "shell_slot" then
    -- FIXME: ensure that origin item is a shell
  elseif to_list == "capsule_inv" then
    return 1
  else
    return 0
  end
end

function allow_metadata_inventory_put(pos, listname, index, stack, player)
end

function allow_metadata_inventory_take(pos, listname, index, stack, player)
end

function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
end

function on_metadata_inventory_put(pos, listname, index, stack, player)
end

function on_metadata_inventory_take(pos, listname, index, stack, player)
end

minetest.register_node("yatm_armoury_icbm:icbm_silo", {
  description = "ICBM Silo",

  codex_entry_id = "yatm_armoury_icbm:icbm_silo",

  groups = groups,

  tiles = {
    "yatm_icbm_silo_top.png",
    "yatm_icbm_silo_bottom.png",
    "yatm_icbm_silo_side.png",
    "yatm_icbm_silo_side.png",
    "yatm_icbm_silo_side.png",
    "yatm_icbm_silo_side.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    inv:set_size("warhead_slot", 1)
    inv:set_size("shell_slot", 1)

    meta:set_int("offset_x", 0)
    meta:set_int("offset_y", 0)
    meta:set_int("offset_z", 0)
  end,

  data_network_device = {
    type = "device",
  },
  data_interface = data_interface,

  item_interface = item_interface,
  fluid_interface = fluid_interface,

  on_rightclick = function (pos, node, user, item_stack, pointed_thing)
    local assigns = { pos = pos, node = node }
    local formspec = get_formspec(pos, user, assigns)
    local formspec_name = get_formspec_name(pos)

    yatm_core.show_bound_formspec(user:get_player_name(), formspec_name, formspec, {
      state = assigns,
      on_receive_fields = receive_fields
    })
  end,

  refresh_infotext = refresh_infotext,
})

local node_box = {
  type = "fixed",
  fixed = {
    ng( 0,  2,  0, 15,  4,  1),
    ng( 0, 10,  0, 15,  4,  1),

    ng(15,  2,  0,  1,  4, 15),
    ng(15, 10,  0,  1,  4, 15),

    ng( 1,  2, 15, 15,  4,  1),
    ng( 1, 10, 15, 15,  4,  1),

    ng( 0,  2,  1,  1,  4, 15),
    ng( 0, 10,  1,  1,  4, 15),
  },
}

local single_node_box = {
  type = "fixed",
  fixed = {
    ng( 0,  2,  0, 15, 12,  1),

    ng(15,  2,  0,  1, 12, 15),

    ng( 1,  2, 15, 15, 12,  1),

    ng( 0,  2,  1,  1, 12, 15),
  },
}

minetest.register_node("yatm_armoury_icbm:icbm_guiding_ring", {
  description = "ICBM Guiding Ring (Double Band)",

  codex_entry_id = "yatm_armoury_icbm:icbm_guiding_ring",

  groups = {
    cracky = 1,
    icbm_guiding_ring = 1,
  },

  tiles = {
    "yatm_icbm_guiding_ring_top.png",
    "yatm_icbm_guiding_ring_bottom.png",
    "yatm_icbm_guiding_ring_side.png",
    "yatm_icbm_guiding_ring_side.png",
    "yatm_icbm_guiding_ring_side.png",
    "yatm_icbm_guiding_ring_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  drawtype = "nodebox",
  node_box = node_box,

  is_ground_content = false,
  sunlight_propagates = true,
})

minetest.register_node("yatm_armoury_icbm:icbm_guiding_ring_single", {
  description = "ICBM Guiding Ring (Single Band)",

  codex_entry_id = "yatm_armoury_icbm:icbm_guiding_ring",

  groups = {
    cracky = 1,
    icbm_guiding_ring = 1,
  },

  tiles = {
    "yatm_icbm_guiding_ring_top.png",
    "yatm_icbm_guiding_ring_bottom.png",
    "yatm_icbm_guiding_ring_single_side.png",
    "yatm_icbm_guiding_ring_single_side.png",
    "yatm_icbm_guiding_ring_single_side.png",
    "yatm_icbm_guiding_ring_single_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  drawtype = "nodebox",
  node_box = single_node_box,

  is_ground_content = false,
  sunlight_propagates = true,
})

minetest.register_node("yatm_armoury_icbm:icbm_guiding_ring_warning_strips", {
  description = "ICBM Guiding Ring [Warning Strips] (Double Band)",

  codex_entry_id = "yatm_armoury_icbm:icbm_guiding_ring",

  groups = {
    cracky = 1,
    icbm_guiding_ring = 1,
  },

  tiles = {
    "yatm_icbm_guiding_ring_top.png",
    "yatm_icbm_guiding_ring_bottom.png",
    "yatm_icbm_guiding_ring_warning_side.png",
    "yatm_icbm_guiding_ring_warning_side.png",
    "yatm_icbm_guiding_ring_warning_side.png",
    "yatm_icbm_guiding_ring_warning_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  drawtype = "nodebox",
  node_box = node_box,

  is_ground_content = false,
  sunlight_propagates = true,
})

minetest.register_node("yatm_armoury_icbm:icbm_guiding_ring_single_warning_strips", {
  description = "ICBM Guiding Ring [Warning Strips] (Single Band)",

  codex_entry_id = "yatm_armoury_icbm:icbm_guiding_ring",

  groups = {
    cracky = 1,
    icbm_guiding_ring = 1,
  },

  tiles = {
    "yatm_icbm_guiding_ring_top.png",
    "yatm_icbm_guiding_ring_bottom.png",
    "yatm_icbm_guiding_ring_warning_single_side.png",
    "yatm_icbm_guiding_ring_warning_single_side.png",
    "yatm_icbm_guiding_ring_warning_single_side.png",
    "yatm_icbm_guiding_ring_warning_single_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  drawtype = "nodebox",
  node_box = single_node_box,

  is_ground_content = false,
  sunlight_propagates = true,
})
