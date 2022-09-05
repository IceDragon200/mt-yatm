local mod = yatm_overhead_rails
local Cuboid = assert(foundation.com.Cuboid)
local ng = assert(Cuboid.new_fast_node_box)
local Groups = assert(foundation.com.Groups)
local string_split = assert(foundation.com.string_split)
local table_merge = assert(foundation.com.table_merge)
local ascii_pack = assert(foundation.com.ascii_pack)
local ascii_unpack = assert(foundation.com.ascii_unpack)
local itemstack_is_blank = assert(foundation.com.itemstack_is_blank)

local FluidInterface
local FluidStack
local FluidMeta

if yatm.fluids then
  FluidInterface = yatm.fluids.FluidInterface
  FluidStack = yatm.fluids.FluidStack
  FluidMeta = yatm.fluids.FluidMeta
end

local ItemInterface
if yatm.items then
  ItemInterface = yatm.items.ItemInterface
end
local InventorySerializer = foundation.com.InventorySerializer

local Energy = yatm.energy
local cluster_energy
local cluster_devices
local cluster_thermal

if yatm.cluster then
  cluster_energy = yatm.cluster.energy
  cluster_devices = yatm.cluster.devices
  cluster_thermal = yatm.cluster.thermal
end

local data_network = yatm.data_network

local INVENTORY_SIZE = 4*4 -- 4 rows by 4 cols, i.e. 16
local INVENTORY_NAME = "main"

local FLUID_CAPACITY = 4000

local ENERGY_CAPACITY = 4000
local ENERGY_BANDWIDTH = 1000
local ENERGY_BUFFER_NAME = "ebuffer"

local CRATE_TYPE_TO_DOCKING_STATION = {
  none = "yatm_overhead_rails:overhead_docking_station",
  empty = "yatm_overhead_rails:overhead_docking_station_blank",
  energy = "yatm_overhead_rails:overhead_docking_station_energy",
  ele = "yatm_overhead_rails:overhead_docking_station_ele",
  fluid = "yatm_overhead_rails:overhead_docking_station_fluid",
  heat = "yatm_overhead_rails:overhead_docking_station_heat",
  items = "yatm_overhead_rails:overhead_docking_station_item",
}

local CRATE_TYPE_TO_DOCKING_CRATE = {
  empty = "yatm_overhead_rails:docking_crate_empty",
  energy = "yatm_overhead_rails:docking_crate_energy",
  ele = "yatm_overhead_rails:docking_crate_ele",
  fluid = "yatm_overhead_rails:docking_crate_fluid",
  heat = "yatm_overhead_rails:docking_crate_heat",
  items = "yatm_overhead_rails:docking_crate_items",
}

local function schedule_update_node(pos, node)
  if data_network then
    data_network:update_member(pos, node)
  end

  if cluster_energy then
    cluster_energy:schedule_update_node(pos, node)
  end

  if cluster_devices then
    cluster_devices:schedule_update_node(pos, node)
  end

  if cluster_thermal then
    cluster_thermal:schedule_update_node(pos, node)
  end
end

-- Normally called by the different interfaces to force a crate to transition into a new type
-- if it hasn't already
local function maybe_change_docking_station_crate_type(pos, node, crate_type)
  -- only empty crates can be changed into other crates
  if crate_type == "empty" or CRATE_TYPE_TO_DOCKING_STATION.empty == node.name then
    local new_name = CRATE_TYPE_TO_DOCKING_STATION[crate_type]

    if new_name and new_name ~= node.name then
      local new_node = {
        name = new_name,
        param = node.param,
        param2 = node.param2,
      }
      minetest.swap_node(pos, new_node)
      yatm.queue_refresh_infotext(pos, new_node)
      schedule_update_node(pos, new_node)
    end
  end
end

local function node_is_crate_type(pos, node, crate_type)
  return node.name == CRATE_TYPE_TO_DOCKING_STATION[crate_type]
end

