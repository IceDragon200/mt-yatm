local mod = yatm_overhead_rails
local Cuboid = assert(foundation.com.Cuboid)
local ng = assert(Cuboid.new_fast_node_box)
local string_split = assert(foundation.com.string_split)
local table_merge = assert(foundation.com.table_merge)

local FluidInterface = yatm.fluids.FluidInterface
local FluidStack = yatm.fluids.FluidStack
local FluidMeta = yatm.fluids.FluidMeta

local ItemInterface = yatm.items.ItemInterface

local Energy = yatm.energy
local cluster_energy = yatm.cluster.energy
local cluster_devices = yatm.cluster.devices
local cluster_thermal = yatm.cluster.thermal
local data_network = yatm.data_network

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  local infotext =
    string_split(nodedef.description, "\n")[1] .. "\n"

  if data_network then
    infotext =
      infotext ..
      data_network:get_infotext(pos) .. "\n"
  end

  if cluster_thermal then
    infotext =
      infotext ..
      cluster_thermal:get_node_infotext(pos) .. "\n"
  end

  if cluster_energy then
    infotext =
      infotext ..
      cluster_energy:get_node_infotext(pos) .. "\n"
  end

  if cluster_devices then
    infotext =
      infotext ..
      cluster_devices:get_node_infotext(pos) .. "\n"
  end

  meta:set_string("infotext", infotext)
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)

  local inv = meta:get_inventory()
  inv:set_size("main", 4*4)

  if data_network then
    data_network:add_node(pos, node)
  end

  if cluster_energy then
    cluster_energy:schedule_add_node(pos, node)
  end

  if cluster_devices then
    cluster_devices:schedule_add_node(pos, node)
  end

  if cluster_thermal then
    cluster_thermal:schedule_add_node(pos, node)
  end
end

local function after_destruct(pos, node)
  if data_network then
    data_network:remove_node(pos, node)
  end

  if cluster_energy then
    cluster_energy:schedule_remove_node(pos, node)
  end

  if cluster_devices then
    cluster_devices:schedule_add_node(pos, node)
  end

  if cluster_thermal then
    cluster_thermal:schedule_remove_node(pos, node)
  end
end

local function transition_device_state(pos, node, state)
  --
  yatm.queue_refresh_infotext(pos, node)
end

local data_network_device
local data_interface

-- only if the data network is present should the data network interface be implemented
if data_network then
  data_network_device = {
    type = "device",
  }
  data_interface = {
    on_load = function (self, pos, node)
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
    end,
  }
end

local fluid_interface

if FluidInterface then
  fluid_interface = FluidInterface.new_simple("tank", 4000)
end

local item_interface
if ItemInterface then
  item_interface = ItemInterface.new_simple("main")
end

local yatm_network
local ENERGY_CAPACITY = 4000
local ENERGY_BANDWIDTH = 1000
if cluster_energy then
  yatm_network = {
    kind = "energy_storage",
    groups = {
      -- it qualifies as an energy storage device
      energy_storage = 1,
      -- it qualifies as an energy receiver device
      energy_receiver = 1,
    },
    energy = {
      capacity = ENERGY_CAPACITY,

      get_usable_stored_energy = function (pos, node, dtime, ot)
        local meta = minetest.get_meta(pos)
        return Energy.get_energy(meta, "ebuffer")
      end,

      use_stored_energy = function (pos, node, amount_to_consume, dtime, ot)
        local meta = minetest.get_meta(pos)
        return Energy.consume_energy(meta, "ebuffer", amount_to_consume, ENERGY_BANDWIDTH, ENERGY_CAPACITY, true)
      end,

      receive_energy = function (pos, node, energy_left, dtime, ot)
        local meta = minetest.get_meta(pos)
        return Energy.receive_energy(meta, "ebuffer", energy_left, ENERGY_BANDWIDTH, ENERGY_CAPACITY)
      end,
    }
  }
end

-- without the corresponding interface, the groups are a no-op
local groups = {
  cracky = 1,
  overhead_docking_station = 1,

  -- data cluster & interface
  data_programmable = 1,
  yatm_data_device = 1,

  -- fluid interface
  fluid_interface_in = 1,
  fluid_interface_out = 1,
  -- item interface
  item_interface_in = 1,
  item_interface_out = 1,
  -- energy cluster
  yatm_energy_device = 1,
  yatm_cluster_energy = 1,
  yatm_cluster_device = 1,
  -- thermal cluster
  heatable_device = 1,
  yatm_cluster_thermal = 1,
}

