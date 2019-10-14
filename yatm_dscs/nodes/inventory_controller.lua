--
-- Inventory Controller
--
-- Inventory controllers are required in a yatm network to store recipes
-- And management automatic crafting, the node in question will remember
-- all active requests.
local inventory_controller_yatm_network = {
  kind = "machine",
  groups = {
    energy_consumer = 1,
    dscs_inventory_controller = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:inventory_controller_error",
    error = "yatm_dscs:inventory_controller_error",
    off = "yatm_dscs:inventory_controller_off",
    on = "yatm_dscs:inventory_controller_on",
  },
  energy = {
    passive_lost = 10,
  },
}

local groups = {
  cracky = 1,
  yatm_network_device = 1,
  yatm_energy_device = 1,
  yatm_inventory_controller = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Inventory Controller",

  groups = groups,

  drop = inventory_controller_yatm_network.states.off,

  tiles = {"yatm_inventory_controller_side.off.png"},

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = inventory_controller_yatm_network,
}, {
  error = {
    tiles = {"yatm_inventory_controller_side.error.png"},
  },
  idle = {
    tiles = {"yatm_inventory_controller_side.idle.png"},
  },
  on = {
    tiles = {
      {
        name = "yatm_inventory_controller_side.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
    },
  },
})
