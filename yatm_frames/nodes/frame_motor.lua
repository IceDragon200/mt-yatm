local function frame_reducer(pos, node, context, accessible_dirs)
  local node_id = minetest.hash_node_position(pos)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef.groups.motor_frame then
    context.frames[node_id] = {
      sticky = false,
      pos = pos,
      node = node,
    }

    local frame_data = context.frames[node_id]
    -- is some kind of motor frame
    if nodedef.groups.motor_frame_sticky then
      -- Is a sticky frame
      frame_data.sticky = true
      frame_data.neighbours = {}
    end

    for _,dir in ipairs(yatm_core.DIR6) do
      -- some sticky frames can be rotated, this will return the specified's face's new orientation.
      local new_dir = yatm_core.facedir_to_face(node.param2, dir)
      local sticky_vec3 = yatm_core.DIR6_TO_VEC3[new_dir]
      local sticky_pos = vector.add(pos, sticky_vec3)

      local sticky_node_id = minetest.hash_node_position(sticky_pos)
      local sticky_node = minetest.get_node_or_nil(sticky_pos)

      local sticky_nodedef
      if sticky_node then
        sticky_nodedef = minetest.registered_nodes[sticky_node.name]

        if sticky_nodedef and sticky_nodedef.groups.motor_frame_wire then
          -- wire prevents other frames from connecting together
          -- TODO: optimize the below
          local inverted_sticky_dir = yatm_core.invert_dir(new_dir)
          for _,wire_dir in ipairs(sticky_nodedef.wired_faces) do
            local new_wire_dir = yatm_core.facedir_to_face(sticky_node.param2, wire_dir)
            if new_wire_dir == inverted_sticky_dir then
              accessible_dirs[new_dir] = false
              break
            end
          end
        else
          -- ignore other frames
        end
      end

      if nodedef.sticky_faces and yatm_core.table_key_of(nodedef.sticky_faces, dir) then
        if sticky_node then
          if sticky_node.name == "air" then
            accessible_dirs[new_dir] = false
          elseif sticky_nodedef then
            if sticky_nodedef.groups.motor_frame then
              -- will drag it along like normal
            elseif sticky_nodedef.groups.frame_motor then
              -- check if it's connected to the top face
              local roller_face = yatm_core.facedir_to_face(sticky_node.param2, yatm_core.D_UP)
              local roller_vec3 = yatm_core.DIR6_TO_VEC3[roller_face]

              local roller_pos = vector.add(sticky_pos, roller_vec3)
              if vector.equals(roller_pos, pos) then
                -- this is the same node, ignore it
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
          else
            print("no nodedef for " .. minetest.pos_to_string(sticky_pos))
            accessible_dirs[new_dir] = false
          end
        else
          print("no node for " .. minetest.pos_to_string(sticky_pos))
          accessible_dirs[new_dir] = false
        end
      end

      if nodedef.wired_faces and yatm_core.table_key_of(nodedef.wired_faces, dir) then
        print("is an attached wire face " .. minetest.pos_to_string(sticky_pos))
        accessible_dirs[new_dir] = false
      end
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

      local status, msg = can_move_nodes(nodes, dir)
      if status then
        print("Can move frame")
        move_nodes(nodes, dir)
      else
        print("Cannot move frame", msg)
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

  paramtype = "none",
  paramtype2 = "facedir",

  is_ground_content = false,
})


minetest.register_node("yatm_frames:frame_motor_default_on", {
  basename = "yatm_frames:frame_motor_default",

  description = "Frame Motor",

  codex_entry_id = "yatm_frames:frame_motor",

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

  paramtype = "none",
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

    codex_entry_id = "yatm_frames:frame_motor_mesecon",

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

    paramtype = "none",
    paramtype2 = "facedir",

    mesecons = frame_motor_mesecons,

    is_ground_content = false,
  })


  minetest.register_node("yatm_frames:frame_motor_mesecon_on", {
    basename = "yatm_frames:frame_motor_mesecon",

    description = "Mesecon Frame Motor",

    codex_entry_id = "yatm_frames:frame_motor_mesecon",

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

    paramtype = "none",
    paramtype2 = "facedir",

    mesecons = frame_motor_mesecons,

    is_ground_content = false,
  })
end

