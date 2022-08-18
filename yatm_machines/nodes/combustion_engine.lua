local mod = yatm_machines
local fspec = assert(foundation.com.formspec.api)
local fluid_fspec = assert(yatm.fluids.formspec)
local energy_fspec = assert(yatm.energy.formspec)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local fluid_registry = assert(yatm.fluids.fluid_registry)
local player_service = assert(nokore.player_service)
local Vector3 = assert(foundation.com.Vector3)

local combustion_engine_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, 0.375, -0.375, 0.5, 0.5}, -- NodeBox1
    {0.375, -0.5, -0.5, 0.5, 0.5, -0.375}, -- NodeBox2
    {-0.375, -0.375, -0.5, 0.375, 0.3125, 0.5}, -- Core
    {-0.1875, 0.3125, -0.1875, 0.1875, 0.375, 0.1875}, -- NodeBox4
    {-0.5, 0.375, -0.5, 0.5, 0.5, -0.375}, -- NodeBox5
    {-0.5, 0.375, 0.375, 0.5, 0.5, 0.5}, -- NodeBox6
    {-0.5, -0.5, -0.5, -0.375, 0.5, -0.375}, -- NodeBox7
    {-0.5, -0.5, 0.375, 0.5, -0.375, 0.5}, -- NodeBox8
    {-0.5, -0.5, -0.5, 0.5, -0.375, -0.375}, -- NodeBox9
    {0.375, -0.5, 0.375, 0.5, 0.5, 0.5}, -- NodeBox10
    {0.375, -0.25, -0.25, 0.5, 0.25, 0.25}, -- NodeBox11
    {-0.5, -0.25, -0.25, -0.375, 0.25, 0.25}, -- NodeBox12
  }
}

local combustion_engine_yatm_network = {
  kind = "energy_producer",
  groups = {
    device_controller = 3,
    energy_producer = 1,
    fluid_consumer = 1,
  },

  default_state = "off",
  states = {
    conflict = "yatm_machines:combustion_engine_error",
    error = "yatm_machines:combustion_engine_error",
    off = "yatm_machines:combustion_engine_off",
    on = "yatm_machines:combustion_engine_on",
    idle = "yatm_machines:combustion_engine_idle",
  },

  energy = {
    capacity = 16000,
  }
}

local TANK_NAME = "tank"
local TANK_CAPACITY = 16000
local fluid_interface = yatm.fluids.FluidInterface.new_simple(TANK_NAME, TANK_CAPACITY)

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

function combustion_engine_yatm_network.energy.produce_energy(pos, node, dtime, ot)
  local need_refresh = false
  local should_commit = true
  local energy_produced = 0
  local meta = minetest.get_meta(pos)
  local fluid_stack = FluidMeta.get_fluid_stack(meta, TANK_NAME)

  local nodedef = minetest.registered_nodes[node.name]

  local new_state
  if fluid_stack and fluid_stack.amount > 0 then
    local fluid = fluid_registry.get_fluid(fluid_stack.name)
    if fluid then
      local capacity = fluid_interface._private.capacity
      fluid_stack.amount = 20
      -- TODO: a FluidFuelRegistry
      if fluid.groups.crude_oil then
        -- Crude is absolutely terrible energy wise
        local consumed_stack = FluidMeta.drain_fluid(meta, TANK_NAME, fluid_stack, capacity, capacity, should_commit)
        if consumed_stack and consumed_stack.amount > 0 then
          energy_produced = energy_produced + consumed_stack.amount * 5
          need_refresh = should_commit
          new_state = 'on'
        end
      elseif fluid.groups.heavy_oil then
        -- Heavy oil doesn't produce much energy, but it lasts a bit longer
        local consumed_stack = FluidMeta.drain_fluid(meta, TANK_NAME, fluid_stack, capacity, capacity, should_commit)
        if consumed_stack and consumed_stack.amount > 0 then
          energy_produced = energy_produced + consumed_stack.amount * 10
          need_refresh = should_commit
          new_state = 'on'
        end
      elseif fluid.groups.light_oil then
        -- Light oil produces more energy at the saem fluid cost
        local consumed_stack = FluidMeta.drain_fluid(meta, TANK_NAME, fluid_stack, capacity, capacity, should_commit)
        if consumed_stack and consumed_stack.amount > 0 then
          energy_produced = energy_produced + consumed_stack.amount  * 15
          need_refresh = should_commit
          new_state = 'on'
        end
      else
        new_state = 'idle'
      end
    else
      new_state = 'idle'
    end
  else
    new_state = 'idle'
  end

  if nodedef.yatm_network.state ~= new_state then
    cluster_devices:schedule_transition_node(pos, node, new_state)
  end

  meta:set_int("last_energy_produced", energy_produced)

  if need_refresh then
    yatm.queue_refresh_infotext(pos, node)
  end

  return energy_produced
