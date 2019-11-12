local ItemInterface = assert(yatm.items.ItemInterface)

local quarry_item_interface = ItemInterface.new_simple("main")

local function quarry_on_construct(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  inv:set_size("main", 4) -- Quarry has a small internal inventory

  yatm.devices.device_on_construct(pos)
end

local quarry_yatm_network = {
  kind = "machine",

  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },

  default_state = "off",
  states = {
    conflict = "yatm_mining:quarry_error",
    error = "yatm_mining:quarry_error",
    on = "yatm_mining:quarry_on",
    off = "yatm_mining:quarry_off",
  },

  energy = {
    capacity = 16000,
    network_charge_bandwidth = 500,
    startup_threshold = 1000,
    passive_lost = 0,
  }
}

function quarry_yatm_network:work(pos, node, available_energy, work_rate, dtime, ot)
  local meta = minetest.get_meta(pos)

  -- TODO: Spawn a cursor entity which marks the position the quarry is currently working on.
  --       The cursor should have a simple animation where lines go up the sides of the cube.
  --       Once the lines reach the top, the target node is removed and added to the internal inventory.
  --       Then the cursor moves to the next tile and repeats.
  return 0
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_mining:quarry",

  description = "Quarry",

  groups = {
    cracky = 1,
    item_interface_out = 1,
  },

  tiles = {
    "yatm_quarry_top.off.png",
    "yatm_quarry_bottom.off.png",
    "yatm_quarry_side.off.png",
    "yatm_quarry_side.off.png^[transformFX",
    "yatm_quarry_back.off.png",
    "yatm_quarry_front.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = quarry_on_construct,

  item_interface = quarry_item_interface,

  yatm_network = quarry_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_quarry_top.error.png",
      "yatm_quarry_bottom.error.png",
      "yatm_quarry_side.error.png",
      "yatm_quarry_side.error.png^[transformFX",
      "yatm_quarry_back.error.png",
      "yatm_quarry_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_quarry_top.on.png",
      "yatm_quarry_bottom.on.png",
      "yatm_quarry_side.on.png",
      "yatm_quarry_side.on.png^[transformFX",
      "yatm_quarry_back.on.png",
      "yatm_quarry_front.on.png",
    },
  },
})
