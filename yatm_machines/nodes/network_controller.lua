local network_yatm_network = {
  kind = "controller",
  groups = {controller = 1},
  states = {
    conflict = "yatm_machines:network_controller_error",
    error = "yatm_machines:network_controller_error",
    on = "yatm_machines:network_controller",
    off = "yatm_machines:network_controller_off",
  }
}

local function handle_on_destruct(pos, _old_node)
  -- the controller is about to be lost, destroy it's existing network
  local meta = minetest.get_meta(pos)
  local network_id = yatm_core.Network.get_network_id(meta)
  if network_id then
    print("Destroying network", network_id)
    yatm_core.Network.destroy_network(network_id)
  end
  yatm_core.Network.schedule_refresh_network_topography(pos, {kind = "controller_removed"})
end

local function handle_on_network_changed(pos, node, ts, network_id, state)
  print("NETWORK CHANGED ", pos.x, pos.y, pos.z, node.name, "TS", ts, "NID", network_id, "STATE", state)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.yatm_network then
      local meta = minetest.get_meta(pos)
      if meta then
        yatm_core.Network.set_network_ts(meta, ts)
      end
      if nodedef.yatm_network.states then
        if state == "off" then
        else
          local new_name = nodedef.yatm_network.states[state]
          if new_name then
            if node.name ~= new_name then
              node.name = new_name
              minetest.swap_node(pos, node)
            end
          else
            print("WARN", node.name, "does not have a network state", state)
          end
        end
      end
    end
  end
end

yatm_machines.register_network_device("yatm_machines:network_controller", {
  description = "Network Controller",
  groups = {cracky = 1},
  tiles = {
    "yatm_network_controller_top.off.png",
    "yatm_network_controller_bottom.png",
    "yatm_network_controller_side.off.png",
    "yatm_network_controller_side.off.png^[transformFX",
    "yatm_network_controller_back.off.png",
    "yatm_network_controller_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = network_yatm_network,
  on_destruct = handle_on_destruct,
  after_place_node = yatm_cables.default_yatm_notify_neighbours_changed,
  after_destruct = yatm_cables.default_yatm_notify_neighbours_changed,
  on_yatm_network_changed = handle_on_network_changed,
})

yatm_machines.register_network_device("yatm_machines:network_controller_error", {
  description = "Network Controller",
  drop = "yatm_machines:network_controller",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_network_controller_top.error.png",
    "yatm_network_controller_bottom.png",
    "yatm_network_controller_side.error.png",
    "yatm_network_controller_side.error.png^[transformFX",
    "yatm_network_controller_back.error.png",
    "yatm_network_controller_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = network_yatm_network,
  on_destruct = handle_on_destruct,
  after_place_node = yatm_cables.default_yatm_notify_neighbours_changed,
  after_destruct = yatm_cables.default_yatm_notify_neighbours_changed,
  on_yatm_network_changed = handle_on_network_changed,
})

yatm_machines.register_network_device("yatm_machines:network_controller_on", {
  description = "Network Controller",
  drop = "yatm_machines:network_controller",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    {
      name = "yatm_network_controller_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    "yatm_network_controller_bottom.png",
    {
      name = "yatm_network_controller_side.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    {
      name = "yatm_network_controller_side.on.png^[transformFX",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    "yatm_network_controller_back.on.png",
    "yatm_network_controller_front.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = network_yatm_network,
  on_destruct = handle_on_destruct,
  after_place_node = yatm_cables.default_yatm_notify_neighbours_changed,
  after_destruct = yatm_cables.default_yatm_notify_neighbours_changed,
  on_yatm_network_changed = handle_on_network_changed,
})

minetest.register_abm({
  label = "yatm_machines:network_controller",
  nodenames = {"yatm_machines:network_controller", "yatm_machines:network_controller_on"},
  interval = 1,
  chance = 1,
  action = function (pos, node)
    -- for now, we'll just activate any existing controllers
    if node.name ~= "yatm_machines:network_controller_on" then
      node.name = "yatm_machines:network_controller_on"
      minetest.swap_node(pos, node)
    end

    -- the node has to be active to do anything useful
    if node.name == "yatm_machines:network_controller_on" then
      local meta = minetest.get_meta(pos)
      local network_id = yatm_core.Network.get_network_id(meta)
      if network_id then
        -- it has a valid network
      else
        print("Initializing network controller")
        network_id = yatm_core.Network.create_network(pos)
        yatm_core.Network.set_network_id(meta, network_id)
        yatm_core.Network.schedule_refresh_network_topography(pos, {kind = "controller_initialized"})
        print("NETWORK ESTABLISHED", pos.x, pos.y, pos.z, network_id)
      end
    end
  end
})

minetest.register_lbm({
  name = "yatm_machines:refresh_network",
  nodenames = {"yatm_machines:network_controller", "yatm_machines:network_controller_on"},
  run_at_every_load = true,
  action = function (pos, _node)
    print("SCHEDULE NETWORK REFRESH", pos.x, pos.y, pos.z)
    local meta = minetest.get_meta(pos)
    local network_id = yatm_core.Network.get_network_id(meta)
    if network_id then
      yatm_core.Network.initialize_network(network_id)
    end
    yatm_core.Network.schedule_refresh_network_topography(pos, {kind = "controller_load"})
  end
})
