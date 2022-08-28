local mod = yatm_machines
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local burn_time = meta:get_float("burn_time")
  local burn_time_max = meta:get_float("burn_time_max")

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Burn Time: " .. math.floor(burn_time) .. " / " .. math.floor(burn_time_max) .. "\n" ..
    "EN/t: " .. meta:get_float("last_energy_produced")

  meta:set_string("infotext", infotext)
end

local yatm_network = {
  kind = "energy_producer",
  groups = {
    device_controller = 3,
    item_consumer = 1,
    energy_producer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:coal_generator_error",
    error = "yatm_machines:coal_generator_error",
    idle = "yatm_machines:coal_generator_idle",
    off = "yatm_machines:coal_generator_off",
    on = "yatm_machines:coal_generator_on",
  },
  energy = {
    capacity = 8000,
  }
}

-- @spec energy.produce_energy(
--   pos: Vector3,
--   node: NodeRef,
--   dtime: Float,
--   trace: Trace
-- ): (energy: Number)
function yatm_network.energy.produce_energy(pos, node, dtime, trace)
  local meta = minetest.get_meta(pos)

  local burn_time = meta:get_float("burn_time")
  local burn_time_max = meta:get_float("burn_time_max")

  if burn_time_max <= 0 then
    local inv = meta:get_inventory()

    local stack = inv:get_stack("fuel_slot", 1)

    if yatm.is_item_solid_fuel(stack) then
      local output, decremented_input =
        minetest.get_craft_result{
          method = "fuel",
          width = 1,
          items = {stack}
        }

      if output.time and output.time > 0 then
        meta:set_float("burn_time_max", output.time)
        inv:set_stack("fuel_slot", 1, decremented_input.items[1])
      end
    end
  end

  local en_amount = 0

  if burn_time_max > 0 then
    local new_burn_time = math.min(burn_time + dtime, burn_time_max)
    local used_dtime = new_burn_time - burn_time

    if used_dtime > 0 then
      en_amount = math.round(used_dtime * 40)
    end

    if burn_time >= burn_time_max then
      meta:set_float("burn_time", 0.0)
      meta:set_float("burn_time_max", 0.0)
    else
      meta:set_float("burn_time", new_burn_time)
    end
  end

  meta:set_float("last_energy_produced", en_amount)

  yatm.queue_refresh_infotext(pos, node)

  return en_amount
end

-- @spec update(pos: Vector3, node: NodeRef, dtime: Float, trace: Trace): void
function yatm_network.update(pos, node, dtime, trace)
  --
end

local function maybe_initialize_inventory(meta)
  local inv = meta:get_inventory()

  inv:set_size("fuel_slot", 1)
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)

  maybe_initialize_inventory(meta)
end

-- @spec.private render_formspec(pos: Vector3, user: PlayerRef, state: Table): String
local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_electric" }, function (loc, rect)
    if loc == "main_body" then
      -- return yatm_fspec.render_meta_energy_gauge(
      --   rect.x + rect.w - cio(1),
      --   rect.y,
      --   1,
      --   rect.h,
      --   meta,
      --   yatm.devices.ENERGY_BUFFER_KEY,
      --   yatm.devices.get_energy_capacity(pos, state.node)
      -- )

      local burn_time = meta:get_float("burn_time")
      local burn_time_max = meta:get_float("burn_time_max")

      return fspec.list(
          node_inv_name,
          "fuel_slot",
          rect.x,
          rect.y,
          1,
          1
        ) ..
        yatm_fspec.render_gauge{
          x = rect.x + cio(1),
          y = rect.y,
          w = rect.w - cis(1),
          h = 1,
          amount = burn_time,
          max = burn_time_max,
          is_horz = true,
          gauge_colors = {"#FFFFFF", "#077f74"},
          border_name = "yatm_item_border_progress.png",
        }
    elseif loc == "footer" then
      return fspec.list_ring("current_player", "main") ..
        fspec.list_ring(node_inv_name, "fuel_slot")
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_machines:coal_generator:"..Vector3.to_string(pos)
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
  local formspec = render_formspec(pos, user, state)

  maybe_initialize_inventory(meta)

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
          every = 0.25,
          action = on_refresh_timer,
        },
      },
    }
  )
end

local groups = {
  cracky = 1,
  yatm_energy_device = 1,
  item_interface_in = 1,
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("coal_generator"),

  basename = mod:make_name("coal_generator"),

  description = mod.S("Coal Generator"),
  groups = groups,

  drop = yatm_network.states.off,

  tiles = {
    "yatm_coal_generator_top.off.png",
    "yatm_coal_generator_bottom.png",
    "yatm_coal_generator_side.off.png",
    "yatm_coal_generator_side.off.png",
    "yatm_coal_generator_back.off.png",
    "yatm_coal_generator_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = yatm_network,

  refresh_infotext = refresh_infotext,

  on_construct = on_construct,
  on_rightclick = on_rightclick,
}, {
  on = {
    tiles = {
      --"yatm_coal_generator_top.on.png",
      {
        name = "yatm_coal_generator_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_coal_generator_bottom.png",
      "yatm_coal_generator_side.on.png",
      "yatm_coal_generator_side.on.png",
      "yatm_coal_generator_back.on.png",
      "yatm_coal_generator_front.on.png"
    },
  },
  idle = {
    tiles = {
      "yatm_coal_generator_top.idle.png",
      "yatm_coal_generator_bottom.png",
      "yatm_coal_generator_side.idle.png",
      "yatm_coal_generator_side.idle.png",
      "yatm_coal_generator_back.idle.png",
      "yatm_coal_generator_front.idle.png"
    },
  },
  error = {
    tiles = {
      "yatm_coal_generator_top.error.png",
      "yatm_coal_generator_bottom.png",
      "yatm_coal_generator_side.error.png",
      "yatm_coal_generator_side.error.png",
      "yatm_coal_generator_back.error.png",
      "yatm_coal_generator_front.error.png"
    },
  },
})
