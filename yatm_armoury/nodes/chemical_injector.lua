--
-- The chemical injector is a single purpose machine which places a fluid into
-- an item, such as chemical warheads or grenades.
--
if not yatm_machines then
  return
end

local Directions = assert(foundation.com.Directions)
local ItemInterface = assert(yatm.items.ItemInterface)
local FluidInterface = assert(yatm.fluids.FluidInterface)

local fluid_interface =
  FluidInterface.new_simple("tank", 4000)

local item_interface =
  ItemInterface.new_directional(function (self, pos, dir)
    local node = minetest.get_node(pos)
    local new_dir = Directions.facedir_to_face(node.param2, dir)

    return "ammo_items"
  end)

local yatm_network = {
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

function yatm_network.work()
  return 0
end

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_armoury:chemical_injector",

  basename = "yatm_armoury:chemical_injector",

  base_description = "Chemical Injector",
  description = "Chemical Injector",

  sounds = yatm.node_sounds:build("metal"),

  groups = {
    cracky = 1,
    yatm_energy_device = 1,
    item_interface_in = 1,
    item_interface_out = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
  },

  tiles = {
    "yatm_chemical_injector_top.off.empty.png",
    "yatm_chemical_injector_bottom.off.png",
    "yatm_chemical_injector_side.off.png",
    "yatm_chemical_injector_side.off.png^[transformFX",
    "yatm_chemical_injector_back.off.png",
    "yatm_chemical_injector_front.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = yatm_network,
  item_interface = item_interface,
  fluid_interface = fluid_interface,
}, {
  error = {
    tiles = {
      "yatm_chemical_injector_top.off.empty.png",
      "yatm_chemical_injector_bottom.error.png",
      "yatm_chemical_injector_side.error.png",
      "yatm_chemical_injector_side.error.png^[transformFX",
      "yatm_chemical_injector_back.error.png",
      "yatm_chemical_injector_front.error.png",
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_chemical_injector_top.on.chemical.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1,
        },
      },
      "yatm_chemical_injector_bottom.on.png",
      "yatm_chemical_injector_side.on.png",
      "yatm_chemical_injector_side.on.png^[transformFX",
      "yatm_chemical_injector_back.on.png",
      "yatm_chemical_injector_front.on.png",
    },
  }
})
