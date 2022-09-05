local Directions = assert(foundation.com.Directions)
local Groups = assert(foundation.com.Groups)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

-- Common

local function thermal_plate_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local thermal_plate_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (3.0 / 16.0) - 0.5, 0.5},
  }
}

local function thermal_plate_after_place_node(pos, placer, item_stack, pointed_thing)
  Directions.facedir_wallmount_after_place_node(pos, placer, item_stack, pointed_thing)
  yatm.devices.device_after_place_node(pos, placer, item_stack, pointed_thing)
end

--
-- Heating Plate - Increases effeciency some some machines,
--                 or may decrease effeciency of some machines.
--
local thermal_plate_heating_yatm_network = {
  kind = "thermal_plate",
  groups = {
    thermal_plate = 1,
    energy_consumer = 1,
    machine_worker = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_machines:thermal_plate_heating_error",
    conflict = "yatm_machines:thermal_plate_heating_error",
    off = "yatm_machines:thermal_plate_heating_off",
    on = "yatm_machines:thermal_plate_heating_on",
  },
  energy = {
    passive_lost = 1,
    capacity = 4000,
    network_charge_bandwidth = 200,
    startup_threshold = 100,
  },
}

-- @private.spec work(yatm.devices.WorkContext): Integer
function thermal_plate_heating_yatm_network:work(ctx)
  -- ctx
  -- Determine where the bottom of the thermal plate is
  local dir = Directions.facedir_to_face(ctx.node.param2, Directions.D_DOWN)

  local target_pos = Vector3.add({}, ctx.pos, Directions.DIR6_TO_VEC3[dir])
  local target_node = minetest.get_node_or_nil(target_pos)

  if target_node then
    local target_nodedef = minetest.registered_nodes[target_node.name]

    if Groups.has_group(target_nodedef, 'uses_heat_modifier') then
      local target_meta = minetest.get_meta(target_pos)

      local heat_modifier = target_meta:get_float(yatm.devices.HEAT_MODIFIER_KEY)

      -- TODO: apply changes

      target_meta:set_float(yatm.devices.HEAT_MODIFIER_KEY, heat_modifier)
    end
  end

  return 0
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      return yatm_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cio(1),
          rect.y,
          1,
          rect.h,
          meta,
          yatm.devices.ENERGY_BUFFER_KEY,
          yatm.devices.get_energy_capacity(pos, state.node)
        )
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_machines:thermal_plate:"..Vector3.to_string(pos)
end

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, user)
  local state = {
    pos = pos,
    node = node,
  }
  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
      timers = {
        -- routinely update the formspec
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
end

local thermal_plate_side_on_texture = {
  name = "yatm_thermal_plate_side.heating.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.0
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:thermal_plate_heating",

  description = "Thermal Plate (heating)",

  groups = {
    cracky = nokore.dig_class("copper"),
  },

  drop = thermal_plate_heating_yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = { "yatm_thermal_plate_side.heating.off.png" },
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  after_place_node = thermal_plate_after_place_node,

  yatm_network = thermal_plate_heating_yatm_network,

  refresh_infotext = thermal_plate_refresh_infotext,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = { "yatm_thermal_plate_side.heating.error.png" },
  },
  on = {
    tiles = { thermal_plate_side_on_texture },
  },
})

--
-- Cooling Plate - increases efficiency of some machines,
--                 or may decrease effeciency of some machines
--
local thermal_plate_cooling_yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_machines:thermal_plate_cooling_error",
    conflict = "yatm_machines:thermal_plate_cooling_error",
    off = "yatm_machines:thermal_plate_cooling_off",
    on = "yatm_machines:thermal_plate_cooling_on",
  },
  energy = {
    passive_lost = 1,
    capacity = 4000,
    network_charge_bandwidth = 200,
    startup_threshold = 100,
  },
}

local thermal_plate_side_on_texture = {
  name = "yatm_thermal_plate_side.cooling.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.0
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:thermal_plate_cooling",

  description = "Thermal Plate (cooling)",

  groups = {
    cracky = nokore.dig_class("copper"),
  },

  drop = thermal_plate_cooling_yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_thermal_plate_side.cooling.off.png",
  },
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  after_place_node = thermal_plate_after_place_node,

  yatm_network = thermal_plate_cooling_yatm_network,

  refresh_infotext = thermal_plate_refresh_infotext,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = { "yatm_thermal_plate_side.cooling.error.png" },
  },
  on = {
    tiles = { thermal_plate_side_on_texture },
  },
})

--
-- Nuclear Plate - protects against radioactivity destroying inventory contents
--
local thermal_plate_nuclear_yatm_network = {
  kind = "thermal_plate",

  groups = {
    thermal_plate = 1,
    nuclear_plate = 1,
    energy_consumer = 1,
  },

  default_state = "off",
  states = {
    error = "yatm_machines:thermal_plate_nuclear_error",
    conflict = "yatm_machines:thermal_plate_nuclear_error",
    off = "yatm_machines:thermal_plate_nuclear_off",
    on = "yatm_machines:thermal_plate_nuclear_on",
  },

  energy = {
    passive_lost = 1,
    capacity = 4000,
    network_charge_bandwidth = 200,
    startup_threshold = 100,
  },
}

local thermal_plate_side_on_texture = {
  name = "yatm_thermal_plate_side.nuclear.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.0
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:thermal_plate_nuclear",

  description = "Thermal Plate (nuclear)",

  groups = {
    cracky = nokore.dig_class("copper"),
    nuclear_plate = 1,
  },

  drop = thermal_plate_nuclear_yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_thermal_plate_side.nuclear.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",

  node_box = thermal_plate_nodebox,

  after_place_node = thermal_plate_after_place_node,

  yatm_network = thermal_plate_nuclear_yatm_network,

  refresh_infotext = thermal_plate_refresh_infotext,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = { "yatm_thermal_plate_side.nuclear.error.png" },
  },
  on = {
    tiles = { thermal_plate_side_on_texture },
  }
})
