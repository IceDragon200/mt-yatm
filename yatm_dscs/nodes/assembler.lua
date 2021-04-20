--
-- It looks just like AE2's Molecular Assembler, and has the same function too.
--
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local assembler_yatm_network = {
  kind = "machine",
  groups = {
    dscs_assembler_module = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
    machine_worker = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:assembler_error",
    error = "yatm_dscs:assembler_error",
    off = "yatm_dscs:assembler_off",
    on = "yatm_dscs:assembler_on",
  },
  energy = {
    capacity = 4000,
    startup_threshold = 200,
    network_charge_bandwidth = 100,
    passive_lost = 0, -- assemblers won't passively start losing energy
  },
}

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    "Assembler\n" ..
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. " [" .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "]\n"

  meta:set_string("infotext", infotext)
end

function assembler_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  local meta = minetest.get_meta(pos)

  return 0
end

local assembler_node_box = {
  type = "fixed",
  fixed = {
    {-0.4375, -0.4375, -0.4375, 0.4375, 0.4375, 0.4375}, -- NodeBox1
    {-0.5, -0.5, -0.5, -0.375, 0.5, -0.375}, -- NodeBox2
    {0.375, -0.5, -0.5, 0.5, 0.5, -0.375}, -- NodeBox3
    {-0.5, -0.5, 0.375, -0.375, 0.5, 0.5}, -- NodeBox4
    {0.375, -0.5, 0.375, 0.5, 0.5, 0.5}, -- NodeBox5
    {-0.375, 0.375, 0.375, 0.375, 0.5, 0.5}, -- NodeBox6
    {-0.375, 0.375, -0.5, 0.375, 0.5, -0.375}, -- NodeBox7
    {-0.5, 0.375, -0.5, -0.375, 0.5, 0.5}, -- NodeBox8
    {0.375, 0.375, -0.5, 0.5, 0.5, 0.5}, -- NodeBox9
    {-0.5, -0.5, -0.5, 0.5, -0.375, -0.375}, -- NodeBox10
    {-0.5, -0.5, 0.375, 0.5, -0.375, 0.5}, -- NodeBox11
    {-0.5, -0.5, -0.5, -0.375, -0.375, 0.5}, -- NodeBox12
    {0.375, -0.5, -0.5, 0.5, -0.375, 0.5}, -- NodeBox13
  }
}

local assembler_selection_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
  },
}

local groups = {
  cracky = 1,
  yatm_dscs_device = 1,
  yatm_data_device = 1,
  yatm_network_device = 1,
  yatm_energy_device = 1,
}

local assembler_data_interface = {}

function assembler_data_interface.on_load(self, pos, node)
end

function assembler_data_interface.receive_pdu(self, pos, node, dir, port, value)
  --
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_dscs:assembler",

  codex_entry_id = "yatm_dscs:assembler",

  description = "Item Assembler",

  groups = groups,

  drop = assembler_yatm_network.states.off,

  tiles = {"yatm_assembler_side.off.png"},
  use_texture_alpha = "clip",

  drawtype = "nodebox",
  node_box = assembler_node_box,

  selection_box = assembler_selection_box,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = assembler_yatm_network,
  data_network_device = {
    type = "device",
  },
  data_interface = assembler_data_interface,

  refresh_infotext = refresh_infotext,
}, {
  on = {
    tiles = {{
      name = "yatm_assembler_side.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    }},
  },
  error = {
    tiles = {"yatm_assembler_side.error.png"},
  }
})
