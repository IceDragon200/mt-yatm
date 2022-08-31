local Directions = assert(foundation.com.Directions)
local Energy = assert(yatm.energy)
local ItemInterface = assert(yatm.items.ItemInterface)
local Vector3 = assert(foundation.com.Vector3)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)

local quarry_item_interface = ItemInterface.new_simple("main")

local function maybe_initialize_inventory(meta)
  local inv = meta:get_inventory()

  inv:set_size("main", 4) -- Quarry has a small internal inventory

  meta:set_int("cx", -8)
  meta:set_int("cy", 0)
  meta:set_int("cz", 0)

  meta:set_int("dx", 1)
  meta:set_int("dz", 1)
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)

  maybe_initialize_inventory(meta)

  yatm.devices.device_on_construct(pos)
end

local yatm_network = {
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

function yatm_network:work(ctx)
  local pos = ctx.pos
  local meta = ctx.meta
  local node = ctx.node

  if ctx.available_energy > 200 then
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

    return 200
  end

  return 0
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      return yatm_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cio(1),
          rect.y,
          1,
          rect.h,
          meta,
          yatm.devices.ENERGY_BUFFER_KEY,
          yatm.devices.get_energy_capacity(pos, state.node)
        )
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_machines:quarry:"..Vector3.to_string(pos)
end

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, user)
  local state = {
    pos = pos,
    node = node,
  }
  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
      timers = {
        -- routinely update the formspec
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_mining:quarry",

  description = "Quarry",

  codex_entry_id = "yatm_mining:quarry",

  drop = yatm_network.states.off,

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

  on_construct = on_construct,

  item_interface = quarry_item_interface,

  yatm_network = yatm_network,

  on_rightclick = on_rightclick,
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