end

function combustion_engine_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local tank_fluid_stack = FluidMeta.get_fluid_stack(meta, TANK_NAME)
  local capacity = fluid_interface._private.capacity

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Tank: " .. FluidStack.pretty_format(tank_fluid_stack, capacity) .. "\n" ..
    "Last Energy Produced: " .. meta:get_int("last_energy_produced")

  meta:set_string("infotext", infotext)
end

function combustion_engine_transition_device_state(pos, _node, state)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  local meta = minetest.get_meta(pos)

  local tank_fluid_stack = FluidMeta.get_fluid_stack(meta, TANK_NAME)

  local new_node_name = node.name

  if state == "conflict" then
    new_node_name = nodedef.yatm_network.states["conflict"]
  elseif state == "error" then
    new_node_name = nodedef.yatm_network.states["error"]
  elseif state == "idle" then
    new_node_name = nodedef.yatm_network.states["idle"]
  elseif state == "up" or state == "on" then
    if tank_fluid_stack and tank_fluid_stack.amount > 0 then
      new_node_name = nodedef.yatm_network.states["on"]
    else
      new_node_name = nodedef.yatm_network.states["idle"]
    end
  elseif state == "down" or state == "off" then
    -- this shouldn't actually happen...
    new_node_name = nodedef.yatm_network.states["off"]
  end

  if node.name ~= new_node_name then
    node.name = new_node_name
    minetest.swap_node(pos, node)

    cluster_devices:schedule_update_node(pos, node)
    cluster_energy:schedule_update_node(pos, node)
  end
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  -- local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, 8, 4, { bg = "machine_electric" }, function (loc, rect)
    if loc == "main_body" then
      local fluid_stack = FluidMeta.get_fluid_stack(meta, TANK_NAME)

      return fluid_fspec.render_fluid_stack(
          rect.x,
          rect.y,
          1,
          cis(4),
          fluid_stack,
          TANK_CAPACITY
        ) ..
        energy_fspec.render_meta_energy_gauge(
          rect.x + cis(7),
          rect.y,
          1,
          cis(4),
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
  return "yatm_machines:combustion_engine:"..Vector3.to_string(pos)
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

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("combustion_engine"),

  basename = mod:make_name("combustion_engine"),

  description = mod.S("Combustion Engine"),

  groups = {
    cracky = 1,
    fluid_interface_in = 1,
    yatm_energy_device = 1,
  },

  drop = combustion_engine_yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_combustion_engine_top.off.png",
    "yatm_combustion_engine_bottom.off.png",
    "yatm_combustion_engine_side.off.png",
    "yatm_combustion_engine_side.off.png",
    "yatm_combustion_engine_back.off.png",
    "yatm_combustion_engine_front.off.png",
  },
  drawtype = "nodebox",
  node_box = combustion_engine_nodebox,

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = combustion_engine_yatm_network,

  fluid_interface = fluid_interface,

  refresh_infotext = combustion_engine_refresh_infotext,

  transition_device_state = combustion_engine_transition_device_state,

  on_rightclick = on_rightclick,
}, {
  on = {
    tiles = {
      "yatm_combustion_engine_top.on.png",
      "yatm_combustion_engine_bottom.on.png",
      "yatm_combustion_engine_side.on.png",
      "yatm_combustion_engine_side.on.png",
      "yatm_combustion_engine_back.on.png",
      "yatm_combustion_engine_front.on.png",
    },
  },
  error = {
    tiles = {
      "yatm_combustion_engine_top.error.png",
      "yatm_combustion_engine_bottom.error.png",
      "yatm_combustion_engine_side.error.png",
      "yatm_combustion_engine_side.error.png",
      "yatm_combustion_engine_back.error.png",
      "yatm_combustion_engine_front.error.png",
    },
  },
  idle = {
    tiles = {
      "yatm_combustion_engine_top.idle.png",
      "yatm_combustion_engine_bottom.idle.png",
      "yatm_combustion_engine_side.idle.png",
      "yatm_combustion_engine_side.idle.png",
      "yatm_combustion_engine_back.idle.png",
      "yatm_combustion_engine_front.idle.png",
    },
  }
})

