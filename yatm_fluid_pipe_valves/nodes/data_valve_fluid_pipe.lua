if not yatm.data_network then
  return
end

local list_concat = assert(foundation.com.list_concat)
local table_merge = assert(foundation.com.table_merge)
local fluid_transport_network = assert(yatm.fluids.fluid_transport_network)
local data_network = assert(yatm.data_network)
local string_hex_unescape = assert(foundation.com.string_hex_unescape)

local on_construct = function (pos)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)

  data_network:add_node(pos, node)
end

local function pipe_after_place_node(pos, _placer, _itemstack, _pointed_thing)
  local node = minetest.get_node(pos)
  fluid_transport_network:register_member(pos, node)
end

local function pipe_on_destruct(pos)
  print("valve_fluid_pipe_on_destruct", minetest.pos_to_string(pos))
end

local function pipe_after_destruct(pos, _old_node)
  print("valve_fluid_pipe_after_destruct", minetest.pos_to_string(pos))
  fluid_transport_network:unregister_member(pos)
  data_network:remove_node(pos, node)
end

local function valve_swap(pos, node, state)
  local nodedef = minetest.registered_nodes[node.name]

  local name = nodedef.fluid_valve_state[state]
  if node.name ~= name then
    local nd = {
      name = name,
      param = node.param,
      param2 = node.param2,
    }
    minetest.swap_node(pos, nd)
    data_network:update_member(pos, nd)
    fluid_transport_network:update_member(pos, nd)
  end
end

local data_interface = {
  on_load = function (self, pos, node)
    yatm_data_logic.mark_all_inputs_for_active_receive(pos)
  end,

  receive_pdu = function (self, pos, node, dir, port, value)
    local bin = string_hex_unescape(value)
    local input = string.byte(bin, 1)

    local meta = minetest.get_meta(pos)

    local data_on_threshold = meta:get_string("data_on_threshold")
    data_on_threshold = string_hex_unescape(data_on_threshold)
    local threshold = string.byte(data_on_threshold, 1) or 0

    if input >= threshold then
      valve_swap(pos, node, 'on')
    else
      valve_swap(pos, node, 'off')
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
            mode = "i",
          }
        },
      },
      {
        tab_id = "data",
        title = "DATA",
        header = "DATA Configuration",
        render = {
          {
            component = "field",
            label = "High Threshold (byte)",
            name = "data_on_threshold",
            type = "string",
            meta = true,
          }
        }
      }
    }
  },

  receive_programmer_fields = {
    tabbed = true, -- notify the solver that tabs are in use
    tabs = {
      {
        components = {
          {
            component = "io_ports",
            mode = "i",
          }
        }
      },
      {
        components = {
          {
            component = "field",
            name = "data_on_threshold",
            type = "string",
            meta = true,
          }
        }
      }
    }
  },
}

local basename = "yatm_fluid_pipe_valves:data_valve_fluid_pipe"
for _,row in ipairs(yatm.colors_with_default) do
  local color_basename = row.name
  local color_name = row.description

  local colored_group_name = "valve_fluid_pipe_" .. color_basename
  local groups = {
    cracky = 1,
    fluid_network_device = 1,
    valve_fluid_pipe = 1,
    [colored_group_name] = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  }

  local node_name = basename .. "_" .. color_basename
  local connects_to = {
    "group:extractor_fluid_device",
    "group:inserter_fluid_device",
  }
  if color_basename == "default" then
    -- default can connect to anything
    table.insert(connects_to, "group:transporter_fluid_pipe")
    table.insert(connects_to, "group:valve_fluid_pipe")
  else
    -- colored pipes can only connect to it's own color OR default
    table.insert(connects_to, "group:" .. colored_group_name)
    table.insert(connects_to, "group:valve_fluid_pipe_default")
    table.insert(connects_to, "group:transporter_fluid_pipe_" .. color_basename)
    table.insert(connects_to, "group:transporter_fluid_pipe_default")
  end

  yatm.register_stateful_node(node_name, {
    basename = basename,
    base_description = "DATA Valve Fluid Pipe",

    description = "DATA Valve Fluid Pipe (" .. color_name .. ")",

    drop = node_name .. "_off",

    groups = groups,

    sounds = yatm.node_sounds:build("metal"),

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = yatm_fluid_pipe_valves.valve_nodebox,

    connects_to = connects_to,

    dye_color = color_basename,

    after_place_node = pipe_after_place_node,
    after_destruct = pipe_after_destruct,
    on_destruct = pipe_on_destruct,

    data_network_device = {
      type = "device",
    },
    data_interface = data_interface,

    fluid_valve_state = {
      off = node_name .. "_off",
      on = node_name .. "_on",
    },
  }, {
    off = {
      tiles = {"yatm_fluid_pipe_valve_data." .. color_basename .. "_valve.off.png"},
      use_texture_alpha = "opaque",

      fluid_transport_device = {
        type = "valve",
        state = "off",
        color = color_basename,
      },
    },
    on = {
      groups = table_merge(groups, {not_in_creative_inventory = 1}),

      tiles = {"yatm_fluid_pipe_valve_data." .. color_basename .. "_valve.on.png"},
      use_texture_alpha = "opaque",

      fluid_transport_device = {
        type = "valve",
        state = "on",
        color = color_basename,
      },
    }
  })
end
