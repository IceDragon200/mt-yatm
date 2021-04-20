--
-- The chemical injector is a single purpose machine which places a fluid into
-- an item, such as chemical warheads or grenades.
--
if not yatm_machines then
  return
end

local Directions = assert(foundation.com.Directions)
local ItemInterface = assert(yatm.items.ItemInterface)

local chemical_injector_item_interface =
  ItemInterface.new_directional(function (self, pos, dir)
    local node = minetest.get_node(pos)
    local new_dir = Directions.facedir_to_face(node.param2, dir)

    return "ammo_items"
  end)

local chemical_injector_yatm_network = {
  basename = "yatm_armoury:chemical_injector",
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_armoury:chemical_injector_error",
    conflict = "yatm_armoury:chemical_injector_error",
    off = "yatm_armoury:chemical_injector_off",
    on = "yatm_armoury:chemical_injector_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 100,
    passive_lost = 10,
    startup_threshold = 500,
  },
}

function chemical_injector_yatm_network.work()
  -- TODO
end

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_armoury:chemical_injector",

  basename = "yatm_armoury:chemical_injector",

  description = "Chemical Injector",

  groups = {
    cracky = 1,
    item_interface_in = 1,
    item_interface_out = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
  },

  tiles = {
    "yatm_chemical_injector_top.off.png",
    "yatm_chemical_injector_bottom.png",
    "yatm_chemical_injector_side.png",
    "yatm_chemical_injector_side.png^[transformFX",
    "yatm_chemical_injector_back.png",
    "yatm_chemical_injector_front.off.png",
  },

  yatm_network = chemical_injector_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_chemical_injector_top.error.png",
      "yatm_chemical_injector_bottom.png",
      "yatm_chemical_injector_side.png",
      "yatm_chemical_injector_side.png^[transformFX",
      "yatm_chemical_injector_back.png",
      "yatm_chemical_injector_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_chemical_injector_top.on.png",
      "yatm_chemical_injector_bottom.png",
      "yatm_chemical_injector_side.png",
      "yatm_chemical_injector_side.png^[transformFX",
      "yatm_chemical_injector_back.png",
      "yatm_chemical_injector_front.on.png",
    },
  }
})
