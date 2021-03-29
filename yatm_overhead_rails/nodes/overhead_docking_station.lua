local mod = yatm_overhead_rails
local Cuboid = assert(foundation.com.Cuboid)
local ng = assert(Cuboid.new_fast_node_box)
local Groups = assert(foundation.com.Groups)
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
  fluid_interface = FluidInterface.new_simple("buffer_tank", 4000)
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

local CRATE_TYPE_TO_DOCKING_STATION = {
  empty = "yatm_overhead_rails:overhead_docking_station_blank",
  energy = "yatm_overhead_rails:overhead_docking_station_energy",
  ele = "yatm_overhead_rails:overhead_docking_station_ele",
  fluid = "yatm_overhead_rails:overhead_docking_station_fluid",
  heat = "yatm_overhead_rails:overhead_docking_station_heat",
  items = "yatm_overhead_rails:overhead_docking_station_item",
}

local CRATE_TYPE_TO_DOCKING_CRATE = {
  empty = "yatm_overhead_rails:docking_crate_blank",
  energy = "yatm_overhead_rails:docking_crate_energy",
  ele = "yatm_overhead_rails:docking_crate_ele",
  fluid = "yatm_overhead_rails:docking_crate_fluid",
  heat = "yatm_overhead_rails:docking_crate_heat",
  items = "yatm_overhead_rails:docking_crate_item",
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

  on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
    local itemdef = itemstack:get_definition()

    if Groups.has_group(itemdef, "docking_crate") then
      -- item is a kind of docking crate
      if itemdef.crate_spec and itemdef.crate_spec.type then
        local docking_station_name = CRATE_TYPE_TO_DOCKING_STATION[itemdef.crate_spec.type]

        if docking_station_name then
          local new_node = {
            name = docking_station_name,
            param1 = node.param1,
            param2 = node.param2,
          }
          local nodedef = minetest.registered_nodes[new_node.name]
          if nodedef.docking_station_spec and nodedef.docking_station_spec.load_from_itemstack then
            local stack = itemstack:take_item(1)
            minetest.swap_node(pos, new_node)
            nodedef.docking_station_spec.load_from_itemstack(pos, new_node, stack)
          end
        else
          -- TODO: alert user about this issue
        end
      else
        -- TODO: alert user that they can't add this crate
      end
    end
  end,
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

  on_rightclick = on_rightclick,

  can_dig = function (_pos, _player)
    -- cannot dig up a docking station with a crate on it
    return false
  end,

  crate_spec = {},
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

    crate_spec = {
      type = "empty",
    },

    docking_station_spec = {
      load_from_itemstack = function (pos, node, stack)
        -- blank crates don't have to do anything with the itemstack on reload
      end,
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

    crate_spec = {
      type = "ele",
    },

    docking_station_spec = {
      load_from_itemstack = function (pos, node, stack)
        -- elemental crates should load any elemental information
        -- but this isn't implemented yet, so...
        minetest.log("warning", "TODO: load_from_itemstack for elemental type crates")
      end,
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

    crate_spec = {
      type = "energy",
    },

    docking_station_spec = {
      load_from_itemstack = function (pos, node, stack)
        local meta = minetest.get_meta(pos)

        local stack_meta = stack:get_meta()

        Energy.set_energy(meta, "ebuffer", stack_meta:get_int("stored_energy"))
      end,
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

    crate_spec = {
      type = "fluid",
    },

    docking_station_spec = {
      load_from_itemstack = function (pos, node, stack)
        local meta = minetest.get_meta(pos)

        local stack_meta = stack:get_meta()

        FluidMeta.set_fluid(meta, "buffer_tank", FluidMeta.get_fluid_stack(stack_meta, "stored_fluid"))
      end,
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

    crate_spec = {
      type = "heat",
    },

    docking_station_spec = {
      load_from_itemstack = function (pos, node, stack)
        local meta = minetest.get_meta(pos)

        local stack_meta = stack:get_meta()

        minetest.log("warning", "TODO: load_from_itemstack with heat crate")
      end,
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

    crate_spec = {
      type = "items",
    },
  },
})
