local Network = assert(yatm_spacetime.Network)

--[[
Teleporter relays are neutral nodes that are placed adjacent to a teleporter to expand it's teleportation effect range
]]
local teleporter_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (1 / 16) - 0.5, 0.5},
  }
}

local teleporter_relay_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter_relay = 1,
    energy_consumer = 1,
  },
  states = {
    conflict = "yatm_spacetime:teleporter_relay_error",
    error = "yatm_spacetime:teleporter_relay_error",
    off = "yatm_spacetime:teleporter_relay_off",
    on = "yatm_spacetime:teleporter_relay_on",
    inactive = "yatm_spacetime:teleporter_relay_inactive",
  },
  passive_energy_lost = 5
}

local function maybe_teleport_all_players_on_teleporter(pos, node)
  local meta = minetest.get_meta(pos)
  local address = yatm_spacetime.get_address_in_meta(meta)
  if not yatm_core.is_blank(address) then
    local target_pos = Network.pos_for_address_from_pos(address, pos)
    if target_pos then
      print("FROM", minetest.pos_to_string(pos), "TO", minetest.pos_to_string(target_pos))
      local objects = minetest.get_objects_inside_radius(pos, 1)
      for _,object in ipairs(objects) do
        if object:is_player() then
          object:set_pos(target_pos)
        end
      end
    else
      print("No target position!")
    end
  else
    print("No address present!")
  end
end

yatm.devices.register_network_device(teleporter_relay_yatm_network.states.off, {
  description = "Teleporter Relay",
  groups = {cracky = 1, spacetime_device = 1},
  drop = teleporter_relay_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_relay_top.off.png",
    "yatm_teleporter_relay_bottom.png",
    "yatm_teleporter_relay_side.off.png",
    "yatm_teleporter_relay_side.off.png^[transformFX",
    "yatm_teleporter_relay_side.off.png",
    "yatm_teleporter_relay_side.off.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,
  yatm_network = teleporter_relay_yatm_network,
})

yatm.devices.register_network_device(teleporter_relay_yatm_network.states.error, {
  description = "Teleporter Relay",
  groups = {cracky = 1, spacetime_device = 1, not_in_creative_inventory = 1},
  drop = teleporter_relay_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_relay_top.error.png",
    "yatm_teleporter_relay_bottom.png",
    "yatm_teleporter_relay_side.error.png",
    "yatm_teleporter_relay_side.error.png^[transformFX",
    "yatm_teleporter_relay_side.error.png",
    "yatm_teleporter_relay_side.error.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,
  yatm_network = teleporter_relay_yatm_network,
})

yatm.devices.register_network_device(teleporter_relay_yatm_network.states.inactive, {
  description = "Teleporter Relay",
  groups = {cracky = 1, spacetime_device = 1, not_in_creative_inventory = 1},
  drop = teleporter_relay_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_relay_top.inactive.png",
    "yatm_teleporter_relay_bottom.png",
    "yatm_teleporter_relay_side.inactive.png",
    "yatm_teleporter_relay_side.inactive.png^[transformFX",
    "yatm_teleporter_relay_side.inactive.png",
    "yatm_teleporter_relay_side.inactive.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,
  yatm_network = teleporter_relay_yatm_network,
})

yatm.devices.register_network_device(teleporter_relay_yatm_network.states.on, {
  description = "Teleporter Relay",
  groups = {cracky = 1, teleporter_relay = 1, spacetime_device = 1, not_in_creative_inventory = 1},
  drop = teleporter_relay_yatm_network.states.off,
  tiles = {
    {
      name = "yatm_teleporter_relay_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    "yatm_teleporter_relay_bottom.png",
    "yatm_teleporter_relay_side.on.png",
    "yatm_teleporter_relay_side.on.png^[transformFX",
    "yatm_teleporter_relay_side.on.png^[transformFX",
    "yatm_teleporter_relay_side.on.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,
  yatm_network = teleporter_relay_yatm_network,
})
