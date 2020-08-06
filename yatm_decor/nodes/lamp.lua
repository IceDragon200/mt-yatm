local Directions = assert(foundation.com.Directions)
local lamp_node_box = {
  type = "fixed",
  fixed = {
    {-0.4375, -0.3125, -0.4375, 0.4375, 0.4375, 0.4375}, -- Lamp
    {-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5}, -- Base
  }
}

local flat_lamp_node_box = {
  type = "fixed",
  fixed = {
    {-0.4375, -0.3125, -0.4375, 0.4375, -0.25, 0.4375}, -- Lamp
    {-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5}, -- Base
  }
}

local small_lamp_node_box = {
  type = "fixed",
  fixed = {
    {-0.1875, -0.375, -0.1875, 0.1875, -0.125, 0.1875}, -- Lamp
    {-0.25, -0.5, -0.25, 0.25, -0.3875, 0.25}, -- Base
  }
}

local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
else
  print("yatm_decor", "dye is not available, lamps will only be available in white")
end

-- Fixes the orientation of the lamp after it was placed
-- aka. don't mess around with the cray-cray place_node code
local lamp_after_place_node = function (pos, placer, itemstack, pointed_thing)
  -- FIXME: If the digtron places the node, YATM will override the param2
  --        This causes the lamp to be placed in the wrong direction.
  --print(pos, placer.get_player_name())
  Directions.facedir_wallmount_after_place_node(pos, placer, itemstack, pointed_thing)
end

local lamp_rules = {}
if mesecon then
  lamp_rules = assert(mesecon.rules.default)
else
  print("yatm_decor", "mesecons is unavailable, lamps cannot be toggled")
end

local lamp_mesecons = {
  effector = {
    rules = lamp_rules,

    -- Boring lamp stuff
    action_on = function (pos, node)
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef and nodedef.yatm then
        local new_state = "on"
        if nodedef.yatm.normal_state == "off" then
          new_state = "on"
        else
          new_state = "off"
        end
        node.name = nodedef.yatm.lamp_basename .. "_" .. new_state
        minetest.swap_node(pos, node)
      end
    end,

    action_off = function (pos, node)
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef and nodedef.yatm then
        local new_state = "off"
        if nodedef.yatm.normal_state == "off" then
          new_state = "off"
        else
          new_state = "on"
        end
        node.name = nodedef.yatm.lamp_basename .. "_" .. new_state
        minetest.swap_node(pos, node)
      end
    end,
  }
}

local lamp_sounds = yatm.node_sounds:build("glass")

local states = {
  "on",
  "off",
}

