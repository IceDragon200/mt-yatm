local function frame_reducer(pos, node, context, accessible_dirs)
  local node_id = minetest.hash_node_position(pos)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef.groups.motor_frame then
    -- Is a sticky frame
    if nodedef.groups.motor_frame_sticky then
      context.frames[node_id] = {
        sticky = 6,
        pos = pos,
        node = node,
        neighbours = {}
      }

      local frame_data = context.frames[node_id]
      for sticky_dir,sticky_vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
        local sticky_pos = vector.add(pos, sticky_vec3)

        local sticky_node_id = minetest.hash_node_position(sticky_pos)
        local sticky_node = minetest.get_node_or_nil(sticky_pos)

        if sticky_node then
          if sticky_node.name == "air" then
            accessible_dirs[sticky_dir] = false
          else
            local sticky_nodedef = minetest.registered_nodes[sticky_node.name]

            if sticky_nodedef.groups.motor_frame then
              -- ignore other frames
            elseif sticky_nodedef.groups.frame_motor then
              -- check if it's connected to the top face
              local roller_face = yatm_core.facedir_to_face(sticky_node.param2, yatm_core.D_UP)
              local roller_vec3 = yatm_core.DIR6_TO_VEC3[roller_face]

              local roller_pos = vector.add(sticky_pos, roller_vec3)
              if vector.equals(roller_pos, pos) then
                -- ignore it
              else
                -- pin it
                frame_data.neighbours[sticky_node_id] = {
                  pos = sticky_pos,
                  node = sticky_node,
                }
              end
            else
              frame_data.neighbours[sticky_node_id] = {
                pos = sticky_pos,
                node = sticky_node,
              }
            end
          end
        else
          accessible_dirs[sticky_dir] = false
        end
      end
    elseif nodedef.groups.motor_frame_sticky_one then
      local sticky_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_SOUTH)
      local sticky_vec3 = yatm_core.DIR6_TO_VEC3[sticky_dir]
      local sticky_pos = vector.add(pos, sticky_vec3)

      local sticky_node = minetest.get_node_or_nil(sticky_pos)

      context.frames[node_id] = {
        sticky = 1,
        pos = pos,
        node = node,
        neighbours = {}
      }

      local frame_data = context.frames[node_id]
      if sticky_node then
        local stick_node_id = minetest.hash_node_position(sticky_pos)
        frame_data.neighbours[stick_node_id] = {
          pos = sticky_pos,
          node = sticky_node,
        }
      else
        accessible_dirs[sticky_dir] = false
      end
    else
      context.frames[node_id] = {
        sticky = false,
        pos = pos,
        node = node,
      }
    end
    return true, context
  end
  return false, context
end

local function can_move_nodes(nodes, dir)
  local dir_vec3 = yatm_core.DIR6_TO_VEC3[dir]

  -- Time to check for collisions
  for node_id, pos in pairs(nodes) do
    local next_pos = vector.add(pos, dir_vec3)
    local next_node_id = minetest.hash_node_position(next_pos)

    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]

    if nodedef.can_dig then
      if not nodedef.can_dig(pos) then
        return false, "node cannot be moved"
      end
    end

    if nodes[next_node_id] then
      -- can skip quietly
    else
      -- need to check...
      local next_node = minetest.get_node_or_nil(next_pos)
      if next_node then
        local next_nodedef = minetest.registered_nodes[next_node.name]
        if next_nodedef.buildable_to then
          if next_nodedef.can_dig then
            if next_nodedef.can_dig(pos) then
              -- we can continue
            else
              return false, "node cannot be replaced"
            end
          end
        else
          return false, "cannot move frame, a node blocks the path"
        end
      else
        return false, "cannot determine if safe to move"
      end
    end
  end

  return true
end

