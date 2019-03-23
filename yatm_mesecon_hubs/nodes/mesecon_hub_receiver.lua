local Network = assert(yatm.mesecon_hubs.Network)
local NetworkMeta = assert(yatm.mesecon_hubs.NetworkMeta)

local mesecon_hub_node_box = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.375, 0.375, -0.3125, 0.375}, -- NodeBox1
    {-0.25, -0.5, -0.5, 0.25, -0.375, 0.5}, -- NodeBox2
    {-0.5, -0.5, -0.25, 0.5, -0.375, 0.25}, -- NodeBox3
  }
}

local function hub_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local addr = NetworkMeta.get_hub_address(meta)
  meta:set_string("infotext", "Hub-Address:<" .. addr .. ">")
end

local function hub_after_place_node(pos, placer, item_stack, pointed_thing)
  yatm_core.facedir_wallmount_after_place_node(pos, placer, item_stack, pointed_thing)
  local meta = minetest.get_meta(pos)
  NetworkMeta.patch_hub_address(meta)
  hub_refresh_infotext(pos)
  Network.register_listener(pos, NetworkMeta.get_hub_address(meta))
end

local function hub_on_destruct(pos)
  Network.unregister_listener(pos)
end

local function hub_change_hub_address(pos, changer, new_address)
  local meta = minetest.get_meta(pos)
  Network.unregister_listener(pos)
  do
    NetworkMeta.set_hub_address(meta, new_address)
    hub_refresh_infotext(pos)
  end
  Network.register_listener(pos, NetworkMeta.get_hub_address(meta))
  return new_address
end

local function hub_action_pdu(pos, node, pdu)
  assert(pdu, "expected a pdu")
  local new_node_name = node.name
  local b = false
  if pdu.value ~= 0 then
    b = true
    new_node_name = "yatm_mesecon_hubs:mesecon_hub_receiver_on"
  else
    b = false
    new_node_name = "yatm_mesecon_hubs:mesecon_hub_receiver_off"
  end
  print(minetest.pos_to_string(pos), node.name, ">", new_node_name, pdu, b)
  if new_node_name ~= node.name then
    node.name = new_node_name
    minetest.swap_node(pos, node)
    local nodedef = minetest.registered_nodes[node.name]
    if b then
      mesecon.receptor_on(pos, nodedef.mesecons.receptor.rules)
    else
      mesecon.receptor_off(pos, nodedef.mesecons.receptor.rules)
    end
    -- TODO: notify state changed
  end
end

minetest.register_node("yatm_mesecon_hubs:mesecon_hub_receiver_off", {
  description = "Mesecon Receiver Hub",
  groups = {
    cracky = 1,
    addressable_hub_device = 1,
    listening_hub_device = 1
  },
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

  change_hub_address = hub_change_hub_address,
  after_place_node = hub_after_place_node,
  on_destruct = hub_on_destruct,
  on_blast = mesecon.on_blastnode,

  mesecons = {
    receptor = {
      rules = mesecon.rules.default,
      state = "off",
    }
  },

  mesecons_wireless_device = {
    action_pdu = hub_action_pdu,
  }
})

minetest.register_node("yatm_mesecon_hubs:mesecon_hub_receiver_on", {
  description = "Mesecon Receiver Hub",
  groups = {
    cracky = 1,
    addressable_hub_device = 1,
    listening_hub_device = 1,
    not_in_creative_inventory = 1,
  },
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

  change_hub_address = hub_change_hub_address,
  after_place_node = hub_after_place_node,
  on_destruct = hub_on_destruct,
  on_blast = mesecon.on_blastnode,

  mesecons = {
    receptor = {
      rules = mesecon.rules.default,
      state = "on",
    }
  },

  mesecons_wireless_device = {
    action_pdu = hub_action_pdu,
  }
})