local function reset_docking_station(pos, node)
  local meta = minetest.get_meta(pos)

  -- thermal
  meta:set_float("heat", 0)

  -- energy
  if Energy then
    Energy.set_meta_energy(meta, ENERGY_BUFFER_NAME, 0)
  end

  -- fluid
  if FluidMeta then
    FluidMeta.set_amount(meta, "buffer_tank", 0, true)
  end

  -- items
  local inv = meta:get_inventory()
  inv:set_size(INVENTORY_NAME, INVENTORY_SIZE)
  inv:set_list(INVENTORY_NAME, {})
end

local function reset_crate_contents(pos, node)
  local meta = minetest.get_meta(pos)

  -- thermal
  meta:set_float("heat", 0)

  -- energy
  if Energy then
    Energy.set_meta_energy(meta, ENERGY_BUFFER_NAME, 0)
  end

  -- fluid
  if FluidMeta then
    FluidMeta.set_amount(meta, "buffer_tank", 0, true)
  end

  -- items
  local inv = meta:get_inventory()
  inv:set_size(INVENTORY_NAME, INVENTORY_SIZE)
  inv:set_list(INVENTORY_NAME, {})
end

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

local function on_destruct(pos)
  local node = minetest.get_node_or_nil(pos)

  if data_network then
    data_network:remove_node(pos, node)
  end

  if cluster_energy then
    cluster_energy:schedule_remove_node(pos, node)
  end

  if cluster_devices then
    cluster_devices:schedule_remove_node(pos, node)
  end

  if cluster_thermal then
    cluster_thermal:schedule_remove_node(pos, node)
  end
end

local function after_destruct(pos, node)

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
  fluid_interface = FluidInterface.new_simple("buffer_tank", FLUID_CAPACITY)

  function fluid_interface:on_fluid_changed(pos, dir, fluid_stack)
    local node = minetest.get_node(pos)
    if FluidStack.is_empty(fluid_stack) then
      -- if the stack is now empty, then transition to empty crate
      maybe_change_docking_station_crate_type(pos, node, "empty")
    else
      -- otherwise transition it to the fluid crate
      maybe_change_docking_station_crate_type(pos, node, "fluid")
    end
  end

  function fluid_interface:allow_replace(pos, dir, fluid_stack)
    local node = minetest.get_node(pos)
    if node_is_crate_type(pos, node, "empty") or
       node_is_crate_type(pos, node, "fluid") then
      return true
    end
    return false
  end

  function fluid_interface:allow_fill(pos, dir, fluid_stack)
    local node = minetest.get_node(pos)
    if node_is_crate_type(pos, node, "empty") or
       node_is_crate_type(pos, node, "fluid") then
      return true
    end
    return false
  end

  function fluid_interface:allow_drain(pos, dir, fluid_stack)
    local node = minetest.get_node(pos)
    if node_is_crate_type(pos, node, "empty") or
       node_is_crate_type(pos, node, "fluid") then
      return true
    end
    return false
  end
end

