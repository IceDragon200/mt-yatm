local Network = assert(yatm_spacetime.Network)
local teleporter_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (1 / 16) - 0.5, 0.5},
  }
}

--[[
Teleporters transport any players standing on them to the paired telporter port block
]]
local teleporter_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter = 1,
    energy_consumer = 1,
  },
  states = {
    conflict = "yatm_spacetime:teleporter_error",
    error = "yatm_spacetime:teleporter_error",
    off = "yatm_spacetime:teleporter_off",
    on = "yatm_spacetime:teleporter_on",
    inactive = "yatm_spacetime:teleporter_inactive",
  },
  passive_energy_lost = 5
}

local function find_all_connected_relays(pos, collected)
  local to_visit = {
    vector.add(pos, yatm_core.V3_NORTH),
    vector.add(pos, yatm_core.V3_EAST),
    vector.add(pos, yatm_core.V3_SOUTH),
    vector.add(pos, yatm_core.V3_WEST),
    vector.add(pos, yatm_core.V3_DOWN),
    vector.add(pos, yatm_core.V3_UP),
  }
  local visited = {}
  for hash,vpos in pairs(collected) do
    visited[hash] = vpos
  end
  while not yatm_core.is_table_empty(to_visit) do
    local old_to_visit = to_visit
    to_visit = {}

    for _,vpos in ipairs(old_to_visit) do
      local vhash = minetest.hash_node_position(vpos)
      if not visited[vhash] then
        visited[vhash] = vpos
        local node = minetest.get_node(vpos)
        if node then
          local nodedef = minetest.registered_nodes[node.name]
          if nodedef then
            if nodedef.groups.teleporter_relay then
              collected[vhash] = vpos
              table.insert(to_visit, vector.add(vpos, yatm_core.V3_NORTH))
              table.insert(to_visit, vector.add(vpos, yatm_core.V3_EAST))
              table.insert(to_visit, vector.add(vpos, yatm_core.V3_SOUTH))
              table.insert(to_visit, vector.add(vpos, yatm_core.V3_WEST))
              table.insert(to_visit, vector.add(vpos, yatm_core.V3_DOWN))
              table.insert(to_visit, vector.add(vpos, yatm_core.V3_UP))
            end
          end
        end
      end
    end
  end
  return collected
end

local function maybe_teleport_all_players_on_teleporter(pos, node)
  local meta = minetest.get_meta(pos)
  local address = yatm_spacetime.get_address_in_meta(meta)
  if not yatm_core.is_blank(address) then
    local hash = minetest.hash_node_position(pos)
    local positions = {}
    for h,target_pos in pairs(Network.poses_for_address(address)) do
      if h ~= hash then
        positions[h] = target_pos
      end
    end

    if yatm_core.is_table_empty(positions) then
      print("No target positions!")
    else
      local all_sources = find_all_connected_relays(pos, { [hash] = pos })
      local hashes = yatm_core.table_keys(positions)
      for _,source_pos in pairs(all_sources) do
        local objects = minetest.get_objects_inside_radius(source_pos, 1)
        for _,object in ipairs(objects) do
          if object:is_player() then
            local h = yatm_core.list_sample(hashes)
            local target_pos = positions[h]
            object:set_pos(target_pos)
          end
        end
      end
    end
  else
    print("No address present!")
  end
end

-- Dummy mesecons to force the device to connect to mesecon regardless of it's state
local teleporter_mesecons = {
  effector = {
    rules = mesecon.rules.default,
  },
}

-- This is the mesecon entry used when the teleporter is on
local teleporter_on_mesecons = {
  effector = {
    rules = mesecon.rules.default,

    action_on = function (pos, node)
      maybe_teleport_all_players_on_teleporter(pos, node)
    end,
  },
}

