local NetworkMeta = assert(yatm.mesecon_hubs.NetworkMeta)
local is_blank = assert(foundation.com.is_blank)
local Directions = assert(foundation.com.Directions)

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
  Directions.facedir_wallmount_after_place_node(pos, placer, item_stack, pointed_thing)
  local meta = minetest.get_meta(pos)
  NetworkMeta.patch_hub_address(meta)
  hub_refresh_infotext(pos)
end

local function hub_change_hub_address(pos, changer, new_address)
  local meta = minetest.get_meta(pos)
  NetworkMeta.set_hub_address(meta, new_address)
  hub_refresh_infotext(pos)
  return new_address
end

local function hub_emit_change_event(pos, value)
  local meta = minetest.get_meta(pos)
  local addr = NetworkMeta.get_hub_address(meta)
  if is_blank(addr) then
    -- No hub address, skip emission
    print("WARN: hub does not have an address cannot emit")
  else
    yatm_mesecon_hubs.wireless_network:emit_value(pos, addr, value)
  end
end

minetest.register_node("yatm_mesecon_hubs:mesecon_hub_emitter_off", {
  basename = "yatm_mesecon_hubs:mesecon_hub_emitter",

  description = "Mesecon Emitter Hub",
  groups = {cracky = 1, addressable_hub_device = 1},
  drop = "yatm_mesecon_hubs:mesecon_hub_emitter_off",
  tiles = {
    "yatm_mesecon_hub_top.emitter.off.png",
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
  on_blast = mesecon.on_blastnode,

  mesecons = {
    effector = {
      rules = mesecon.rules.default,

      action_on = function (pos, node)
        node.name = "yatm_mesecon_hubs:mesecon_hub_emitter_on"
        minetest.swap_node(pos, node)

        hub_emit_change_event(pos, 1)
      end
    }
  },
})

minetest.register_node("yatm_mesecon_hubs:mesecon_hub_emitter_on", {
  basename = "yatm_mesecon_hubs:mesecon_hub_emitter",

  description = "Mesecon Emitter Hub",
  groups = {cracky = 1, addressable_hub_device = 1, not_in_creative_inventory = 1},
  drop = "yatm_mesecon_hubs:mesecon_hub_emitter_off",
  tiles = {
    {
      name = "yatm_mesecon_hub_top.emitter.on.png",
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
  on_blast = mesecon.on_blastnode,

  mesecons = {
    effector = {
      rules = mesecon.rules.default,

      action_off = function (pos, node)
        node.name = "yatm_mesecon_hubs:mesecon_hub_emitter_off"
        minetest.swap_node(pos, node)

        hub_emit_change_event(pos, 0)
      end
    }
  }
})
