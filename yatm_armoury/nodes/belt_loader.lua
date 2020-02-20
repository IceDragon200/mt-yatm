--
-- Belt Loader
--
-- Handles automatically arming a belt magazine with given cartridges.
if not yatm_machines then
  return
end

local ItemInterface = assert(yatm.items.ItemInterface)

local belt_loader_item_interface =
  ItemInterface.new_directional(function (self, pos, dir)
    local node = minetest.get_node(pos)
    local new_dir = yatm_core.facedir_to_face(node.param2, dir)

    if new_dir == yatm_core.D_EAST and new_dir == yatm_core.D_WEST then
      return "belt_items"
    else
      return "ammo_items"
    end
  end)

local belt_loader_yatm_network = {
  basename = "yatm_armoury:belt_loader",
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_armoury:belt_loader_error",
    conflict = "yatm_armoury:belt_loader_error",
    off = "yatm_armoury:belt_loader_off",
    on = "yatm_armoury:belt_loader_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 100,
    passive_lost = 10,
    startup_threshold = 500,
  },
}

function belt_loader_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  return 0
end

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_armoury:belt_loader",

  basename = "yatm_armoury:belt_loader",

  description =  "Ammo Belt Loader",

  groups = {
    cracky = 1,
    item_interface_in = 1,
    item_interface_out = 1,
  },

  tiles = {
    "yatm_belt_loader_top.off.png",
    "yatm_belt_loader_bottom.png",
    "yatm_belt_loader_side.png",
    "yatm_belt_loader_side.png^[transformFX",
    "yatm_belt_loader_back.png",
    "yatm_belt_loader_front.off.png",
  },

  yatm_network = belt_loader_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_belt_loader_top.error.png",
      "yatm_belt_loader_bottom.png",
      "yatm_belt_loader_side.png",
      "yatm_belt_loader_side.png^[transformFX",
      "yatm_belt_loader_back.png",
      "yatm_belt_loader_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_belt_loader_top.on.png",
      "yatm_belt_loader_bottom.png",
      "yatm_belt_loader_side.png",
      "yatm_belt_loader_side.png^[transformFX",
      "yatm_belt_loader_back.png",
      "yatm_belt_loader_front.on.png",
    },
  }
})