local function move_nodes(nodes, dir)
  local dir_vec3 = yatm_core.DIR6_TO_VEC3[dir]
  local frozen_state = {}

  for node_id, pos in pairs(nodes) do
    local new_pos = vector.add(pos, dir_vec3)
    local meta = minetest.get_meta(pos)

    local timer = minetest.get_node_timer(pos)
    local timer_state = false

    if timer:is_started() then
      timer_state = {timer:get_timeout(), timer:get_elapsed()}
    end

    frozen_state[node_id] = {
      new_pos = new_pos,
      old_pos = pos,
      node = minetest.get_node(pos),
      meta = meta:to_table(),
      timer_state = timer_state,
    }
  end

  for node_id, pos in pairs(nodes) do
    minetest.remove_node(pos)
  end

  for node_id, pos in pairs(nodes) do
    local state = frozen_state[node_id]

    minetest.set_node(state.new_pos, state.node)
    minetest.get_meta(state.new_pos):from_table(state.meta)

    if state.timer_state then
      minetest.get_node_timer(state.new_pos):set(unpack(state.timer_state))
    end
  end
end

local function maybe_move_frame(pos, dir)
  local node = minetest.get_node_or_nil(pos)
  if node then
    local nodedef = minetest.registered_nodes[node.name]

    if nodedef.groups.motor_frame then
      local context = {
        frames = {}
      }

      yatm_clusters.explore_nodes(pos, context, frame_reducer)

      --
      -- Create a table of all nodes that will be affected by this frame
      -- This will be used for the collision checking
      -- Any node in this table can be ignored for checking, anything else
      -- needs to be tested
      local nodes = {}

      for node_id, frame in pairs(context.frames) do
        nodes[node_id] = minetest.get_position_from_hash(node_id)

        if frame.neighbours then
          for ne_node_id, _ in pairs(frame.neighbours) do
            nodes[ne_node_id] = minetest.get_position_from_hash(ne_node_id)
          end
        end
      end

      if can_move_nodes(nodes, dir) then
        print("Can move frame")
        move_nodes(nodes, dir)
      else
        print("Cannot move frame")
      end
    end
  end
end

local function motor_move_frame(pos, node)
  -- where is the motor face
  local roller_face = yatm_core.facedir_to_face(node.param2, yatm_core.D_UP)
  -- what direction is the motor facing
  local motor_direction = yatm_core.facedir_to_face(node.param2, yatm_core.D_SOUTH)

  local vec3 = yatm_core.DIR6_TO_VEC3[roller_face]

  maybe_move_frame(vector.add(pos, vec3), motor_direction)
end

