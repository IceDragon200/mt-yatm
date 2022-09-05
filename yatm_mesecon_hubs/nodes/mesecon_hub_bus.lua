local Directions = assert(foundation.com.Directions)

local mesecon_hub_node_box = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.375, 0.375, -0.3125, 0.375}, -- NodeBox1
    {-0.25, -0.5, -0.5, 0.25, -0.375, 0.5}, -- NodeBox2
    {-0.5, -0.5, -0.25, 0.5, -0.375, 0.25}, -- NodeBox3
  }
}

local function hub_after_place_node(pos, placer, item_stack, pointed_thing)
  Directions.facedir_wallmount_after_place_node(pos, placer, item_stack, pointed_thing)
end

minetest.register_node("yatm_mesecon_hubs:mesecon_hub_bus_off", {
  basename = "yatm_mesecon_hubs:mesecon_hub_bus",

  description = "Mesecon Bus Hub",
  groups = {
    cracky = nokore.dig_class("copper"),
  },
  drop = "yatm_mesecon_hubs:mesecon_hub_bus_off",

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_mesecon_hub_top.bus.off.png",
    "yatm_mesecon_hub_bottom.png",
    "yatm_mesecon_hub_side.off.png",
    "yatm_mesecon_hub_side.off.png",
    "yatm_mesecon_hub_side.off.png",
    "yatm_mesecon_hub_side.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = mesecon_hub_node_box,

  after_place_node = hub_after_place_node,

  mesecons = {
    effector = {
      rules = mesecon.rules.default,

      action_on = function (pos, node)
        node.name = "yatm_mesecon_hubs:mesecon_hub_bus_on"
        minetest.swap_node(pos, node)
      end
    }
  }
})

minetest.register_node("yatm_mesecon_hubs:mesecon_hub_bus_on", {
  basename = "yatm_mesecon_hubs:mesecon_hub_bus",

  description = "Mesecon Bus Hub",
  groups = {
    cracky = nokore.dig_class("copper"),
    not_in_creative_inventory = 1
  },
  drop = "yatm_mesecon_hubs:mesecon_hub_bus_off",

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_mesecon_hub_top.bus.on.png",
    "yatm_mesecon_hub_bottom.png",
    "yatm_mesecon_hub_side.on.png",
    "yatm_mesecon_hub_side.on.png",
    "yatm_mesecon_hub_side.on.png",
    "yatm_mesecon_hub_side.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = mesecon_hub_node_box,
  after_place_node = hub_after_place_node,

  mesecons = {
    effector = {
      rules = mesecon.rules.default,

      action_off = function (pos, node)
        node.name = "yatm_mesecon_hubs:mesecon_hub_bus_off"
        minetest.swap_node(pos, node)
      end
    }
  }
})
