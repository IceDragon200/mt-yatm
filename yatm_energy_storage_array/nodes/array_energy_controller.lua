--
-- Array Energy Controllers are nodes that act as energy storage nodes in a energy network
-- However they do not store energy directly, instead they join together with array energy cells
-- which act as the energy storage, however those nodes themselves are not actual energy devices.
-- Basically a separation of concern
--
local mod = yatm_energy_storage_array
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local fspec = assert(foundation.com.formspec.api)
local energy_fspec = assert(yatm.energy.formspec)
local player_service = assert(nokore.player_service)
local Vector3 = assert(foundation.com.Vector3)

-- Schedule infotext refresh for all controllers in the node group
local function queue_refresh_infotext_for_controllers(pos)
  local cluster = cluster_devices:get_node_cluster(pos)

  if cluster then
    cluster:reduce_nodes_of_group("array_energy_controller", 0, function (node_entry, acc)
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
    return cluster:reduce_nodes_of_group("array_energy_cell", 0, function (node_entry, acc)
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
    local count = cluster:count_nodes_of_group("array_energy_cell")

    return cluster:reduce_nodes_of_group("array_energy_cell", 0, function (node_entry, acc)
      local cell_node = minetest.get_node(node_entry.pos)
      local intf = get_array_energy_interface(cell_node)
      if intf then
        local energy_received =
          intf.receive_energy(
            node_entry.pos,
            cell_node,
            energy_left,
            dtime,
            ot
          )

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
    return cluster:reduce_nodes_of_group("array_energy_cell", 0, function (node_entry, acc)
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
    return cluster:reduce_nodes_of_group("array_energy_cell", 0, function (node_entry, acc)
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
    return cluster:reduce_nodes_of_group("array_energy_cell", 0, function (node_entry, acc)
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

local yatm_network = {
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
}

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  --local usable = EnergyDevices.get_usable_stored_energy(pos, node)

  local en = array_get_stored_energy(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. " [" .. en .. " /" .. calc_array_capacity(pos) .. "]"

  meta:set_string("infotext", infotext)
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_electric" }, function (loc, rect)
    if loc == "main_body" then
      return energy_fspec.render_meta_energy_gauge(
          rect.x + cio(7),
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
  return "yatm_energy_storage_array:array_energy_controller:"..Vector3.to_string(pos)
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
  basename = "yatm_energy_storage_array:array_energy_controller",

  description = mod.S("Array Energy Cell Controller"),

  drop = yatm_network.states.off,

  groups = {
    cracky = 1,
    array_energy_cell_controller = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
  },

  tiles = {
    "yatm_array_energy_controller_side.off.png",
  },

  yatm_network = yatm_network,

  refresh_infotext = refresh_infotext,

  on_rightclick = on_rightclick,
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