--
-- Default Frame Motor
--
minetest.register_node("yatm_frames:frame_motor_default_off", {
  basename = "yatm_frames:frame_motor_default",

  description = "Frame Motor",

  groups = {
    cracky = 1,
    frame_motor = 1,
  },

  tiles = {
    "yatm_frame_motor_top.off.png",
    "yatm_frame_motor_bottom.png",
    "yatm_frame_motor_side.png",
    "yatm_frame_motor_side.png",
    "yatm_frame_motor_side.png",
    "yatm_frame_motor_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  is_ground_content = false,
})


minetest.register_node("yatm_frames:frame_motor_default_on", {
  basename = "yatm_frames:frame_motor_default",

  description = "Frame Motor",

  groups = {
    cracky = 1,
    frame_motor = 1,
    not_in_creative_inventory = 1,
  },

  tiles = {
    "yatm_frame_motor_top.on.png",
    "yatm_frame_motor_bottom.png",
    "yatm_frame_motor_side.png",
    "yatm_frame_motor_side.png",
    "yatm_frame_motor_side.png",
    "yatm_frame_motor_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  is_ground_content = false,
})

--
-- Mesecon Frame Motor
--
if mesecon then
  local frame_motor_mesecons = {
    effector = {
      rules = mesecon.rules.default,

      action_on = function (pos, node)
        print('off', node.name)
        if node.name == "yatm_frames:frame_motor_mesecon_off" then
          node.name = "yatm_frames:frame_motor_mesecon_on"
          minetest.swap_node(pos, node)

          motor_move_frame(pos, node)
        end
      end,

      action_off = function (pos, node)
        print('off', node.name)
        if node.name == "yatm_frames:frame_motor_mesecon_on" then
          node.name = "yatm_frames:frame_motor_mesecon_off"
          minetest.swap_node(pos, node)
        end
      end,
    },
  }

  minetest.register_node("yatm_frames:frame_motor_mesecon_off", {
    basename = "yatm_frames:frame_motor_mesecon",

    description = "Mesecon Frame Motor",

    groups = {
      cracky = 1,
      frame_motor = 1,
    },

    tiles = {
      "yatm_frame_motor_top.off.png",
      "yatm_frame_motor_bottom.png",
      "yatm_frame_motor_side_mesecon.off.png",
      "yatm_frame_motor_side_mesecon.off.png",
      "yatm_frame_motor_side_mesecon.off.png",
      "yatm_frame_motor_side_mesecon.off.png",
    },

    paramtype = "light",
    paramtype2 = "facedir",

    mesecons = frame_motor_mesecons,

    is_ground_content = false,
  })


  minetest.register_node("yatm_frames:frame_motor_mesecon_on", {
    basename = "yatm_frames:frame_motor_mesecon",

    description = "Mesecon Frame Motor",

    groups = {
      cracky = 1,
      frame_motor = 1,
      not_in_creative_inventory = 1,
    },

    tiles = {
      "yatm_frame_motor_top.on.png",
      "yatm_frame_motor_bottom.png",
      "yatm_frame_motor_side_mesecon.on.png",
      "yatm_frame_motor_side_mesecon.on.png",
      "yatm_frame_motor_side_mesecon.on.png",
      "yatm_frame_motor_side_mesecon.on.png",
    },

    paramtype = "light",
    paramtype2 = "facedir",

    mesecons = frame_motor_mesecons,

    is_ground_content = false,
  })
end

--
-- Data Frame Motor
--
if yatm_data_network then
  local data_network = assert(yatm.data_network)

  local function refresh_infotext(pos, node)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end

  local frame_motor_data_network_device = {
    type = "device",
  }

  local frame_motor_data_interface = {}

  function frame_motor_data_interface.on_load(self, pos, node)
  end

  function frame_motor_data_interface.receive_pdu(self, pos, node, dir, port, value)
    --
  end

  local function frame_motor_on_construct(pos)
    local node = minetest.get_node(pos)

    data_network:add_node(pos, node)
  end

  local function frame_motor_after_destruct(pos, node)
    data_network:unregister_member(pos, node)
  end

  minetest.register_node("yatm_frames:frame_motor_data_off", {
    basename = "yatm_frames:frame_motor_data",

    description = "Data Frame Motor",

    groups = {
      cracky = 1,
      frame_motor = 1,
      yatm_data_device = 1,
    },

    tiles = {
      "yatm_frame_motor_top.off.png",
      "yatm_frame_motor_bottom.png",
      "yatm_frame_motor_side_data.png",
      "yatm_frame_motor_side_data.png",
      "yatm_frame_motor_side_data.png",
      "yatm_frame_motor_side_data.png",
    },

    paramtype = "light",
    paramtype2 = "facedir",

    refresh_infotext = refresh_infotext,

    data_network_device = frame_motor_data_network_device,
    data_interface = frame_motor_data_interface,

    on_construct = frame_motor_on_construct,
    after_destruct = frame_motor_after_destruct,

    is_ground_content = false,
  })

  minetest.register_node("yatm_frames:frame_motor_data_on", {
    basename = "yatm_frames:frame_motor_data",

    description = "Data Frame Motor",

    groups = {
      cracky = 1,
      frame_motor = 1,
      yatm_data_device = 1,
      not_in_creative_inventory = 1,
    },

    tiles = {
      "yatm_frame_motor_top.on.png",
      "yatm_frame_motor_bottom.png",
      "yatm_frame_motor_side_data.png",
      "yatm_frame_motor_side_data.png",
      "yatm_frame_motor_side_data.png",
      "yatm_frame_motor_side_data.png",
    },

    paramtype = "light",
    paramtype2 = "facedir",

    refresh_infotext = refresh_infotext,

    data_network_device = frame_motor_data_network_device,
    data_interface = frame_motor_data_interface,

    on_construct = frame_motor_on_construct,
    after_destruct = frame_motor_after_destruct,

    is_ground_content = false,
  })
end
