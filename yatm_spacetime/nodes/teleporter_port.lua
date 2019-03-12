local teleporter_port_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (1 / 16) - 0.5, 0.5},
  }
}


local function teleporter_port_after_place_node(pos, placer, itemstack, pointed_thing)
  print("teleporter_port_after_place_node/4")
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()

  yatm_spacetime.copy_address_in_meta(old_meta, new_meta)

  local address = yatm_spacetime.patch_address_in_meta(new_meta)

  assert(yatm_spacetime.get_address_in_meta(new_meta) == address)
  yatm_spacetime.Network.register_device(pos, address)

  yatm.devices.device_after_place_node(pos, placer, itemstack, pointed_thing)

  local node = minetest.get_node(pos)
  minetest.after(0, mesecon.on_placenode, pos, node)
end

local function teleporter_port_on_destruct(pos)
  print("teleporter_port_on_destruct/1")
  yatm_spacetime.Network.unregister_device(pos)
  yatm.devices.device_on_destruct(pos)
end

local function teleporter_port_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = yatm_core.FakeMetaRef.new(old_meta_table)
  local new_meta = stack:get_meta()
  yatm_spacetime.copy_address_in_meta(old_meta, new_meta)
end

--[[
Ports are teleporter destinations, by themselves they don't actually do any teleporting.
]]
local teleporter_port_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter_port = 1,
    energy_consumer = 1,
  },
  states = {
    conflict = "yatm_spacetime:teleporter_port_error",
    error = "yatm_spacetime:teleporter_port_error",
    off = "yatm_spacetime:teleporter_port_off",
    on = "yatm_spacetime:teleporter_port_on",
    inactive = "yatm_spacetime:teleporter_port_inactive",
  },
  passive_energy_lost = 5
}

yatm.devices.register_network_device(teleporter_port_yatm_network.states.off, {
  description = "Teleporter Port",
  groups = {cracky = 1, spacetime_device = 1, addressable_spacetime_device = 1},
  drop = teleporter_port_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_port_top.off.png",
    "yatm_teleporter_port_bottom.png",
    "yatm_teleporter_port_side.off.png",
    "yatm_teleporter_port_side.off.png^[transformFX",
    "yatm_teleporter_port_side.off.png",
    "yatm_teleporter_port_side.off.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_port_node_box,
  yatm_network = teleporter_port_yatm_network,

  after_place_node = teleporter_port_after_place_node,
  on_destruct = teleporter_port_on_destruct,
  preserve_metadata = teleporter_port_preserve_metadata,
})

yatm.devices.register_network_device(teleporter_port_yatm_network.states.error, {
  description = "Teleporter Port",
  groups = {cracky = 1, spacetime_device = 1, addressable_spacetime_device = 1, not_in_creative_inventory = 1},
  drop = teleporter_port_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_port_top.error.png",
    "yatm_teleporter_port_bottom.png",
    "yatm_teleporter_port_side.error.png",
    "yatm_teleporter_port_side.error.png^[transformFX",
    "yatm_teleporter_port_side.error.png",
    "yatm_teleporter_port_side.error.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_port_node_box,
  yatm_network = teleporter_port_yatm_network,

  after_place_node = teleporter_port_after_place_node,
  on_destruct = teleporter_port_on_destruct,
  preserve_metadata = teleporter_port_preserve_metadata,
})

yatm.devices.register_network_device(teleporter_port_yatm_network.states.inactive, {
  description = "Teleporter Port",
  groups = {cracky = 1, spacetime_device = 1, addressable_spacetime_device = 1, not_in_creative_inventory = 1},
  drop = teleporter_port_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_port_top.inactive.png",
    "yatm_teleporter_port_bottom.png",
    "yatm_teleporter_port_side.inactive.png",
    "yatm_teleporter_port_side.inactive.png^[transformFX",
    "yatm_teleporter_port_side.inactive.png",
    "yatm_teleporter_port_side.inactive.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_port_node_box,
  yatm_network = teleporter_port_yatm_network,

  after_place_node = teleporter_port_after_place_node,
  on_destruct = teleporter_port_on_destruct,
  preserve_metadata = teleporter_port_preserve_metadata,
})

yatm.devices.register_network_device(teleporter_port_yatm_network.states.on, {
  description = "Teleporter Port",
  groups = {cracky = 1, spacetime_device = 1, addressable_spacetime_device = 1, not_in_creative_inventory = 1},
  drop = teleporter_port_yatm_network.states.off,
  tiles = {
    {
      name = "yatm_teleporter_port_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    "yatm_teleporter_port_bottom.png",
    "yatm_teleporter_port_side.on.png",
    "yatm_teleporter_port_side.on.png^[transformFX",
    "yatm_teleporter_port_side.on.png",
    "yatm_teleporter_port_side.on.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_port_node_box,
  yatm_network = teleporter_port_yatm_network,

  after_place_node = teleporter_port_after_place_node,
  on_destruct = teleporter_port_on_destruct,
  preserve_metadata = teleporter_port_preserve_metadata,
})
