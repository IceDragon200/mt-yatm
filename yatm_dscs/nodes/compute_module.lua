--[[

  Compute Modules are no-op blocks that act as a bonus modifier to assemblers on the network.

  Each compute module will speed up the auto-crafting by parallel processing other requests.

]]
local compute_module_yatm_network = {
  kind = "machine",
  groups = {
    energy_consumer = 1,
    dscs_compute_module = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:compute_module_error",
    error = "yatm_dscs:compute_module_error",
    off = "yatm_dscs:compute_module_off",
    on = "yatm_dscs:compute_module_on",
  },
  energy = {
    passive_lost = 10,
  },
}

local groups = {
  cracky = 1,
  yatm_network_device = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Assembler Compute Module",

  groups = groups,

  drop = compute_module_yatm_network.states.off,

  tiles = {"yatm_compute_module_side.off.png"},

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = compute_module_yatm_network,
}, {
  on = {
    tiles = {{
      name = "yatm_compute_module_side.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    }},
  },
  error = {
    tiles = {"yatm_compute_module_side.error.png"},
  }
})
