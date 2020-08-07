local Directions = assert(foundation.com.Directions)
local ItemInterface = assert(yatm.items.ItemInterface)

local quarry_item_interface = ItemInterface.new_simple("main")

local function quarry_on_construct(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  inv:set_size("main", 4) -- Quarry has a small internal inventory

  meta:set_int("cx", -8)
  meta:set_int("cy", 0)
  meta:set_int("cz", 0)

  meta:set_int("dx", 1)
  meta:set_int("dz", 1)

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
    idle = "yatm_mining:quarry_idle",
  },

  energy = {
    capacity = 16000,
    network_charge_bandwidth = 500,
    startup_threshold = 1000,
    passive_lost = 0,
  }
}

function quarry_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  local meta = minetest.get_meta(pos)

  -- get current cursor position
  local cx = meta:get_int("cx")
  local cy = meta:get_int("cy")
  local cz = meta:get_int("cz")

  local delta_x = meta:get_int("dx")
  if delta_x == 0 then
    delta_x = 1
  end
  local delta_z = meta:get_int("dz")
  if delta_z == 0 then
    delta_z = 1
  end

  -- determine coords matrix
  local north_dir = Directions.facedir_to_face(node.param2, Directions.D_NORTH)
  local east_dir = Directions.facedir_to_face(node.param2, Directions.D_EAST)
  local down_dir = Directions.facedir_to_face(node.param2, Directions.D_DOWN)

  local nv = Directions.DIR6_TO_VEC3[north_dir]
  local ev = Directions.DIR6_TO_VEC3[east_dir]
  local dv = Directions.DIR6_TO_VEC3[down_dir]

  local new_nv = vector.multiply(nv, cz)
  local new_ev = vector.multiply(ev, cx)
  local new_dv = vector.multiply(dv, cy)

  local cursor_relative_pos = vector.add(vector.add(new_nv, new_ev), new_dv)
  cursor_relative_pos = vector.add(cursor_relative_pos, north_dir) -- the cursor is always 1 step ahead of the quarry
  local cursor_pos = vector.add(pos, cursor_relative_pos)

  -- TODO: respect permissions
  print("Removing " .. minetest.pos_to_string(cursor_pos))
  minetest.remove_node(cursor_pos)
  -- TODO: store removed node, or determine if it can be stored

  -- Finally move the cursor to the next location
  cx = cx + delta_x

  if cx > 7 then
    cx = 7 -- clamp
    delta_x = -1 -- reverse delta
    cz = cz + delta_z
  elseif cx < -8 then
    cx = -8
    delta_x = 1
    cz = cz + delta_z
  end

  if cz > 16 then
    cz = 16
    delta_z = -1
    delta_x = -delta_x
    cy = cy + 1
  elseif cz < 0 then
    cz = 0
    delta_z = 1
    delta_x = -delta_x
    cy = cy + 1
  end

  meta:set_int("cx", cx)
  meta:set_int("cy", cy)
  meta:set_int("cz", cz)
  meta:set_int("dx", delta_x)
  meta:set_int("dz", delta_z)

  -- TODO: Spawn a cursor entity which marks the position the quarry is currently working on.
  --       The cursor should have a simple animation where lines go up the sides of the cube.
  --       Once the lines reach the top, the target node is removed and added to the internal inventory.
  --       Then the cursor moves to the next tile and repeats.

  return 0
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_mining:quarry",

  description = "Quarry",

  codex_entry_id = "yatm_mining:quarry",

  drop = quarry_yatm_network.states.off,

  groups = {
    cracky = 1,
    item_interface_out = 1,
  },

  tiles = {
    "yatm_quarry_top.off.png",
    "yatm_quarry_bottom.png",
    "yatm_quarry_side.off.png",
    "yatm_quarry_side.off.png^[transformFX",
    "yatm_quarry_back.off.png",
    "yatm_quarry_front.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  on_construct = quarry_on_construct,

  item_interface = quarry_item_interface,

  yatm_network = quarry_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_quarry_top.error.png",
      "yatm_quarry_bottom.png",
      "yatm_quarry_side.error.png",
      "yatm_quarry_side.error.png^[transformFX",
      "yatm_quarry_back.error.png",
      "yatm_quarry_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_quarry_top.on.png",
      "yatm_quarry_bottom.png",
      "yatm_quarry_side.on.png",
      "yatm_quarry_side.on.png^[transformFX",
      "yatm_quarry_back.on.png",
      "yatm_quarry_front.on.png",
    },
  },
  idle = {
    tiles = {
      "yatm_quarry_top.idle.png",
      "yatm_quarry_bottom.png",
      "yatm_quarry_side.idle.png",
      "yatm_quarry_side.idle.png^[transformFX",
      "yatm_quarry_back.idle.png",
      "yatm_quarry_front.idle.png",
    },
  },
})
