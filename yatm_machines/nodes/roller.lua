local Energy = assert(yatm.energy)
local ItemInterface = assert(yatm.items.ItemInterface)

local roller_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:roller_error",
    error = "yatm_machines:roller_error",
    off = "yatm_machines:roller_off",
    on = "yatm_machines:roller_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 200,
    passive_lost = 0,
    startup_threshold = 100,
  }
}

function roller_yatm_network.work(pos, node, energy_available, work_rate, ot)

end

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_UP or new_dir == yatm_core.D_DOWN then
    return "roller_output"
  end
  return "roller_input"
end)

yatm.devices.register_stateful_network_device({
  description = "Roller",
  groups = {cracky = 1, item_interface_in = 1, item_interface_out = 1},
  drop = roller_yatm_network.states.off,

  sounds = default.node_sound_metal_defaults(),

  tiles = {
    "yatm_roller_top.off.png",
    "yatm_roller_bottom.png",
    "yatm_roller_side.off.png",
    "yatm_roller_side.off.png^[transformFX",
    "yatm_roller_back.off.png",
    "yatm_roller_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = function (pos)
    yatm.devices.default_on_construct
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("roller_input", 1)
    inv:set_size("roller_output", 1)
  end,

  can_dig = function (pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    return inv:is_empty("roller_input") and inv:is_empty("roller_output")
  end,

  yatm_network = roller_yatm_network,

  item_interface = item_interface,
}, {
  error = {
    tiles = {
      "yatm_roller_top.error.png",
      "yatm_roller_bottom.png",
      "yatm_roller_side.error.png",
      "yatm_roller_side.error.png^[transformFX",
      "yatm_roller_back.error.png",
      "yatm_roller_front.error.png"
    },
  },
  on = {

    tiles = {
      "yatm_roller_top.on.png",
      "yatm_roller_bottom.png",
      "yatm_roller_side.on.png",
      "yatm_roller_side.on.png^[transformFX",
      "yatm_roller_back.on.png",
      {
        name = "yatm_roller_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.25
        },
      },
    },
  }
})
