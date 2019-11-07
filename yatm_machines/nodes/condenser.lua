--[[

  Condensers turn gases into liquids, primarily steam back into water.

]]
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local condenser_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:condenser_error",
    error = "yatm_machines:condenser_error",
    off = "yatm_machines:condenser_off",
    on = "yatm_machines:condenser_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 200,
    passive_lost = 50,
    startup_threshold = 400,
  }
}

local function condenser_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local capacity = 16000

local function get_fluid_tank_name(_self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_DOWN then
    return "water_tank", capacity
  elseif new_dir == yatm_core.D_UP or
         new_dir == yatm_core.D_EAST or
         new_dir == yatm_core.D_WEST or
         new_dir == yatm_core.D_NORTH or
         new_dir == yatm_core.D_SOUTH then
    return "steam_tank", capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)

function condenser_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  local meta = minetest.get_meta(pos)

  local steam_fluid_stack = FluidMeta.get_fluid_stack(meta, "steam_tank")
  return 0
end

local groups = {
  cracky = 1,
  fluid_interface_in = 1,
  fluid_interface_out = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:condenser",

  description = "Condenser",

  groups = groups,

  drop = condenser_yatm_network.states.off,

  tiles = {
    "yatm_condenser_top.off.png",
    "yatm_condenser_bottom.off.png",
    "yatm_condenser_side.off.png",
    "yatm_condenser_side.off.png^[transformFX",
    "yatm_condenser_back.off.png",
    "yatm_condenser_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = condenser_yatm_network,

  fluid_interface = fluid_interface,

  refresh_infotext = condenser_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_condenser_top.error.png",
      "yatm_condenser_bottom.error.png",
      "yatm_condenser_side.error.png",
      "yatm_condenser_side.error.png^[transformFX",
      "yatm_condenser_back.error.png",
      "yatm_condenser_front.error.png"
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_condenser_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.4
        },
      },
      "yatm_condenser_bottom.on.png",
      "yatm_condenser_side.on.png",
      "yatm_condenser_side.on.png^[transformFX",
      {
        name = "yatm_condenser_back.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.4
        },
      },
      "yatm_condenser_front.on.png"
    },
  }
})