--
-- Data Frame Motor
--
if yatm_data_logic then
  local data_network = assert(yatm.data_network)

  local function refresh_infotext(pos, node)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end

  local function frame_motor_on_construct(pos)
    local node = minetest.get_node(pos)

    data_network:add_node(pos, node)
  end

  local function frame_motor_after_destruct(pos, node)
    data_network:unregister_member(pos, node)
  end

  yatm.register_stateful_node("yatm_frames:frame_motor_data", {
    basename = "yatm_frames:frame_motor_data",

    description = "Data Frame Motor",

    codex_entry_id = "yatm_frames:frame_motor_data",

    paramtype = "none",
    paramtype2 = "facedir",

    refresh_infotext = refresh_infotext,

    data_network_device = {
      type = "device",
    },
    data_interface = {
      on_load = function (self, pos, node)
        yatm_data_logic.mark_all_inputs_for_active_receive(pos)
      end,

      receive_pdu = function (self, pos, node, dir, port, value)
        local meta = minetest.get_meta(pos)
        local new_value = yatm_core.string_hex_unescape(value)

        if node.name == "yatm_frames:frame_motor_data_off" then
          if yatm_core.string_hex_unescape(meta:get_string("data_on")) == new_value then
            node.name = "yatm_frames:frame_motor_data_on"
            minetest.swap_node(pos, node)
            motor_move_frame(pos, node)
            minetest.get_node_timer(pos):start(0.25)
          end
        elseif node.name == "yatm_frames:frame_motor_data_on" then
          local timer = minetest.get_node_timer(pos)
          if not timer:is_started() then
            timer:start(0.25)
          end
        end
      end,

      get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
        --
        local meta = minetest.get_meta(pos)

        assigns.tab = assigns.tab or 1
        local formspec =
          "size[8,9]" ..
          yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
          "tabheader[0,0;tab;Ports,Data;" .. assigns.tab .. "]"

        if assigns.tab == 1 then
          formspec =
            formspec ..
            "label[0,0;Port Configuration]"

          local io_formspec = yatm_data_logic.get_io_port_formspec(pos, meta, "io")

          formspec =
            formspec ..
            io_formspec

        elseif assigns.tab == 2 then
          formspec =
            formspec ..
            "label[0,0;Data Configuration]" ..
            "label[0,1;Data Trigger]" ..
            "label[4,1;On (Data to trigger ON state)]" ..
            "field[4.25,2;4,4;data_on;Data;" .. minetest.formspec_escape(meta:get_string("data_on")) .. "]" ..
            "label[0,1;Off (Data when the motor returns to it's off state)]" ..
            "field[0.25,2;4,4;data_off;Data;" .. minetest.formspec_escape(meta:get_string("data_off")) .. "]" ..
            ""
        end

        return formspec
      end,

      receive_programmer_fields = function (self, player, form_name, fields, assigns)
        local meta = minetest.get_meta(assigns.pos)

        local needs_refresh = false

        if fields["tab"] then
          local tab = tonumber(fields["tab"])
          if tab ~= assigns.tab then
            assigns.tab = tab
            needs_refresh = true
          end
        end

        local inputs_changed = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "io")

        if not yatm_core.is_table_empty(inputs_changed) then
          yatm_data_logic.unmark_all_receive(assigns.pos)
          yatm_data_logic.mark_all_inputs_for_active_receive(assigns.pos)
        end

        if fields["data_off"] then
          meta:set_string("data_off", fields["data_off"])
        end

        if fields["data_on"] then
          meta:set_string("data_on", fields["data_on"])
        end

        if needs_refresh then
          local formspec = self:get_programmer_formspec(assigns.pos, player, nil, assigns)
          return true, formspec
        else
          return true
        end
      end,
    },

    on_construct = frame_motor_on_construct,
    after_destruct = frame_motor_after_destruct,

    is_ground_content = false,
  }, {
    off = {
      groups = {
        cracky = 1,
        frame_motor = 1,
        yatm_data_device = 1,
        data_programmable = 1,
      },

      tiles = {
        "yatm_frame_motor_top.off.png",
        "yatm_frame_motor_bottom.png",
        "yatm_frame_motor_side_data.png",
        "yatm_frame_motor_side_data.png",
        "yatm_frame_motor_side_data.png",
        "yatm_frame_motor_side_data.png",
      },
    },
    on = {
      groups = {
        cracky = 1,
        frame_motor = 1,
        yatm_data_device = 1,
        data_programmable = 1,
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

      on_timer = function (pos, elapsed)
        local node = minetest.get_node(pos)
        node.name = "yatm_frames:frame_motor_data_off"
        minetest.swap_node(pos, node)
        yatm_data_logic.emit_output_data(pos, "off")
        return false
      end,
    },
  })
end
