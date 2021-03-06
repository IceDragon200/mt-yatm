local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidRegistry = assert(yatm.fluids.FluidRegistry)

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

local fluid_interface = yatm.fluids.FluidInterface.new_simple("tank", 16000)

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

function combustion_engine_yatm_network.energy.produce_energy(pos, node, dtime, ot)
  local need_refresh = false
  local should_commit = true
  local energy_produced = 0
  local meta = minetest.get_meta(pos)
  local fluid_stack = FluidMeta.get_fluid_stack(meta, "tank")

  local nodedef = minetest.registered_nodes[node.name]

  local new_state
  if fluid_stack and fluid_stack.amount > 0 then
    local fluid = FluidRegistry.get_fluid(fluid_stack.name)
    if fluid then
      fluid_stack.amount = 20
      -- TODO: a FluidFuelRegistry
      if fluid.groups.crude_oil then
        -- Crude is absolutely terrible energy wise
        local consumed_stack = FluidMeta.drain_fluid(meta, "tank", fluid_stack, fluid_interface.capacity, fluid_interface.capacity, should_commit)
        if consumed_stack and consumed_stack.amount > 0 then
          energy_produced = energy_produced + consumed_stack.amount * 5
          need_refresh = should_commit
          new_state = 'on'
        end
      elseif fluid.groups.heavy_oil then
        -- Heavy oil doesn't produce much energy, but it lasts a bit longer
        local consumed_stack = FluidMeta.drain_fluid(meta, "tank", fluid_stack, fluid_interface.capacity, fluid_interface.capacity, should_commit)
        if consumed_stack and consumed_stack.amount > 0 then
          energy_produced = energy_produced + consumed_stack.amount * 10
          need_refresh = should_commit
          new_state = 'on'
        end
      elseif fluid.groups.light_oil then
        -- Light oil produces more energy at the saem fluid cost
        local consumed_stack = FluidMeta.drain_fluid(meta, "tank", fluid_stack, fluid_interface.capacity, fluid_interface.capacity, should_commit)
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

  local tank_fluid_stack = FluidMeta.get_fluid_stack(meta, "tank")

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Tank: " .. FluidStack.pretty_format(tank_fluid_stack, fluid_interface.capacity) .. "\n" ..
    "Last Energy Produced: " .. meta:get_int("last_energy_produced")

  meta:set_string("infotext", infotext)
end

function combustion_engine_transition_device_state(pos, _node, state)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  local meta = minetest.get_meta(pos)

  local tank_fluid_stack = FluidMeta.get_fluid_stack(meta, "tank")

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

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:combustion_engine",

  description = "Combustion Engine",

  groups = {
    cracky = 1,
    fluid_interface_in = 1,
    yatm_energy_device = 1,
  },

  drop = combustion_engine_yatm_network.states.off,

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
  basename = "yatm_machines:creative_engine",

  description = "Creative Engine",

  groups = {
    cracky = 1,
    yatm_energy_device = 1,
  },

  drop = creative_engine_yatm_network.states.off,

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
