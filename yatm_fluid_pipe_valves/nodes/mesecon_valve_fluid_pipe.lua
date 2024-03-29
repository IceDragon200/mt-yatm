local list_concat = assert(foundation.com.list_concat)
local table_merge = assert(foundation.com.table_merge)
local fluid_transport_network = assert(yatm.fluids.fluid_transport_network)

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
end

local basename = "yatm_fluid_pipe_valves:mesecon_valve_fluid_pipe"
for _,row in ipairs(yatm.colors_with_default) do
  local color_basename = row.name
  local color_name = row.description

  local colored_group_name = "valve_fluid_pipe_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    fluid_network_device = 1,
    valve_fluid_pipe = 1,
    [colored_group_name] = 1,
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
    base_description = "Mesecon Valve Fluid Pipe",

    description = "Mesecon Valve Fluid Pipe (" .. color_name .. ")",

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

  }, {
    off = {
      tiles = {"yatm_fluid_pipe_valve_mesecon." .. color_basename .. "_valve.off.png"},
      use_texture_alpha = "opaque",

      fluid_transport_device = {
        type = "valve",
        state = "off",
        color = color_basename,
      },

      mesecons = {
        effector = {
          rules = yatm_fluid_pipe_valves.valve_mesecon_rules,

          action_on = function (pos, node)
            node.name = node_name .. "_on"
            minetest.swap_node(pos, node)
            fluid_transport_network:update_member(pos, node)
          end,
        }
      },
    },
    on = {
      groups = table_merge(groups, {not_in_creative_inventory = 1}),

      tiles = {"yatm_fluid_pipe_valve_mesecon." .. color_basename .. "_valve.on.png"},
      use_texture_alpha = "opaque",

      fluid_transport_device = {
        type = "valve",
        state = "on",
        color = color_basename,
      },

      mesecons = {
        effector = {
          rules = yatm_fluid_pipe_valves.valve_mesecon_rules,

          action_off = function (pos, node)
            node.name = node_name .. "_off"
            minetest.swap_node(pos, node)
            fluid_transport_network:update_member(pos, node)
          end,
        }
      },
    }
  })
end
