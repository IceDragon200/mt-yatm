local mesecon_hub_node_box = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.375, 0.375, -0.3125, 0.375}, -- NodeBox1
    {-0.25, -0.5, -0.5, 0.25, -0.375, 0.5}, -- NodeBox2
    {-0.5, -0.5, -0.25, 0.5, -0.375, 0.25}, -- NodeBox3
  }
}

local function hub_after_place_node(pos, placer, item_stack, pointed_thing)
  yatm_core.facedir_wallmount_after_place_node(pos, placer, item_stack, pointed_thing)
end

local function hub_effector_rules_get(node)
  local result = {}
  local dir
  dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_NORTH)
  table.insert(result, yatm_core.DIR6_TO_VEC3[dir])

  dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_SOUTH)
  table.insert(result, yatm_core.DIR6_TO_VEC3[dir])

  return result
end

local function hub_receptor_rules_get(node)
  local result = {}
  if node.name == "yatm_mesecon_hubs:mesecon_hub_flip_flop_left" then
    local left = yatm_core.facedir_to_face(node.param2, yatm_core.D_WEST)
    table.insert(result, yatm_core.DIR6_TO_VEC3[left])
  elseif node.name == "yatm_mesecon_hubs:mesecon_hub_flip_flop_right" then
    local right = yatm_core.facedir_to_face(node.param2, yatm_core.D_EAST)
    table.insert(result, yatm_core.DIR6_TO_VEC3[right])
  else
    error("invalid")
  end
  return result
end

local function toggle_hub(pos, node)
  minetest.sound_play("mesecons_button_push", { pos = pos })

  mesecon.receptor_off(pos, hub_receptor_rules_get(node))

  local new_node

  if node.name == "yatm_mesecon_hubs:mesecon_hub_flip_flop_left" then
    new_node = yatm_core.table_merge(node, { name = "yatm_mesecon_hubs:mesecon_hub_flip_flop_right" })
  elseif node.name == "yatm_mesecon_hubs:mesecon_hub_flip_flop_right" then
    new_node = yatm_core.table_merge(node, { name = "yatm_mesecon_hubs:mesecon_hub_flip_flop_left" })
  else
    error("invalid")
  end

  minetest.swap_node(pos, new_node)

  mesecon.receptor_on(pos, hub_receptor_rules_get(new_node))
end

minetest.register_node("yatm_mesecon_hubs:mesecon_hub_flip_flop_left", {
  basename = "yatm_mesecon_hubs:mesecon_hub_flip_flop",

  description = "Mesecon Flip Flop (Left)",
  groups = {
    cracky = 1
  },

  tiles = {
    "yatm_mesecon_hub_top.flip_flop.left.on.png",
    "yatm_mesecon_hub_bottom.png",
    "yatm_mesecon_hub_side.on.png",
    "yatm_mesecon_hub_side.off.png",
    "yatm_mesecon_hub_side.off.png",
    "yatm_mesecon_hub_side.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = mesecon_hub_node_box,

  after_place_node = hub_after_place_node,
  on_rotate = mesecon.buttonlike_onrotate,
  on_blast = mesecon.on_blastnode,

  on_rightclick = toggle_hub,

  mesecons = {
    receptor = {
      state = mesecon.state.on,
      rules = hub_receptor_rules_get,
    },

    effector = {
      rules = hub_effector_rules_get,

      action_on = toggle_hub
    }
  }
})

minetest.register_node("yatm_mesecon_hubs:mesecon_hub_flip_flop_right", {
  basename = "yatm_mesecon_hubs:mesecon_hub_flip_flop",

  description = "Mesecon Flip Flop (Right)",
  groups = {
    cracky = 1
  },

  tiles = {
    "yatm_mesecon_hub_top.flip_flop.right.on.png",
    "yatm_mesecon_hub_bottom.png",
    "yatm_mesecon_hub_side.on.png",
    "yatm_mesecon_hub_side.off.png",
    "yatm_mesecon_hub_side.off.png",
    "yatm_mesecon_hub_side.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = mesecon_hub_node_box,

  after_place_node = hub_after_place_node,
  on_rotate = mesecon.buttonlike_onrotate,
  on_blast = mesecon.on_blastnode,

  on_rightclick = toggle_hub,

  mesecons = {
    receptor = {
      state = mesecon.state.on,
      rules = hub_receptor_rules_get,
    },

    effector = {
      rules = hub_effector_rules_get,

      action_on = toggle_hub,
    }
  }
})
