--
-- The maganize loader has an internal magazine template containing
-- the order in which rounds should be loaded into a specified magazine
--
if not yatm_machines then
  return
end

local Directions = assert(foundation.com.Directions)
local ItemInterface = assert(yatm.items.ItemInterface)

local magazine_loader_item_interface =
  ItemInterface.new_directional(function (self, pos, dir)
    local node = minetest.get_node(pos)
    local new_dir = Directions.facedir_to_face(node.param2, dir)

    if new_dir == Directions.D_EAST and new_dir == Directions.D_WEST then
      return "magazine_items"
    else
      return "ammo_items"
    end
  end)

local magazine_loader_yatm_network = {
  basename = "yatm_armoury:magazine_loader",
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_armoury:magazine_loader_error",
    conflict = "yatm_armoury:magazine_loader_error",
    off = "yatm_armoury:magazine_loader_off",
    on = "yatm_armoury:magazine_loader_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 100,
    passive_lost = 10,
    startup_threshold = 500,
  },
}

function magazine_loader_yatm_network:work(ctx)
  return 0
end

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_armoury:magazine_loader",

  basename = "yatm_armoury:magazine_loader",

  description = "Magazine Loader",

  groups = {
    cracky = 1,
    item_interface_in = 1,
    item_interface_out = 1,
  },

  tiles = {
    "yatm_magazine_loader_top.off.png",
    "yatm_magazine_loader_bottom.png",
    "yatm_magazine_loader_side.png",
    "yatm_magazine_loader_side.png^[transformFX",
    "yatm_magazine_loader_back.png",
    "yatm_magazine_loader_front.off.png",
  },

  yatm_network = magazine_loader_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_magazine_loader_top.error.png",
      "yatm_magazine_loader_bottom.png",
      "yatm_magazine_loader_side.png",
      "yatm_magazine_loader_side.png^[transformFX",
      "yatm_magazine_loader_back.png",
      "yatm_magazine_loader_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_magazine_loader_top.on.png",
      "yatm_magazine_loader_bottom.png",
      "yatm_magazine_loader_side.png",
      "yatm_magazine_loader_side.png^[transformFX",
      "yatm_magazine_loader_back.png",
      "yatm_magazine_loader_front.on.png",
    },
  }
})