local item_interface
if ItemInterface then
  item_interface = ItemInterface.new_simple(INVENTORY_NAME)

  local function check_items_transition(pos)
    local node = minetest.get_node(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    if inv:is_empty(INVENTORY_NAME) then
      maybe_change_docking_station_crate_type(pos, node, "empty")
    else
      maybe_change_docking_station_crate_type(pos, node, "items")
    end
  end

  function item_interface:on_insert_item(pos, dir, item_stack)
    check_items_transition(pos)
  end

  function item_interface:on_extract_item(pos, dir, item_stack)
    check_items_transition(pos)
  end

  function item_interface:allow_replace_item(pos, dir, itemstack)
    return false
  end

  function item_interface:allow_insert_item(pos, dir, itemstack)
    local node = minetest.get_node(pos)
    if node_is_crate_type(pos, node, "empty") or
       node_is_crate_type(pos, node, "items") then
      return true
    end
    return false
  end

  function item_interface:allow_extract_item(pos, dir, itemstack)
    local node = minetest.get_node(pos)
    if node_is_crate_type(pos, node, "empty") or
       node_is_crate_type(pos, node, "items") then
      return true
    end
    return false
  end
end

local yatm_network
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
        if node_is_crate_type(pos, node, "energy") then
          local meta = minetest.get_meta(pos)
          return Energy.get_meta_energy(meta, ENERGY_BUFFER_NAME)
        end
        return 0
      end,

      use_stored_energy = function (pos, node, amount_to_consume, dtime, ot)
        if node_is_crate_type(pos, node, "energy") then
          local meta = minetest.get_meta(pos)
          local used = Energy.consume_meta_energy(meta, ENERGY_BUFFER_NAME, amount_to_consume, ENERGY_BANDWIDTH, ENERGY_CAPACITY, true)
          if Energy.get_meta_energy(meta, ENERGY_BUFFER_NAME) <= 0 then
            maybe_change_docking_station_crate_type(pos, node, "empty")
          end
          return used
        end
        return 0
      end,

      receive_energy = function (pos, node, energy_left, dtime, ot)
        if node_is_crate_type(pos, node, "energy") or
           node_is_crate_type(pos, node, "empty") then
          local meta = minetest.get_meta(pos)
          local received = Energy.receive_meta_energy(meta, ENERGY_BUFFER_NAME, energy_left, ENERGY_BANDWIDTH, ENERGY_CAPACITY, true)
          if Energy.get_meta_energy(meta, ENERGY_BUFFER_NAME) > 0 then
            maybe_change_docking_station_crate_type(pos, node, "energy")
          end
          return received
        end
        return 0
      end,
    }
  }
end

local thermal_interface
if cluster_thermal then
  thermal_interface = {
    groups = {
      heater = 1,
      thermal_user = 1,
    },

    update_heat = function (self, pos, node, heat, dtime)
      local meta = minetest.get_meta(pos)

      if node_is_crate_type(pos, node, "heat") or
         node_is_crate_type(pos, node, "empty") then
        if yatm.thermal.update_heat(meta, "heat", heat, 10, dtime) then
          --
        end
        if yatm.thermal.get_heat(meta, "heat") == 0 then
          maybe_change_docking_station_crate_type(pos, node, "empty")
        else
          maybe_change_docking_station_crate_type(pos, node, "heat")
        end
      end
    end,
  }
end

-- without the corresponding interface, the groups are a no-op
local groups = {
  cracky = nokore.dig_class("copper"),
  --
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
  on_destruct = on_destruct,
  after_destruct = after_destruct,

  data_network_device = data_network_device,
  data_interface = data_interface,

  refresh_infotext = refresh_infotext,

  fluid_interface = fluid_interface,
  item_interface = item_interface,
  thermal_interface = thermal_interface,

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

            -- before loading the itemstack, reset the crate contents on the station
            -- at this point, it hasn't actually been swapped
            reset_crate_contents(pos, new_node)

            local keep_node = nodedef.docking_station_spec.load_from_itemstack(pos, new_node, stack)

            if not keep_node then
              -- the crate ended up not loading anything, transition the node into a blank crate
              new_node.name = assert(CRATE_TYPE_TO_DOCKING_STATION.empty)
            end
            minetest.swap_node(pos, new_node)
            schedule_update_node(pos, new_node)
            yatm.queue_refresh_infotext(pos, new_node)
          end
        else
          -- TODO: alert user about this issue
        end
      else
        -- TODO: alert user that they can't add this crate
      end
    end

    return itemstack
  end,
})

