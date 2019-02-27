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
end

-- Fixes the orientation of the lamp after it was placed
-- aka. don't mess around with the cray-cray place_node code
local lamp_after_place_node = yatm_core.facedir_wallmount_after_place_node

local lamp_mesecons = {
  effector = {
    rules = mesecon.rules.default,

    -- Boring lamp stuff
    action_on = function (pos, node)
      local nodedef = minetest.registered_nodes[node.name]
      print("Lamp on", pos, node)
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
      print("Lamp off", pos, node)
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

local lamp_sounds = default.node_sound_glass_defaults()
local lamp_groups = { dig_immediate = 3 }

for _,pair in ipairs(colors) do
  local basename = pair[1]
  local name = pair[2]
  local lamp_basename = "yatm_decor:lamp_" .. basename


  minetest.register_node(lamp_basename .. "_off", {
    description = name .. " Lamp [OFF]",
    groups = lamp_groups,
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
    yatm = { color = basename, lamp_basename = lamp_basename, normal_state = "off" },
  })

  minetest.register_node(lamp_basename .. "_on", {
    description = name .. " Lamp [ON]",
    groups = lamp_groups,
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
    sunlight_propagates = true,
    light_source = default.LIGHT_MAX,
    drawtype = "nodebox",
    node_box = lamp_node_box,
    after_place_node = lamp_after_place_node,
    mesecons = lamp_mesecons,
    yatm = { color = basename, lamp_basename = lamp_basename, normal_state = "off" },
  })

  lamp_basename = "yatm_decor:flat_lamp_" .. basename
  minetest.register_node(lamp_basename .. "_off", {
    description = name .. " Flat Lamp [OFF]",
    groups = lamp_groups,
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
    yatm = { color = basename, lamp_basename = lamp_basename, normal_state = "off" },
  })

  minetest.register_node(lamp_basename .. "_on", {
    description = name .. " Flat Lamp [ON]",
    groups = lamp_groups,
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
    sunlight_propagates = true,
    light_source = default.LIGHT_MAX,
    drawtype = "nodebox",
    node_box = flat_lamp_node_box,
    after_place_node = lamp_after_place_node,
    mesecons = lamp_mesecons,
    yatm = { color = basename, lamp_basename = lamp_basename, normal_state = "off" },
  })

  lamp_basename = "yatm_decor:small_lamp_" .. basename
  minetest.register_node(lamp_basename .. "_off", {
    description = name .. " Small Lamp [OFF]",
    groups = lamp_groups,
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
    yatm = { color = basename, lamp_basename = lamp_basename, normal_state = "off" },
  })

  minetest.register_node(lamp_basename .. "_on", {
    description = name .. " Small Lamp [ON]",
    groups = lamp_groups,
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
    sunlight_propagates = true,
    light_source = default.LIGHT_MAX,
    drawtype = "nodebox",
    node_box = small_lamp_node_box,
    after_place_node = lamp_after_place_node,
    mesecons = lamp_mesecons,
    yatm = { color = basename, lamp_basename = lamp_basename, normal_state = "off" },
  })
end
