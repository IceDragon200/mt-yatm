--
-- Digitizers take physical items/fluids and inserts them into the dscs network.
--
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)

local digitizer_yatm_network = {
  kind = "machine",
  groups = {
    dscs_digitizer_module = 1,
    energy_consumer = 1,
    item_consumer = 1,
    machine_worker = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:digitizer_error",
    error = "yatm_dscs:digitizer_error",
    off = "yatm_dscs:digitizer_off",
    on = "yatm_dscs:digitizer_on",
  },
  energy = {
    capacity = 4000,
    startup_threshold = 200,
    network_charge_bandwidth = 100,
    passive_lost = 0, -- digitizers won't passively start losing energy
  },
}

function digitizer_yatm_network.work(pos, node, total_energy_available, work_rate, dtime, ot)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local energy_available = total_energy_available

  for i = 1,6 do
    if energy_available < 100 then
      break
    end
    local stack = inv:get_stack("main", i)

    if not stack:is_empty() then
      -- TODO: push into network

      -- Each item pushed into the network requires 100 energy per total stack
      local energy_used = math.ceil(100 * stack:get_count() / stack:get_stack_max())
      energy_available = energy_available - energy_used
    end
  end

  if energy_available >= 100 then
    local fluid_stack = FluidMeta.get_fluid_stack(meta, "tank")
    if fluid_stack and not FluidStack.is_empty(fluid_stack) then
      -- TODO: push into network

      local energy_used = math.ceil(100 * fluid_stack.size / 4000)
      energy_available = energy_available - energy_used
    end
  end

  return total_energy_available - energy_available
end

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    "Digitizer\n" ..
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. " [" .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "]\n"

  meta:set_string("infotext", infotext)
end

local item_interface = yatm.items.ItemInterface.new_simple("main")
local fluid_interface = yatm.fluids.FluidInterface.new_simple("tank", 4000)

local groups = {
  cracky = 1,
  yatm_dscs_device = 1,
  yatm_network_device = 1,
  yatm_energy_device = 1,
  item_interface_in = 1,
  fluid_interface_in = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:digitizer",

  description = "Digitizer",

  groups = groups,

  drop = digitizer_yatm_network.states.off,

  tiles = {"yatm_digitizer_side.off.png"},

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = digitizer_yatm_network,
  data_network_device = {
    type = "device",
  },

  refresh_infotext = refresh_infotext,

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    local inventory = meta:get_inventory()

    inventory:set_size("main", 6)

    yatm.devices.device_on_construct(pos)
  end,

  on_dig = function (pos, node, digger)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    local fluid_stack = FluidMeta.get_fluid_stack(meta, "tank")
    if inv:is_empty("main") and FluidStack.is_empty(fluid_stack) then
      return minetest.node_dig(pos, node, digger)
    end

    return false
  end,

  item_interface = item_interface,
  fluid_interface = fluid_interface,
}, {
  on = {
    tiles = {{
      name = "yatm_digitizer_side.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 4.0
      },
    }},
  },
  error = {
    tiles = {"yatm_digitizer_side.error.png"},
  }
})
