local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)

local function queue_refresh_infotext_for_controllers(pos)
  local cluster = cluster_devices:get_node_cluster(pos)

  if cluster then
    cluster:reduce_nodes_of_groups({"array_energy_controller"}, 0, function (node_entry, acc)
      yatm.queue_refresh_infotext(node_entry.pos)
      return true, acc + 1
    end)
  end
end

local function get_array_energy_interface(node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.yatm_network then
      return nodedef.yatm_network.array_energy
    end
  end

  return nil
end

local function calc_array_capacity(pos)
  local cluster = cluster_devices:get_node_cluster(pos)

  if cluster then
    return cluster:reduce_nodes_of_groups({"array_energy_cell"}, 0, function (node_entry, acc)
      local cell_node = minetest.get_node(node_entry.pos)
      local intf = get_array_energy_interface(cell_node)
      if intf then
        return true, acc + intf.capacity(node_entry.pos, cell_node)
      else
        return true, acc
      end
    end)
  end

  return 0
end

local function array_receive_energy(pos, energy_left, dtime, ot)
  local cluster = cluster_devices:get_node_cluster(pos)

  if cluster then
    local count =
      cluster:reduce_nodes_of_groups({"array_energy_cell"}, 0, function (node_entry, acc)
        return true, acc + 1
      end)

    local energy_per_cell = math.floor(energy_left / count)
    if energy_per_cell == 0 then
      energy_per_cell = energy_left
    end

    return cluster:reduce_nodes_of_groups({"array_energy_cell"}, 0, function (node_entry, acc)
      local cell_node = minetest.get_node(node_entry.pos)
      local intf = get_array_energy_interface(cell_node)
      if intf then
        energy_per_cell = math.min(energy_per_cell, energy_left)
        local energy_received = intf.receive_energy(node_entry.pos, cell_node, energy_per_cell, dtime, ot)
        energy_left = energy_left - energy_received
        return energy_left > 0, acc + energy_received
      else
        return energy_left > 0, acc
      end
    end)
  end

  return 0
end

local function array_get_stored_energy(pos)
  local cluster = cluster_devices:get_node_cluster(pos)

  if cluster then
    return cluster:reduce_nodes_of_groups({"array_energy_cell"}, 0, function (node_entry, acc)
      local cell_node = minetest.get_node(node_entry.pos)
      local intf = get_array_energy_interface(cell_node)
      if intf then
        return true, acc + intf.get_stored_energy(node_entry.pos, cell_node)
      else
        return true, acc
      end
    end)
  end

  return 0
end

local function array_get_usable_stored_energy(pos)
  local cluster = cluster_devices:get_node_cluster(pos)

  if cluster then
    return cluster:reduce_nodes_of_groups({"array_energy_cell"}, 0, function (node_entry, acc)
      local cell_node = minetest.get_node(node_entry.pos)
      local intf = get_array_energy_interface(cell_node)
      if intf then
        return true, acc + intf.get_usable_stored_energy(node_entry.pos, cell_node)
      else
        return true, acc
      end
    end)
  end

  return 0
end

local function array_use_stored_energy(pos, energy_to_use)
  local cluster = cluster_devices:get_node_cluster(pos)

  if cluster then
    return cluster:reduce_nodes_of_groups({"array_energy_cell"}, 0, function (node_entry, acc)
      local cell_node = minetest.get_node(node_entry.pos)
      local intf = get_array_energy_interface(cell_node)
      if intf then
        local energy_used = intf.use_stored_energy(node_entry.pos, cell_node, energy_to_use)
        energy_to_use = energy_to_use - energy_used
        return energy_to_use > 0, acc + energy_used
      else
        return energy_to_use > 0, acc
      end
    end)
  end

  return 0
end

yatm.devices.register_stateful_network_device({
  description = "Array Energy Cell Controller",

  groups = {
    cracky = 1,
    array_energy_cell_controller = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
  },

  tiles = {
    "yatm_array_energy_controller_side.off.png",
  },

  yatm_network = {
    kind = "array_energy_controller",

    groups = {
      array_energy_controller = 1,
      device_controller = 2,
      energy_storage = 1,
      energy_receiver = 1,
    },

    default_state = "off",
    states = {
      error = "yatm_energy_storage_array:array_energy_controller_error",
      conflict = "yatm_energy_storage_array:array_energy_controller_error",
      off = "yatm_energy_storage_array:array_energy_controller_off",
      on = "yatm_energy_storage_array:array_energy_controller_on",
    },

    energy = {
      capacity = function (pos, node)
        return calc_array_capacity(pos)
      end,

      get_stored_energy = function (pos, node)
        return array_get_stored_energy(pos)
      end,

      receive_energy = function (pos, node, energy_left, dtime, ot)
        local received_energy = array_receive_energy(pos, energy_left, dtime, ot)
        if received_energy > 0 then
          queue_refresh_infotext_for_controllers(pos)
        end
        return received_energy
      end,

      get_usable_stored_energy = function (pos, node)
        return array_get_usable_stored_energy(pos)
      end,

      use_stored_energy = function (pos, node, energy_to_use)
        local consumed_energy = array_use_stored_energy(pos, energy_to_use)
        if consumed_energy > 0 then
          queue_refresh_infotext_for_controllers(pos)
        end
        return consumed_energy
      end,
    },
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]

    --local usable = EnergyDevices.get_usable_stored_energy(pos, node)

    local en = array_get_stored_energy(pos)

    local infotext =
      cluster_devices:get_node_infotext(pos) .. "\n" ..
      cluster_energy:get_node_infotext(pos) .. " [" .. en .. " /" .. calc_array_capacity(pos) .. "]"

    meta:set_string("infotext", infotext)
  end,
}, {
  error = {
    tiles = {
      "yatm_array_energy_controller_side.error.png",
    },
  },

  on = {
    tiles = {
      "yatm_array_energy_controller_side.on.png",
    },
  },
})
