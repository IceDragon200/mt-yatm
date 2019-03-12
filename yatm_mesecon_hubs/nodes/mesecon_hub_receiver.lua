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

minetest.register_node("yatm_mesecon_hubs:mesecon_hub_receiver_off", {
  description = "Mesecon Receiver Hub",
  groups = {cracky = 1},
  drop = "yatm_mesecon_hubs:mesecon_hub_receiver_off",
  tiles = {
    "yatm_mesecon_hub_top.receiver.off.png",
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
    receptor = {
      rules = mesecon.rules.default,
      state = "off",
    }
  },

  mesecons_wireless_device = {
    action_pdu = function (pos, node, value)

    end,
  }
})

minetest.register_node("yatm_mesecon_hubs:mesecon_hub_receiver_on", {
  description = "Mesecon Receiver Hub",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = "yatm_mesecon_hubs:mesecon_hub_receiver_off",
  tiles = {
    {
      name = "yatm_mesecon_hub_top.receiver.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
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
    receptor = {
      rules = mesecon.rules.default,
      state = "on",
    }
  },

  mesecons_wireless_device = {
    action_pdu = function (pos, node, value)

    end,
  }
})
