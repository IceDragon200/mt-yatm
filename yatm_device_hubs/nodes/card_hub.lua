local mod = assert(yatm_device_hubs)
local Cuboid = assert(foundation.com.Cuboid)
local ng = assert(Cuboid.new_fast_node_box)
local Groups = assert(foundation.com.Groups)
local table_merge = assert(foundation.com.table_merge)

local yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_device_hubs:hub_card_error",
    conflict = "yatm_device_hubs:hub_card_error",
    off = "yatm_device_hubs:hub_card_off",
    on = "yatm_device_hubs:hub_card_on",
  },
  energy = {
    capacity = 200,
    passive_lost = 0,
    network_charge_bandwidth = 10,
    startup_threshold = 1,
  }
}

local loaded_yatm_network =
  table_merge(
    yatm_network,
    {
      states = {
        error = "yatm_device_hubs:hub_card_loaded_error",
        conflict = "yatm_device_hubs:hub_card_loaded_error",
        off = "yatm_device_hubs:hub_card_loaded_off",
        on = "yatm_device_hubs:hub_card_loaded_on",
      },
    }
  )

local function maybe_initialize_inventory(meta)
  local inv = meta:get_inventory()

  inv:set_size("access_card_slot", 1)
end

local function on_construct(pos)
  devices.device_on_construct(pos)

  local meta = minetest.get_meta(pos)

  maybe_initialize_inventory(meta)
end

local function on_rightclick(pos, node, user, itemstack, pointed_thing)
  local meta = minetest.get_meta(pos)

  maybe_initialize_inventory(meta)

  yatm.security.on_rightclick_access_card(pos, node, user, itemstack, pointed_thing)
end

local function on_access_card_inserted(pos, node, access_card)
  local nodedef = minetest.registered_nodes[node.name]
  local new_name = loaded_yatm_network.states[nodedef.yatm_network.state]
  minetest.swap_node(pos, table_merge(node, { name = new_name }))
end

local function on_access_card_removed(pos, node, access_card)
  local nodedef = minetest.registered_nodes[node.name]
  local new_name = yatm_network.states[nodedef.yatm_network.state]
  minetest.swap_node(pos, table_merge(node, { name = new_name }))
end

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_device_hubs:hub_card",

  basename = "yatm_device_hubs:hub_card",

  description = mod.S("Hub (Card)"),

  groups = {cracky = 1},

  drop = yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_card_hub_top.png",
    "yatm_card_hub_bottom.png",
    "yatm_card_hub_side.png",
    "yatm_card_hub_side.png^[transformFX",
    "yatm_card_hub_back.png",
    "yatm_card_hub_front.png",
  },
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(2, 0, 2, 12, 4, 12), -- base
      ng(3, 4, 2,  2, 3, 2), -- antennae
    }
  },

  paramtype = "light",
  paramtype2 = "facedir",

  after_place_node = yatm_device_hubs.hub_after_place_node,

  yatm_network = yatm_network,

  refresh_infotext = yatm_device_hubs.hub_refresh_infotext,

  on_construct = on_construct,

  on_rightclick = on_rightclick,

  on_access_card_inserted = on_access_card_inserted,
  on_access_card_removed = on_access_card_removed,
}, {
  error = {
    tiles = {
      "yatm_card_hub_top.png",
      "yatm_card_hub_bottom.png",
      "yatm_card_hub_side.png",
      "yatm_card_hub_side.png^[transformFX",
      "yatm_card_hub_back.png",
      "yatm_card_hub_front.png",
    },
  },
  on = {
    tiles = {
      "yatm_card_hub_top.png",
      "yatm_card_hub_bottom.png",
      "yatm_card_hub_side.png",
      "yatm_card_hub_side.png^[transformFX",
      "yatm_card_hub_back.png",
      "yatm_card_hub_front.png",
    },
  },
})

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_device_hubs:hub_card_loaded",

  basename = "yatm_device_hubs:hub_card_loaded",

  description = mod.S("Hub (Card) [Loaded]"),

  groups = {
    cracky = 1,
    not_in_creative_inventory = 1,
  },

  drop = "yatm_device_hubs:hub_card_off",

  use_texture_alpha = "clip",
  tiles = {
    "yatm_card_hub_top.card.png",
    "yatm_card_hub_bottom.card.png",
    "yatm_card_hub_side.card.png",
    "yatm_card_hub_side.card.png^[transformFX",
    "yatm_card_hub_back.png",
    "yatm_card_hub_front.card.png",
  },
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(2, 0, 2, 12, 4, 12), -- base
      ng(3, 4, 2,  2, 3, 2), -- antennae
      ng(4, 2, 1, 8, 1, 1), -- card
    }
  },

  paramtype = "light",
  paramtype2 = "facedir",

  after_place_node = yatm_device_hubs.hub_after_place_node,

  yatm_network = loaded_yatm_network,

  refresh_infotext = yatm_device_hubs.hub_refresh_infotext,

  on_construct = on_construct,

  on_rightclick = on_rightclick,

  on_access_card_inserted = on_access_card_inserted,
  on_access_card_removed = on_access_card_removed,
}, {
  error = {
    tiles = {
      "yatm_card_hub_top.card.png",
      "yatm_card_hub_bottom.card.png",
      "yatm_card_hub_side.card.png",
      "yatm_card_hub_side.card.png^[transformFX",
      "yatm_card_hub_back.png",
      "yatm_card_hub_front.card.png",
    },
  },
  on = {
    tiles = {
      "yatm_card_hub_top.card.png",
      "yatm_card_hub_bottom.card.png",
      "yatm_card_hub_side.card.png",
      "yatm_card_hub_side.card.png^[transformFX",
      "yatm_card_hub_side.png",
      "yatm_card_hub_front.card.png",
    },
  },
})
