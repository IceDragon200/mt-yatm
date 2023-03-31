local Directions = assert(foundation.com.Directions)
local Energy = assert(yatm.energy)
local ItemInterface = assert(yatm.items.ItemInterface)
local Vector3 = assert(foundation.com.Vector3)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)
local drill_node_to_meta_inventory = assert(yatm.mining.drill_node_to_meta_inventory)

local quarry_item_interface = ItemInterface.new_simple("main")

local function maybe_initialize_inventory(meta)
  local inv = meta:get_inventory()

  inv:set_size("main", 4) -- Quarry has a small internal inventory
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)

  meta:set_int("cx", -8)
  meta:set_int("cy", 0)
  meta:set_int("cz", 0)

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
    capacity = 32000,
    network_charge_bandwidth = 10000,
    startup_threshold = 1000,
    passive_lost = 0,
  }
}

-- @spec &work(WorkContext): (energy_consumed: Number)
function yatm_network:work(ctx)
  local pos = ctx.pos
  local meta = ctx.meta
  local node = ctx.node
  local dtime = ctx.dtime

  local worked = false

  local energy_consumed = 0

  local cooldown = meta:get_float("cooldown")

  if cooldown > 0 then
    worked = true
    cooldown = cooldown - dtime
    meta:set_float("cooldown", cooldown)
    ctx:set_up_state("on")
    return energy_consumed
  end

  local energy_to_consume = 1000

  if ctx.available_energy >= energy_to_consume then
    -- get current cursor position
    local cx = meta:get_int("cx")
    local cy = meta:get_int("cy")
    local cz = meta:get_int("cz")

    local delta_x = meta:get_int("dx")
    if delta_x == 0 then
      delta_x = 1
    end
    local delta_y = meta:get_int("dy")
    if delta_y == 0 then
      delta_y = -1
    end
    local delta_z = meta:get_int("dz")
    if delta_z == 0 then
      delta_z = 1
    end

    -- determine coords matrix
    local north_dir = Directions.facedir_to_face(node.param2, Directions.D_NORTH)
    local east_dir = Directions.facedir_to_face(node.param2, Directions.D_EAST)
    local up_dir = Directions.facedir_to_face(node.param2, Directions.D_UP)

    local nv = Directions.DIR6_TO_VEC3[north_dir]
    local ev = Directions.DIR6_TO_VEC3[east_dir]
    local uv = Directions.DIR6_TO_VEC3[up_dir]

    local new_nv = vector.multiply(nv, cz)
    local new_ev = vector.multiply(ev, cx)
    local new_uv = vector.multiply(uv, cy)

    local cursor_relative_pos = {}
    cursor_relative_pos = Vector3.add(cursor_relative_pos, new_nv, new_ev)
    cursor_relative_pos = Vector3.add(cursor_relative_pos, cursor_relative_pos, new_uv)
    -- the cursor is always 1 step ahead of the quarry
    cursor_relative_pos = Vector3.add(cursor_relative_pos, cursor_relative_pos, north_dir)
    local cursor_pos = vector.add(pos, cursor_relative_pos)

    -- TODO: respect permissions
    print("Digging " .. minetest.pos_to_string(cursor_pos))

    local drilled_node = drill_node_to_meta_inventory(cursor_pos, meta, "main")

    if drilled_node then
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
        cy = cy + delta_y
      elseif cz < 0 then
        cz = 0
        delta_z = 1
        delta_x = -delta_x
        cy = cy + delta_y
      end

      meta:set_int("cx", cx)
      meta:set_int("cy", cy)
      meta:set_int("cz", cz)
      meta:set_int("dx", delta_x)
      meta:set_int("dy", delta_y)
      meta:set_int("dz", delta_z)

      -- TODO: Spawn a cursor entity which marks the position the quarry is currently working on.
      --       The cursor should have a simple animation where lines go up the sides of the cube.
      --       Once the lines reach the top, the target node is removed and added to the internal inventory.
      --       Then the cursor moves to the next tile and repeats.

      worked = true

      if drilled_node.name ~= "air" then
        energy_consumed = energy_consumed + energy_to_consume
      end

      cooldown = cooldown + 0.25
      meta:set_float("cooldown", cooldown)
      meta:set_float("cooldown_max", cooldown)
      meta:set_string("last_drilled_node", drilled_node.name)
    else
      meta:set_string("last_drilled_node", "")
    end
  end

  if worked then
    ctx:set_up_state("on")
  else
    ctx:set_up_state("idle")
  end

  return energy_consumed
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      local cooldown = math.max(meta:get_float("cooldown"), 0)
      local cooldown_max = math.max(meta:get_float("cooldown_max"), 0)

      local cx = meta:get_int("cx")
      local cy = meta:get_int("cy")
      local cz = meta:get_int("cz")

      local dx = meta:get_int("dx")
      local dy = meta:get_int("dy")
      local dz = meta:get_int("dz")

      return "" ..
        fspec.label(rect.x + cio(2), rect.y, "Cursor-Pos: " .. cx .. "," .. cy .. "," .. cz) ..
        fspec.label(rect.x + cio(2), rect.y + cio(0.5), "Offset-Pos: " .. dx .. "," .. dy .. "," .. dz) ..
        fspec.item_image(
          rect.x,
          rect.y + cio(2),
          1,
          1,
          meta:get_string("last_drilled_node")
        ) ..
        fspec.list(
          node_inv_name,
          "main",
          rect.x,
          rect.y,
          2,
          2
        ) ..
        yatm_fspec.render_gauge{
          x = rect.x,
          y = rect.y + rect.h - cis(1),
          w = rect.w - cio(1),
          h = 1,
          amount = cooldown,
          max = cooldown_max,
          is_horz = true,
          gauge_colors = {"#FFFFFF", "#077f74"},
          border_name = "yatm_item_border_progress.png",
        } ..
        yatm_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cis(1),
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
  local meta = minetest.get_meta(pos)
  maybe_initialize_inventory(meta)
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
    cracky = nokore.dig_class("copper"),
    --
    item_interface_out = 1,
    yatm_energy_device = 1,
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