minetest.register_node("yatm_overhead_rails:overhead_docking_station", {
  basename = "yatm_overhead_rails:overhead_docking_station",

  base_description = mod.S("Docking Station"),
  description = mod.S("Docking Station"),

  -- when no crate is docked, none of the interfaces are active
  groups = groups,

  tiles = {
    "yatm_overhead_docking_station_base_top.blank.png",
    "yatm_overhead_docking_station_base_bottom.png",
    "yatm_overhead_docking_station_base_side.blank.png",
    "yatm_overhead_docking_station_base_side.blank.png",
    "yatm_overhead_docking_station_base_side.blank.png",
    "yatm_overhead_docking_station_base_side.blank.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 2, 16),
      ng(1, 2, 1, 14, 2, 14),
    },
  },

  paramtype = "light",

  on_construct = on_construct,
  after_destruct = after_destruct,

  data_network_device = data_network_device,
  data_interface = data_interface,

  refresh_infotext = refresh_infotext,

  fluid_interface = fluid_interface,
  item_interface = item_interface,

  yatm_network = yatm_network,

  transition_device_state = transition_device_state,
})

yatm.register_stateful_node("yatm_overhead_rails:overhead_docking_station", {
  base_description = mod.S("Docking Station"),

  groups = groups,

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 2, 16),
      ng(1, 2, 1, 14, 2, 14),
      ng(2, 4, 2, 12, 12, 12),
    },
  },

  paramtype = "light",

  on_construct = on_construct,
  after_destruct = after_destruct,

  data_network_device = data_network_device,
  data_interface = data_interface,

  refresh_infotext = refresh_infotext,

  fluid_interface = fluid_interface,
  item_interface = item_interface,

  yatm_network = yatm_network,

  transition_device_state = transition_device_state,
}, {
  blank = {
    description = mod.S("Docking Station [Empty]"),

    -- empty will activate ALL interfaces
    groups = groups,

    tiles = {
      "yatm_overhead_docking_station_top.blank.wcrate.png",
      "yatm_overhead_docking_station_base_bottom.png",
      "yatm_overhead_docking_station_side.blank.wcrate.png",
      "yatm_overhead_docking_station_side.blank.wcrate.png",
      "yatm_overhead_docking_station_side.blank.wcrate.png",
      "yatm_overhead_docking_station_side.blank.wcrate.png",
    },
  },

  ele = {
    description = mod.S("Docking Station [Elemental]"),

    tiles = {
      "yatm_overhead_docking_station_top.ele.wcrate.png",
      "yatm_overhead_docking_station_base_bottom.png",
      "yatm_overhead_docking_station_side.ele.wcrate.png",
      "yatm_overhead_docking_station_side.ele.wcrate.png",
      "yatm_overhead_docking_station_side.ele.wcrate.png",
      "yatm_overhead_docking_station_side.ele.wcrate.png",
    },
  },

  energy = {
    description = mod.S("Docking Station [Energy]"),

    groups = groups,

    tiles = {
      "yatm_overhead_docking_station_top.energy.wcrate.png",
      "yatm_overhead_docking_station_base_bottom.png",
      "yatm_overhead_docking_station_side.energy.wcrate.png",
      "yatm_overhead_docking_station_side.energy.wcrate.png",
      "yatm_overhead_docking_station_side.energy.wcrate.png",
      "yatm_overhead_docking_station_side.energy.wcrate.png",
    },
  },

  fluid = {
    description = mod.S("Docking Station [Fluids]"),

    groups = groups,

    tiles = {
      "yatm_overhead_docking_station_top.fluid.wcrate.png",
      "yatm_overhead_docking_station_base_bottom.png",
      "yatm_overhead_docking_station_side.fluid.wcrate.png",
      "yatm_overhead_docking_station_side.fluid.wcrate.png",
      "yatm_overhead_docking_station_side.fluid.wcrate.png",
      "yatm_overhead_docking_station_side.fluid.wcrate.png",
    },
  },

  heat = {
    description = mod.S("Docking Station [Heat]"),

    groups = groups,

    tiles = {
      "yatm_overhead_docking_station_top.heat.wcrate.png",
      "yatm_overhead_docking_station_base_bottom.png",
      "yatm_overhead_docking_station_side.heat.wcrate.png",
      "yatm_overhead_docking_station_side.heat.wcrate.png",
      "yatm_overhead_docking_station_side.heat.wcrate.png",
      "yatm_overhead_docking_station_side.heat.wcrate.png",
    },
  },

  item = {
    description = mod.S("Docking Station [Items]"),

    groups = groups,

    tiles = {
      "yatm_overhead_docking_station_top.items.wcrate.png",
      "yatm_overhead_docking_station_base_bottom.png",
      "yatm_overhead_docking_station_side.items.wcrate.png",
      "yatm_overhead_docking_station_side.items.wcrate.png",
      "yatm_overhead_docking_station_side.items.wcrate.png",
      "yatm_overhead_docking_station_side.items.wcrate.png",
    },
  },
})
