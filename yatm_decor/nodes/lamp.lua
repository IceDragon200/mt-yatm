local lamp_node_box = {
  type = "fixed",
  fixed = {
    {-0.4375, -0.3125, -0.4375, 0.4375, 0.4375, 0.4375}, -- Lamp
    {-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5}, -- Base
  }
}

local colors = {
  {"white", "White"}
}

if dye then
  colors = dye.dyes
end

-- Fixes the orientation of the lamp after it was placed
-- aka. don't mess around with the cray-cray place_node code
local lamp_after_place_node = yatm_core.facedir_wallmount_after_place_node

for _,pair in ipairs(colors) do
  local basename = pair[1]
  local name = pair[2]
  minetest.register_node("yatm_decor:lamp_" .. basename .. "_off", {
    description = name .. " Lamp [OFF]",
    groups = {cracky = 1},
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
  })

  minetest.register_node("yatm_decor:lamp_" .. basename .. "_on", {
    description = name .. " Lamp [ON]",
    groups = {cracky = 1},
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
  })

  local flat_lamp_node_box = {
    type = "fixed",
    fixed = {
      {-0.4375, -0.3125, -0.4375, 0.4375, -0.25, 0.4375}, -- Lamp
      {-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5}, -- Base
    }
  }

  minetest.register_node("yatm_decor:flat_lamp_" .. basename .. "_off", {
    description = name .. " Flat Lamp [OFF]",
    groups = {cracky = 1},
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
  })

  minetest.register_node("yatm_decor:flat_lamp_" .. basename .. "_on", {
    description = name .. " Flat Lamp [ON]",
    groups = {cracky = 1},
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
  })

  local small_lamp_node_box = {
    type = "fixed",
    fixed = {
      {-0.1875, -0.375, -0.1875, 0.1875, -0.125, 0.1875}, -- Lamp
      {-0.25, -0.5, -0.25, 0.25, -0.3875, 0.25}, -- Base
    }
  }

  minetest.register_node("yatm_decor:small_lamp_" .. basename .. "_off", {
    description = name .. " Small Lamp [OFF]",
    groups = {cracky = 1},
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
  })

  minetest.register_node("yatm_decor:small_lamp_" .. basename .. "_on", {
    description = name .. " Small Lamp [ON]",
    groups = {cracky = 1},
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
  })
end