local function teleporter_after_place_node(pos, placer, itemstack, pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()

  yatm_spacetime.copy_address_in_meta(old_meta, new_meta)

  local address = yatm_spacetime.patch_address_in_meta(new_meta)
  yatm_spacetime.Network.register_device(pos, address)

  yatm.devices.device_after_place_node(pos, placer, itemstack, pointed_thing)

  local node = minetest.get_node(pos)
  minetest.after(0, mesecon.on_placenode, pos, node)
end

local function teleporter_on_destruct(pos)
  yatm_spacetime.Network.unregister_device(pos)
  yatm.devices.device_on_destruct(pos)
end

local function teleporter_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = yatm_core.FakeMetaRef:new(old_meta_table)
  local new_meta = stack:get_meta()
  yatm_spacetime.copy_address_in_meta(old_meta, new_meta)
end

local function teleporter_change_address(pos, node, new_address)
  local meta = minetest.get_meta(pos)

  yatm_spacetime.Network.unregister_device(pos)
  yatm_spacetime.set_address_in_meta(meta, new_address)
  yatm_spacetime.Network.register_device(pos, new_address)

  local nodedef = minetest.registered_nodes[node.name]
  if yatm_core.is_blank(new_address) then
    node.name = nodedef.yatm_network.states.inactive
    minetest.swap_node(pos, node)
  else
    node.name = nodedef.yatm_network.states.on
    minetest.swap_node(pos, node)
  end
  return new_address
end

yatm.devices.register_network_device(teleporter_yatm_network.states.off, {
  description = "Teleporter",
  groups = {cracky = 1, spacetime_device = 1, addressable_spacetime_device = 1},
  drop = teleporter_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_top.off.png",
    "yatm_teleporter_bottom.png",
    "yatm_teleporter_side.off.png",
    "yatm_teleporter_side.off.png^[transformFX",
    "yatm_teleporter_side.off.png",
    "yatm_teleporter_side.off.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,
  yatm_network = teleporter_yatm_network,
  mesecons = teleporter_mesecons,

  after_place_node = teleporter_after_place_node,
  on_destruct = teleporter_on_destruct,
  preserve_metadata = teleporter_preserve_metadata,

  change_address = teleporter_change_address,
})

yatm.devices.register_network_device(teleporter_yatm_network.states.error, {
  description = "Teleporter",
  groups = {cracky = 1, spacetime_device = 1, addressable_spacetime_device = 1, not_in_creative_inventory = 1},
  drop = teleporter_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_top.error.png",
    "yatm_teleporter_bottom.png",
    "yatm_teleporter_side.error.png",
    "yatm_teleporter_side.error.png^[transformFX",
    "yatm_teleporter_side.error.png",
    "yatm_teleporter_side.error.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,
  yatm_network = teleporter_yatm_network,
  mesecons = teleporter_mesecons,

  after_place_node = teleporter_after_place_node,
  on_destruct = teleporter_on_destruct,
  preserve_metadata = teleporter_preserve_metadata,

  change_address = teleporter_change_address,
})

yatm.devices.register_network_device(teleporter_yatm_network.states.inactive, {
  description = "Teleporter",
  groups = {cracky = 1, spacetime_device = 1, addressable_spacetime_device = 1, not_in_creative_inventory = 1},
  drop = teleporter_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_top.inactive.png",
    "yatm_teleporter_bottom.png",
    "yatm_teleporter_side.inactive.png",
    "yatm_teleporter_side.inactive.png^[transformFX",
    "yatm_teleporter_side.inactive.png",
    "yatm_teleporter_side.inactive.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,
  yatm_network = teleporter_yatm_network,
  mesecons = teleporter_mesecons,

  after_place_node = teleporter_after_place_node,
  on_destruct = teleporter_on_destruct,
  preserve_metadata = teleporter_preserve_metadata,

  change_address = teleporter_change_address,
})

yatm.devices.register_network_device(teleporter_yatm_network.states.on, {
  description = "Teleporter",
  groups = {cracky = 1, spacetime_device = 1, addressable_spacetime_device = 1, not_in_creative_inventory = 1},
  drop = teleporter_yatm_network.states.off,
  tiles = {
    {
      name = "yatm_teleporter_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    "yatm_teleporter_bottom.png",
    "yatm_teleporter_side.on.png",
    "yatm_teleporter_side.on.png^[transformFX",
    "yatm_teleporter_side.on.png^[transformFX",
    "yatm_teleporter_side.on.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,
  yatm_network = teleporter_yatm_network,
  mesecons = teleporter_on_mesecons,

  after_place_node = teleporter_after_place_node,
  on_destruct = teleporter_on_destruct,
  preserve_metadata = teleporter_preserve_metadata,

  change_address = teleporter_change_address,
})
