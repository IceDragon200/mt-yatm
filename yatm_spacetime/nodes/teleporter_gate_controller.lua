local mod = assert(yatm_spacetime)

local is_blank = assert(foundation.com.is_blank)
local table_copy = assert(foundation.com.table_copy)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local cluster_gate = assert(yatm.cluster.gate)
local Energy = assert(yatm.energy)
local SpacetimeMeta = assert(yatm.spacetime.SpacetimeMeta)
local spacetime_network = assert(yatm.spacetime.network)
local HeadlessMetaDataRef = assert(foundation.com.headless.MetaDataRef)

local yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter_gate_controller = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = mod:make_name("teleporter_gate_controller_error"),
    error = mod:make_name("teleporter_gate_controller_error"),
    off = mod:make_name("teleporter_gate_controller_off"),
    on = mod:make_name("teleporter_gate_controller_on"),
    idle = mod:make_name("teleporter_gate_controller_idle"),
  },

  energy = {
    capacity = 10000,
    passive_lost = 5,
    network_charge_bandwidth = 10,
    startup_threshold = 20,
  },
}

--- @spec refresh_infotext(Vector3, NodeRef): void
local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n"
    .. cluster_energy:get_node_infotext(pos) .. "\n"
    .. cluster_gate:get_node_infotext(pos) .. "\n"
    .. "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n"
    .. "S.Address: " .. SpacetimeMeta.to_infotext(meta)

  meta:set_string("infotext", infotext)
end

--- @spec on_construct(Vector3): void
local function on_construct(pos)
  local node = minetest.get_node(pos)
  cluster_gate:schedule_add_node(pos, node)
  yatm.devices.device_on_construct(pos)
end

--- @spec after_place_node(Vector3, PlayerRef, ItemStack, PointedThing): void
local function after_place_node(pos, user, item_stack, pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = item_stack:get_meta()

  SpacetimeMeta.copy_address(old_meta, new_meta)
  local address = SpacetimeMeta.patch_address(new_meta)
  local node = minetest.get_node(pos)
  spacetime_network:maybe_register_node(pos, node)

  yatm.devices.device_after_place_node(pos, user, item_stack, pointed_thing)

  yatm.queue_refresh_infotext(pos, node)
end

--- @spec on_destruct(Vector3): void
local function on_destruct(pos)
  local node = minetest.get_node(pos)
  spacetime_network:unregister_device(pos)
  cluster_gate:schedule_remove_node(pos, node)
  yatm.devices.device_on_destruct(pos)
end

--- @spec after_destruct(Vector3, NodeRef): void
local function after_destruct(pos, old_node)
  yatm.devices.device_after_destruct(pos, old_node)
end

--- @spec preserve_metadata(Vector3, NodeRef, Table, ): void
local function preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = HeadlessMetaDataRef:new(old_meta_table)
  local new_meta = stack:get_meta()
  SpacetimeMeta.copy_address(old_meta, new_meta)
end

--- @spec change_spacetime_address(pos: Vector3, NodeRef, new_address: String): String
local function change_spacetime_address(pos, node, new_address)
  local meta = minetest.get_meta(pos)

  SpacetimeMeta.set_address(meta, new_address)

  local nodedef = minetest.registered_nodes[node.name]
  local new_node = table_copy(node)
  if is_blank(new_address) then
    new_node.name = assert(nodedef.yatm_network.states.idle)
  else
    new_node.name = assert(nodedef.yatm_network.states.on)
  end

  if new_node.name ~= node.name then
    minetest.swap_node(pos, new_node)
    spacetime_network:maybe_update_node(pos, new_node)
  end
  yatm.queue_refresh_infotext(pos, new_node)

  return new_address
end

yatm.devices.register_stateful_network_device({
  basename = mod:make_name("teleporter_gate_controller"),

  description = mod.S("Teleporter Gate Controller"),
  groups = {
    cracky = nokore.dig_class("wme"),
    spacetime_device = 1,
    addressable_spacetime_device = 1,
    yatm_cluster_gate = 1,
    yatm_cluster_device = 1,
    yatm_cluster_energy = 1,
  },

  drop = yatm_network.states.off,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_spacetime = {
    groups = {
      gate_controller = 1,
    },
  },

  yatm_network = yatm_network,

  refresh_infotext = refresh_infotext,

  on_construct = on_construct,
  after_place_node = after_place_node,
  on_destruct = on_destruct,
  after_destruct = after_destruct,
  preserve_metadata = preserve_metadata,
  change_spacetime_address = change_spacetime_address,
}, {
  off = {
    use_texture_alpha = "opaque",
    tiles = {
      "yatm_teleporter_gate_controller_top.off.png",
      "yatm_teleporter_gate_controller_bottom.png",
      "yatm_teleporter_gate_controller_side.off.png",
      "yatm_teleporter_gate_controller_side.off.png",
      "yatm_teleporter_gate_controller_side.off.png",
      "yatm_teleporter_gate_controller_front.off.png",
    }
  },

  on = {
    use_texture_alpha = "opaque",
    tiles = {
      "yatm_teleporter_gate_controller_top.on.png",
      "yatm_teleporter_gate_controller_bottom.png",
      "yatm_teleporter_gate_controller_side.on.png",
      "yatm_teleporter_gate_controller_side.on.png",
      "yatm_teleporter_gate_controller_side.on.png",
      "yatm_teleporter_gate_controller_front.on.png",
    }
  },

  error = {
    use_texture_alpha = "opaque",
    tiles = {
      "yatm_teleporter_gate_controller_top.error.png",
      "yatm_teleporter_gate_controller_bottom.png",
      "yatm_teleporter_gate_controller_side.error.png",
      "yatm_teleporter_gate_controller_side.error.png",
      "yatm_teleporter_gate_controller_side.error.png",
      "yatm_teleporter_gate_controller_front.error.png",
    }
  },

  idle = {
    use_texture_alpha = "opaque",
    tiles = {
      "yatm_teleporter_gate_controller_top.idle.png",
      "yatm_teleporter_gate_controller_bottom.png",
      "yatm_teleporter_gate_controller_side.idle.png",
      "yatm_teleporter_gate_controller_side.idle.png",
      "yatm_teleporter_gate_controller_side.idle.png",
      "yatm_teleporter_gate_controller_front.idle.png",
    }
  },
})
