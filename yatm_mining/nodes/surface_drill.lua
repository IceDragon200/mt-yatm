local surface_drill_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_mining:surface_drill_error",
    error = "yatm_mining:surface_drill_error",
    off = "yatm_mining:surface_drill_off",
    on = "yatm_mining:surface_drill_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 16000,
    network_charge_bandwidth = 500,
    startup_threshold = 200,
  },
}

local function update_bit(pos, node)
  local new_face = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
  assert(new_face)
  local mine_dirv3 = yatm_core.DIR6_TO_VEC3[new_face]
  local mine_pos = pos
  local bit_node = {
    name = "yatm_mining:surface_drill_bit",
    param2 = node.param2,
  }
  while true do
    mine_pos = vector.add(mine_pos, mine_dirv3)
    local mine_node = minetest.get_node(mine_pos)
    if mine_node.name == "air" then
      --print("SET NODE", mine_pos.x, mine_pos.y, mine_pos.z, bit_node.name, bit_node.param2)
      minetest.set_node(mine_pos, bit_node)
      break
    else
      local mine_nodedef = minetest.registered_nodes[mine_node.name]
      if mine_nodedef then
        if mine_nodedef.groups.surface_drill_bit then
          --print("IS BIT", mine_pos.x, mine_pos.y, mine_pos.z)
          -- TODO check if the bit belongs to the surface drill
        else
          --print("DIGGING", mine_pos.x, mine_pos.y, mine_pos.z, mine_node.name)
          minetest.dig_node(mine_pos)
          break
        end
      else
        break
      end
    end
  end
end

function surface_drill_yatm_network.work(pos, node, energy_available, work_rate, dtime, _ot)
  local meta = minetest.get_meta(pos)
  local timer = meta:get_int("work_timer")
  local new_face = yatm_core.facedir_to_face(node.param2, yatm_core.D_UP)
  assert(new_face)
  local up_dirv3 = yatm_core.DIR6_TO_VEC3[new_face]
  local decr = 1
  local ext_pos = pos
  -- Count all the attached extensions
  while true do
    ext_pos = vector.add(ext_pos, up_dirv3)
    local ext_node = minetest.get_node(ext_pos)
    local ext_nodedef = minetest.registered_nodes[ext_node.name]
    if ext_nodedef then
      --print("node def", ext_pos.x, ext_pos.y, ext_pos.z, ext_node.name)
      if ext_nodedef.groups.surface_drill_ext then
        decr = decr + 1
      else
        break
      end
    else
      --print("No node def", ext_pos.x, ext_pos.y, ext_pos.z, ext_node.name)
      break
    end
  end
  if timer <= 0 then
    update_bit(pos, node)
    timer = 20
  else
    --print("decr timer", decr, pos.x, pos.y, pos.z, node.name)
    timer = timer - decr
  end
  meta:set_int("work_timer", timer)
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_mining:surface_drill",

  description = "Surface Drill",

  codex_entry_id = "yatm_mining:surface_drill",

  groups = {cracky = 1, surface_drill = 1},

  drop = surface_drill_yatm_network.states.off,

  tiles = {
    "yatm_surface_drill_top.off.png",
    "yatm_surface_drill_bottom.png",
    "yatm_surface_drill_side.off.png",
    "yatm_surface_drill_side.off.png^[transformFX",
    "yatm_surface_drill_back.off.png",
    "yatm_surface_drill_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = surface_drill_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_surface_drill_top.error.png",
      "yatm_surface_drill_bottom.png",
      "yatm_surface_drill_side.error.png",
      "yatm_surface_drill_side.error.png^[transformFX",
      "yatm_surface_drill_back.error.png",
      "yatm_surface_drill_front.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_surface_drill_top.on.png",
      "yatm_surface_drill_bottom.png",
      "yatm_surface_drill_side.on.png",
      "yatm_surface_drill_side.on.png^[transformFX",
      "yatm_surface_drill_back.on.png",
      "yatm_surface_drill_front.on.png",
    },
  }
})

local surface_drill_ext_yatm_network = {
  basename = "yatm_mining:surface_drill_ext",
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_mining:surface_drill_ext_error",
    error = "yatm_mining:surface_drill_ext_error",
    off = "yatm_mining:surface_drill_ext_off",
    on = "yatm_mining:surface_drill_ext_on",
  },
  energy = {
    passive_lost = 10,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_mining:surface_drill_ext",

  description = "Surface Drill Extension",

  codex_entry_id = "yatm_mining:surface_drill_ext",

  groups = {cracky = 1, surface_drill_ext = 1},

  drop = surface_drill_ext_yatm_network.states.off,

  tiles = {
    "yatm_surface_drill_top.off.png",
    "yatm_surface_drill_bottom.png",
    "yatm_surface_drill_side.ext.off.png",
    "yatm_surface_drill_side.ext.off.png",
    "yatm_surface_drill_side.ext.off.png",
    "yatm_surface_drill_side.ext.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = surface_drill_ext_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_surface_drill_top.error.png",
      "yatm_surface_drill_bottom.png",
      "yatm_surface_drill_side.ext.error.png",
      "yatm_surface_drill_side.ext.error.png",
      "yatm_surface_drill_side.ext.error.png",
      "yatm_surface_drill_side.ext.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_surface_drill_top.on.png",
      "yatm_surface_drill_bottom.png",
      "yatm_surface_drill_side.ext.on.png",
      "yatm_surface_drill_side.ext.on.png",
      "yatm_surface_drill_side.ext.on.png",
      "yatm_surface_drill_side.ext.on.png",
    },
  }
})

minetest.register_node("yatm_mining:surface_drill_bit", {
  description = "Surface Drill Bit",

  codex_entry_id = "yatm_mining:surface_drill_bit",

  groups = {
    cracky = 1,
    surface_drill_bit = 1,
    not_in_creative_inventory = 1
  },

  tiles = {
    "yatm_surface_drill_bit.top.png",
    "yatm_surface_drill_bit.bottom.png",
    "yatm_surface_drill_bit.side.png",
    "yatm_surface_drill_bit.side.png",
    "yatm_surface_drill_bit.side.png",
    "yatm_surface_drill_bit.side.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, -- NodeBox2
    }
  }
})