--
-- Creative Engine
--
local creative_engine_yatm_network = {
  kind = "energy_producer",
  groups = {
    device_controller = 3,
    energy_producer = 1,
  },

  default_state = "off",
  states = {
    conflict = "yatm_machines:creative_engine_error",
    error = "yatm_machines:creative_engine_error",
    off = "yatm_machines:creative_engine_off",
    on = "yatm_machines:creative_engine_on",
    idle = "yatm_machines:creative_engine_idle",
  },

  energy = {
    capacity = 16000,
  }
}

function creative_engine_yatm_network.energy.produce_energy(pos, node, dtime, ot)
  local meta = minetest.get_meta(pos)
  local energy_produced = 4096 * dtime
  meta:set_int("last_energy_produced", energy_produced)
  yatm.queue_refresh_infotext(pos)
  return energy_produced
end

function creative_engine_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Last Energy Produced: " .. meta:get_int("last_energy_produced")

  meta:set_string("infotext", infotext)
end

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_machines:creative_engine",

  basename = "yatm_machines:creative_engine",

  description = mod.S("Creative Engine"),

  groups = {
    cracky = 1,
    yatm_energy_device = 1,
  },

  drop = creative_engine_yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_creative_engine_top.off.png",
    "yatm_creative_engine_bottom.off.png",
    "yatm_creative_engine_side.off.png",
    "yatm_creative_engine_side.off.png",
    "yatm_creative_engine_back.off.png",
    "yatm_creative_engine_front.off.png",
  },
  drawtype = "nodebox",
  node_box = combustion_engine_nodebox,

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = creative_engine_yatm_network,

  refresh_infotext = creative_engine_refresh_infotext,
}, {
  on = {
    tiles = {
      "yatm_creative_engine_top.on.png",
      "yatm_creative_engine_bottom.on.png",
      "yatm_creative_engine_side.on.png",
      "yatm_creative_engine_side.on.png",
      "yatm_creative_engine_back.on.png",
      "yatm_creative_engine_front.on.png",
    },
  },
  error = {
    tiles = {
      "yatm_creative_engine_top.error.png",
      "yatm_creative_engine_bottom.error.png",
      "yatm_creative_engine_side.error.png",
      "yatm_creative_engine_side.error.png",
      "yatm_creative_engine_back.error.png",
      "yatm_creative_engine_front.error.png",
    },
  },
  idle = {
    tiles = {
      "yatm_creative_engine_top.idle.png",
      "yatm_creative_engine_bottom.idle.png",
      "yatm_creative_engine_side.idle.png",
      "yatm_creative_engine_side.idle.png",
      "yatm_creative_engine_back.idle.png",
      "yatm_creative_engine_front.idle.png",
    },
  }
})