-- From this point, it's not dealing with Docking Stations with Crates, which normally can't be
-- used directly, since they will be initialized empty
groups = table_merge(groups, {
  not_in_creative_inventory = 1,
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
  thermal_interface = thermal_interface,

  yatm_network = yatm_network,

  transition_device_state = transition_device_state,

  on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
    if itemstack:is_empty() then
      local nodedef = minetest.registered_nodes[node.name]
      local crate_stack = nodedef.docking_station_spec.get_crate_stack(pos, node)
      itemstack:add_item(crate_stack)
      local new_node = {
        name = CRATE_TYPE_TO_DOCKING_STATION.none,
        param = node.param,
        param2 = node.param2,
      }
      -- with the crate removed, the docking station's state needs to be reset.
      reset_docking_station(pos, new_node)
      schedule_update_node(pos, new_node)
      minetest.swap_node(pos, new_node)
    else
      -- nothing
    end
  end,

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
        return true
      end,

      get_crate_stack = function (pos, node)
        local itemstack = ItemStack(CRATE_TYPE_TO_DOCKING_CRATE.empty)
        return itemstack
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
        return false
      end,

      get_crate_stack = function (pos, node)
        local itemstack = ItemStack(CRATE_TYPE_TO_DOCKING_CRATE.ele)
        return itemstack
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

        local energy = stack_meta:get_int("stored_energy")
        if energy > 0 then
          Energy.set_meta_energy(meta, ENERGY_BUFFER_NAME, energy)
          return true
        end
        return false
      end,

      get_crate_stack = function (pos, node)
        local itemstack = ItemStack(CRATE_TYPE_TO_DOCKING_CRATE.energy)
        local stack_meta = itemstack:get_meta()
        local meta = minetest.get_meta(pos)
        stack_meta:set_int("stored_energy", Energy.get_meta_energy(meta, ENERGY_BUFFER_NAME))
        return itemstack
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
        local fluid_stack = FluidMeta.get_fluid_stack(stack_meta, "stored_fluid")
        if fluid_stack and not FluidStack.is_empty(fluid_stack) then
          FluidMeta.set_fluid(meta, "buffer_tank", fluid_stack, true)
          return true
        end
        return false
      end,

      get_crate_stack = function (pos, node)
        local itemstack = ItemStack(CRATE_TYPE_TO_DOCKING_CRATE.fluid)
        local stack_meta = itemstack:get_meta()
        local meta = minetest.get_meta(pos)
        local fluid_stack = FluidMeta.get_fluid_stack(meta, "buffer_tank")
        FluidMeta.set_fluid(stack_meta, "stored_fluid", fluid_stack, true)
        local infotext = FluidMeta.to_infotext(stack_meta, "stored_fluid", FLUID_CAPACITY)
        foundation.com.append_itemstack_meta_description(itemstack, "\n" .. infotext)
        return itemstack
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

        local heat = stack_meta:get_float("stored_heat")

        if heat ~= 0 then
          meta:set_float("heat", heat)
          return true
        end
        return false
      end,

      get_crate_stack = function (pos, node)
        local itemstack = ItemStack(CRATE_TYPE_TO_DOCKING_CRATE.heat)
        local stack_meta = itemstack:get_meta()
        local meta = minetest.get_meta(pos)

        stack_meta:set_float("stored_heat", meta:get_float("stored_heat"))

        return itemstack
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

    docking_station_spec = {
      load_from_itemstack = function (pos, node, stack)
        local meta = minetest.get_meta(pos)

        local stack_meta = stack:get_meta()

        local blob = stack_meta:get_string("crate_inventory")
        if blob and #blob > 0 then
          if string.sub(blob, 1, 4) == "ASCI" then
            blob = string.sub(blob, 5)
            local serialized_list = ascii_unpack(blob)
            local list = {}
            InventorySerializer.load_list(serialized_list, list)
            local inv = meta:get_inventory()
            inv:set_size(INVENTORY_NAME, INVENTORY_SIZE)
            inv:set_list(INVENTORY_NAME, list)
            return true
          else
            error("cannot load crate inventory, was not packed with ascii_pack it seems")
          end
        else
          return false
        end
      end,

      get_crate_stack = function (pos, node)
        local itemstack = ItemStack(CRATE_TYPE_TO_DOCKING_CRATE.items)
        local stack_meta = itemstack:get_meta()
        local meta = minetest.get_meta(pos)

        local inv = meta:get_inventory()
        local list = inv:get_list(INVENTORY_NAME)
        local serialized_list = InventorySerializer.dump_list(list)
        local blob = ascii_pack(serialized_list)
        stack_meta:set_string("crate_inventory", "ASCI"..blob)

        local infotext = InventorySerializer.description(serialized_list)
        foundation.com.append_itemstack_meta_description(itemstack, "\n" .. infotext)
        return itemstack
      end,
    },
  },
})
