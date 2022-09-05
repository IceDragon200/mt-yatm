local Directions = assert(foundation.com.Directions)
local FakeMetaRef = assert(foundation.com.FakeMetaRef)
local table_merge = assert(foundation.com.table_merge)

local lock_dirs = {
  assert(Directions.D_DOWN),
  assert(Directions.D_NORTH),
  assert(Directions.D_EAST),
  assert(Directions.D_SOUTH),
  assert(Directions.D_WEST),
}

local function mesecon_lock_rules_get(node)
  local result = {}
  local i = 1
  for _,dir in ipairs(lock_dirs) do
    local new_dir = Directions.facedir_to_face(node.param2, dir)
    result[i] = Directions.DIR6_TO_VEC3[new_dir]
    i = i + 1
  end
  return result
end

local function mesecon_lock_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = FakeMetaRef:new(old_meta_table)
  local new_meta = stack:get_meta()
  yatm_security.copy_lockable_object_pubkey(old_meta, new_meta)
  new_meta:set_string(old_meta:get_string("description"))
end

local function mesecon_lock_after_place_node(pos, placer, itemstack, pointed_thing)
  Directions.facedir_wallmount_after_place_node(pos, placer, itemstack, pointed_thing)

  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()

  yatm_security.copy_lockable_object_pubkey(assert(old_meta), new_meta)
  new_meta:set_string(old_meta:get_string("description"))
end

local node_box = {
  type = "fixed",
  fixed = {
    {(3 / 16) - 0.5, -0.5, (3 / 16) - 0.5, (13 / 16) - 0.5, (3 / 16) - 0.5, (13 / 16) - 0.5},
  }
}

for _,row in ipairs(yatm.colors) do
  local color_basename = row.name
  local color_name = row.description

  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    mesecon_needs_receiver = 1,
    lockable_object = 1,
  }

  local description = "Mesecon Lock (" .. color_name .. ")"
  local off_name = "yatm_mesecon_locks:mesecon_lock_" .. color_basename .. "_off"
  local on_name = "yatm_mesecon_locks:mesecon_lock_" .. color_basename .. "_on"

  minetest.register_node(off_name, {
    basename = "yatm_mesecon_locks:mesecon_lock",
    base_description = "Mesecon Lock",

    description = description,

    drop = off_name,

    groups = groups,

    dye_color = color_basename,

    sunlight_propagates = false,
    is_ground_content = false,

    sounds = yatm.node_sounds:build("metal"),

    paramtype = "light",
    paramtype2 = "facedir",

    tiles = {
      "yatm_mesecon_lock_" .. color_basename .. "_top.off.png",
      "yatm_mesecon_lock_" .. color_basename .. "_bottom.off.png",
      "yatm_mesecon_lock_" .. color_basename .. "_side.off.png",
      "yatm_mesecon_lock_" .. color_basename .. "_side.off.png",
      "yatm_mesecon_lock_" .. color_basename .. "_side.off.png",
      "yatm_mesecon_lock_" .. color_basename .. "_side.off.png",
    },
    use_texture_alpha = "opaque",
    drawtype = "nodebox",
    node_box = node_box,

    mesecons = {
      receptor = {
        state = mesecon.state.off,
        rules = mesecon_lock_rules_get,
      }
    },

    on_rotate = mesecon.buttonlike_onrotate,
    on_rightclick = function (pos, node, clicker, item_stack, pointed_thing)
      if yatm_security.is_stack_a_key_for_locked_node(item_stack, pos) then
        minetest.sound_play("mesecons_button_push", {pos=pos})
        minetest.swap_node(pos, { name = on_name, param2 = node.param2 })
        mesecon.receptor_on(pos, mesecon_lock_rules_get(node))
      end
    end,
    on_blast = mesecon.on_blastnode,

    after_place_node = mesecon_lock_after_place_node,

    preserve_metadata = mesecon_lock_preserve_metadata,
  })

  minetest.register_node(on_name, {
    basename = "yatm_mesecon_locks:mesecon_lock",
    base_description = "Mesecon Lock",

    description = description,

    drop = off_name,

    groups = table_merge(groups, {not_in_creative_inventory = 1}),

    dye_color = color_basename,

    sunlight_propagates = false,
    is_ground_content = false,

    sounds = yatm.node_sounds:build("metal"),

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = node_box,
    tiles = {
      "yatm_mesecon_lock_" .. color_basename .. "_top.on.png",
      "yatm_mesecon_lock_" .. color_basename .. "_bottom.on.png",
      "yatm_mesecon_lock_" .. color_basename .. "_side.on.png",
      "yatm_mesecon_lock_" .. color_basename .. "_side.on.png",
      "yatm_mesecon_lock_" .. color_basename .. "_side.on.png",
      "yatm_mesecon_lock_" .. color_basename .. "_side.on.png",
    },
    use_texture_alpha = "opaque",

    mesecons = {
      receptor = {
        state = mesecon.state.on,
        rules = mesecon_lock_rules_get,
      },
    },

    on_rotate = mesecon.buttonlike_onrotate,
    on_rightclick = function (pos, node, clicker, item_stack, pointed_thing)
      if yatm_security.is_stack_a_key_for_locked_node(item_stack, pos) then
        minetest.sound_play("mesecons_button_pop", {pos=pos})
        minetest.swap_node(pos, { name = off_name, param2 = node.param2 })
        mesecon.receptor_off(pos, mesecon_lock_rules_get(node))
      end
    end,
    on_blast = mesecon.on_blastnode,

    after_place_node = mesecon_lock_after_place_node,

    preserve_metadata = mesecon_lock_preserve_metadata,
  })
end
