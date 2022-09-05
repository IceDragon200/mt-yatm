local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local Directions = assert(foundation.com.Directions)
local table_merge = assert(foundation.com.table_merge)

local button_after_place_node = assert(Directions.facedir_wallmount_after_place_node)

-- Buttons affect everything below and adjacent to them, however, they do not affect what's directly in front of the button!
local button_dirs = {
  Directions.D_DOWN,
  Directions.D_NORTH,
  Directions.D_EAST,
  Directions.D_SOUTH,
  Directions.D_WEST,
}

local function mesecon_button_rules_get(node)
  local result = {}
  local i = 1
  for _,dir in ipairs(button_dirs) do
    local new_dir = Directions.facedir_to_face(node.param2, dir)
    result[i] = Directions.DIR6_TO_VEC3[new_dir]
    i = i + 1
  end
  return result
end

local mesecon_button_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (3 / 16) - 0.5, 0.5}, -- Base
    ng(  3,  3,  3, 10,  1, 10), -- Button
  }
}

for _,row in ipairs(yatm.colors) do
  local color_basename = row.name
  local color_name = row.description

  local groups = {
    cracky = nokore.dig_class("copper"),
    mesecon_needs_receiver = 1,
  }

  -- Push buttons have a temporary state

  -- Toggle buttons hold their state until pressed again
  local description = "Mesecon Toggle Button (" .. color_name .. ")"
  local off_name = "yatm_mesecon_buttons:mesecon_toggle_button_" .. color_basename .. "_off"
  local on_name = "yatm_mesecon_buttons:mesecon_toggle_button_" .. color_basename .. "_on"

  minetest.register_node(off_name, {
    basename = "yatm_mesecon_buttons:mesecon_toggle_button",

    base_description = "Mesecon Toggle Button",

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
      "yatm_mesecon_button_" .. color_basename .. "_top.off.png",
      "yatm_mesecon_button_" .. color_basename .. "_bottom.off.png",
      "yatm_mesecon_button_" .. color_basename .. "_side.off.png",
      "yatm_mesecon_button_" .. color_basename .. "_side.off.png",
      "yatm_mesecon_button_" .. color_basename .. "_side.off.png",
      "yatm_mesecon_button_" .. color_basename .. "_side.off.png",
    },
    use_texture_alpha = "opaque",

    drawtype = "nodebox",
    node_box = mesecon_button_nodebox,

    mesecons = {
      receptor = {
        state = mesecon.state.off,
        rules = mesecon_button_rules_get,
      }
    },

    on_rotate = mesecon.buttonlike_onrotate,
    on_rightclick = function (pos, node)
      minetest.sound_play("mesecons_button_push", {pos=pos})
      minetest.swap_node(pos, { name = on_name, param2 = node.param2 })
      mesecon.receptor_on(pos, mesecon_button_rules_get(node))
    end,
    on_blast = mesecon.on_blastnode,

    after_place_node = button_after_place_node,
  })

  minetest.register_node(on_name, {
    basename = "yatm_mesecon_buttons:mesecon_toggle_button",

    base_description = "Mesecon Toggle Button",

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
    node_box = {
      type = "fixed",
      fixed = {
        {-0.5, -0.5, -0.5, 0.5, (3 / 16) - 0.5, 0.5}, -- Base
      }
    },
    tiles = {
      "yatm_mesecon_button_" .. color_basename .. "_top.on.png",
      "yatm_mesecon_button_" .. color_basename .. "_bottom.on.png",
      "yatm_mesecon_button_" .. color_basename .. "_side.on.png",
      "yatm_mesecon_button_" .. color_basename .. "_side.on.png",
      "yatm_mesecon_button_" .. color_basename .. "_side.on.png",
      "yatm_mesecon_button_" .. color_basename .. "_side.on.png",
    },
    use_texture_alpha = "opaque",

    mesecons = {
      receptor = {
        state = mesecon.state.on,
        rules = mesecon_button_rules_get,
      },
    },

    on_rotate = mesecon.buttonlike_onrotate,
    on_rightclick = function (pos, node)
      minetest.sound_play("mesecons_button_pop", {pos=pos})
      minetest.swap_node(pos, { name = off_name, param2 = node.param2 })
      mesecon.receptor_off(pos, mesecon_button_rules_get(node))
    end,
    on_blast = mesecon.on_blastnode,

    after_place_node = button_after_place_node,
  })
end