for _,default_state in ipairs(states) do
  for _,pair in ipairs(colors) do
    local basename = pair[1]
    local name = pair[2]
    local basename_postfix = "_d" .. default_state


    local postfix = "(default: " .. default_state .. ")"

    local lamp_groups_on = { dig_immediate = 3 }
    local lamp_groups_off = { dig_immediate = 3 }
    if default_state == "on" then
      lamp_groups_off.not_in_creative_inventory = 1
    else
      lamp_groups_on.not_in_creative_inventory = 1
    end

    -- Regular large lamps
    local lamp_basename = "yatm_decor:lamp_" .. basename .. basename_postfix
    minetest.register_node(lamp_basename .. "_off", {
      basename = "yatm_decor:lamp",
      base_description = "Lamp",

      description = name .. " Lamp [OFF] " .. postfix,
      groups = lamp_groups_off,
      is_ground_content = false,
      sounds = lamp_sounds,
      tiles = {
        "yatm_lamp_large_" .. basename .. "_top.off.png",
        "yatm_lamp_large_" .. basename .. "_bottom.off.png",
        "yatm_lamp_large_" .. basename .. "_side.off.png",
        "yatm_lamp_large_" .. basename .. "_side.off.png",
        "yatm_lamp_large_" .. basename .. "_side.off.png",
        "yatm_lamp_large_" .. basename .. "_side.off.png"
      },
      paramtype = "light",
      paramtype2 = "facedir",
      drawtype = "nodebox",
      node_box = lamp_node_box,
      after_place_node = lamp_after_place_node,
      mesecons = lamp_mesecons,
      yatm = { color = basename, lamp_basename = lamp_basename, normal_state = default_state },
    })

    minetest.register_node(lamp_basename .. "_on", {
      basename = "yatm_decor:lamp",
      base_description = "Lamp",

      description = name .. " Lamp [ON] " .. postfix,
      groups = lamp_groups_on,
      is_ground_content = false,
      sounds = lamp_sounds,
      tiles = {
        "yatm_lamp_large_" .. basename .. "_top.on.png",
        "yatm_lamp_large_" .. basename .. "_bottom.on.png",
        "yatm_lamp_large_" .. basename .. "_side.on.png",
        "yatm_lamp_large_" .. basename .. "_side.on.png",
        "yatm_lamp_large_" .. basename .. "_side.on.png",
        "yatm_lamp_large_" .. basename .. "_side.on.png"
      },
      paramtype = "light",
      paramtype2 = "facedir",
      sunlight_propagates = false,
      light_source = minetest.LIGHT_MAX,
      drawtype = "nodebox",
      node_box = lamp_node_box,
      after_place_node = lamp_after_place_node,
      mesecons = lamp_mesecons,
      yatm = { color = basename, lamp_basename = lamp_basename, normal_state = default_state },
    })

    -- The really flat lamps
    lamp_basename = "yatm_decor:flat_lamp_" .. basename .. basename_postfix
    minetest.register_node(lamp_basename .. "_off", {
      basename = "yatm_decor:flat_lamp",
      base_description = "Flat Lamp",

      description = name .. " Flat Lamp [OFF] " .. postfix,
      groups = lamp_groups_off,
      is_ground_content = false,
      sounds = lamp_sounds,
      tiles = {
        "yatm_lamp_large_" .. basename .. "_top.off.png",
        "yatm_lamp_large_" .. basename .. "_bottom.off.png",
        "yatm_lamp_large_" .. basename .. "_side.off.png",
        "yatm_lamp_large_" .. basename .. "_side.off.png",
        "yatm_lamp_large_" .. basename .. "_side.off.png",
        "yatm_lamp_large_" .. basename .. "_side.off.png"
      },
      paramtype = "light",
      paramtype2 = "facedir",
      drawtype = "nodebox",
      node_box = flat_lamp_node_box,
      after_place_node = lamp_after_place_node,
      mesecons = lamp_mesecons,
      yatm = { color = basename, lamp_basename = lamp_basename, normal_state = default_state },
    })

    minetest.register_node(lamp_basename .. "_on", {
      basename = "yatm_decor:flat_lamp",
      base_description = "Flat Lamp",

      description = name .. " Flat Lamp [ON] " .. postfix,
      groups = lamp_groups_on,
      is_ground_content = false,
      sounds = lamp_sounds,
      tiles = {
        "yatm_lamp_large_" .. basename .. "_top.on.png",
        "yatm_lamp_large_" .. basename .. "_bottom.on.png",
        "yatm_lamp_large_" .. basename .. "_side.on.png",
        "yatm_lamp_large_" .. basename .. "_side.on.png",
        "yatm_lamp_large_" .. basename .. "_side.on.png",
        "yatm_lamp_large_" .. basename .. "_side.on.png"
      },
      paramtype = "light",
      paramtype2 = "facedir",
      sunlight_propagates = false,
      light_source = minetest.LIGHT_MAX,
      drawtype = "nodebox",
      node_box = flat_lamp_node_box,
      after_place_node = lamp_after_place_node,
      mesecons = lamp_mesecons,
      yatm = { color = basename, lamp_basename = lamp_basename, normal_state = default_state },
    })

    --[[
    The really tiny lamp block
    ]]
    lamp_basename = "yatm_decor:small_lamp_" .. basename .. basename_postfix
    minetest.register_node(lamp_basename .. "_off", {
      basename = "yatm_decor:small_lamp",
      base_description = "Small Lamp",

      description = name .. " Small Lamp [OFF] " .. postfix,
      groups = lamp_groups_off,
      is_ground_content = false,
      sounds = lamp_sounds,
      tiles = {
        "yatm_lamp_small_" .. basename .. "_top.off.png",
        "yatm_lamp_small_" .. basename .. "_bottom.off.png",
        "yatm_lamp_small_" .. basename .. "_side.off.png",
        "yatm_lamp_small_" .. basename .. "_side.off.png",
        "yatm_lamp_small_" .. basename .. "_side.off.png",
        "yatm_lamp_small_" .. basename .. "_side.off.png"
      },
      paramtype = "light",
      paramtype2 = "facedir",
      drawtype = "nodebox",
      node_box = small_lamp_node_box,
      after_place_node = lamp_after_place_node,
      mesecons = lamp_mesecons,
      yatm = { color = basename, lamp_basename = lamp_basename, normal_state = default_state },
    })

    minetest.register_node(lamp_basename .. "_on", {
      basename = "yatm_decor:small_lamp",
      base_description = "Small Lamp",

      description = name .. " Small Lamp [ON] " .. postfix,
      groups = lamp_groups_on,
      is_ground_content = false,
      sounds = lamp_sounds,
      tiles = {
        "yatm_lamp_small_" .. basename .. "_top.on.png",
        "yatm_lamp_small_" .. basename .. "_bottom.on.png",
        "yatm_lamp_small_" .. basename .. "_side.on.png",
        "yatm_lamp_small_" .. basename .. "_side.on.png",
        "yatm_lamp_small_" .. basename .. "_side.on.png",
        "yatm_lamp_small_" .. basename .. "_side.on.png"
      },
      paramtype = "light",
      paramtype2 = "facedir",
      sunlight_propagates = false,
      light_source = minetest.LIGHT_MAX,
      drawtype = "nodebox",
      node_box = small_lamp_node_box,
      after_place_node = lamp_after_place_node,
      mesecons = lamp_mesecons,
      yatm = { color = basename, lamp_basename = lamp_basename, normal_state = default_state },
    })
  end
end
