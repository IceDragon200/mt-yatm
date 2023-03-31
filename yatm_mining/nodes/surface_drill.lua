local Directions = assert(foundation.com.Directions)
local Energy = assert(yatm.energy)
local ItemInterface = assert(yatm.items.ItemInterface)
local Vector3 = assert(foundation.com.Vector3)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)
local drill_node_to_meta_inventory = assert(yatm.mining.drill_node_to_meta_inventory)

local function maybe_initialize_inventory(meta)
  local inv = meta:get_inventory()

  inv:set_size("main", 4) -- Surface drill's have a small internal inventory
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)

  maybe_initialize_inventory(meta)

  yatm.devices.device_on_construct(pos)
end

local surface_drill_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_mining:surface_drill_error",
    error = "yatm_mining:surface_drill_error",
    idle = "yatm_mining:surface_drill_idle",
    off = "yatm_mining:surface_drill_off",
    on = "yatm_mining:surface_drill_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 16000,
    network_charge_bandwidth = 500,
    startup_threshold = 200,
  },
}

local function update_bit(ctx)
  local pos = ctx.pos
  local node = ctx.node
  local meta = ctx.meta

  local new_face = Directions.facedir_to_face(node.param2, Directions.D_DOWN)
  assert(new_face)
  local mine_dirv3 = Directions.DIR6_TO_VEC3[new_face]
  local mine_pos = pos
  local bit_node = {
    name = "yatm_mining:surface_drill_bit",
    param2 = node.param2,
  }
  while true do
    mine_pos = vector.add(mine_pos, mine_dirv3)
    local mine_node = minetest.get_node(mine_pos)
    if mine_node.name == "air" then
      --print("SET NODE", mine_pos.x, mine_pos.y, mine_pos.z, bit_node.name, bit_node.param2)
      minetest.set_node(mine_pos, bit_node)
      return true
    else
      local mine_nodedef = minetest.registered_nodes[mine_node.name]
      if mine_nodedef then
        if mine_nodedef.groups.surface_drill_bit then
          --print("IS BIT", mine_pos.x, mine_pos.y, mine_pos.z)
          -- TODO check if the bit belongs to the surface drill
        else
          --print("DIGGING", mine_pos.x, mine_pos.y, mine_pos.z, mine_node.name)
          drill_node_to_meta_inventory(mine_pos, meta, "main")
          return true
        end
      else
        return false
      end
    end
  end
end

function surface_drill_yatm_network:work(ctx)
  local meta = ctx.meta
  local node = ctx.node
  local pos = ctx.pos
  local dtime = ctx.dtime

  local worked = false

  local energy_consumed = 0

  local cooldown = meta:get_float("cooldown")
  if cooldown > 0 then
    worked = true
    cooldown = cooldown - dtime
    ctx:set_up_state("on")
    return energy_consumed
  end

  if ctx.available_energy > 100 then
    local new_face = Directions.facedir_to_face(node.param2, Directions.D_UP)
    assert(new_face)
    local up_dirv3 = Directions.DIR6_TO_VEC3[new_face]
    local segments = 1
    local ext_pos = pos
    -- Count all the attached extensions
    local ext_node
    local ext_nodedef

    while true do
      ext_pos = vector.add(ext_pos, up_dirv3)
      ext_node = minetest.get_node(ext_pos)
      ext_nodedef = minetest.registered_nodes[ext_node.name]
      if ext_nodedef then
        --print("node def", ext_pos.x, ext_pos.y, ext_pos.z, ext_node.name)
        if ext_nodedef.groups.surface_drill_ext then
          segments = segments + 1
        else
          break
        end
      else
        --print("No node def", ext_pos.x, ext_pos.y, ext_pos.z, ext_node.name)
        break
      end
    end

    if update_bit(ctx) then
      cooldown = cooldown + math.max(0.25, 1 / segments)
      meta:set_float("cooldown", cooldown)
      meta:set_float("cooldown_max", cooldown)

      energy_consumed = 100
      worked = true
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

      return fspec.list(
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
  return "yatm_machines:surface_drill:"..Vector3.to_string(pos)
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
  basename = "yatm_mining:surface_drill",

  description = "Surface Drill",

  codex_entry_id = "yatm_mining:surface_drill",

  groups = {
    cracky = nokore.dig_class("iron"),
    --
    surface_drill = 1,
    yatm_energy_device = 1,
  },

  drop = surface_drill_yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_surface_drill_top.off.png",
    "yatm_surface_drill_bottom.png",
    "yatm_surface_drill_side.off.png",
    "yatm_surface_drill_side.off.png^[transformFX",
    "yatm_surface_drill_back.off.png",
    "yatm_surface_drill_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",
  yatm_network = surface_drill_yatm_network,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_surface_drill_top.error.png",
      "yatm_surface_drill_bottom.png",
      "yatm_surface_drill_side.error.png",
      "yatm_surface_drill_side.error.png^[transformFX",
      "yatm_surface_drill_back.error.png",
      "yatm_surface_drill_front.error.png"
    },
  },
  idle = {
    tiles = {
      "yatm_surface_drill_top.idle.png",
      "yatm_surface_drill_bottom.png",
      "yatm_surface_drill_side.idle.png",
      "yatm_surface_drill_side.idle.png^[transformFX",
      "yatm_surface_drill_back.idle.png",
      "yatm_surface_drill_front.idle.png"
    },
  },
  on = {
    tiles = {
      "yatm_surface_drill_top.on.png",
      "yatm_surface_drill_bottom.png",
      "yatm_surface_drill_side.on.png",
      "yatm_surface_drill_side.on.png^[transformFX",
      "yatm_surface_drill_back.on.png",
      "yatm_surface_drill_front.on.png",
    },
  }
})

local surface_drill_ext_yatm_network = {
  basename = "yatm_mining:surface_drill_ext",
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_mining:surface_drill_ext_error",
    error = "yatm_mining:surface_drill_ext_error",
    off = "yatm_mining:surface_drill_ext_off",
    on = "yatm_mining:surface_drill_ext_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 10,
    network_charge_bandwidth = 500,
    startup_threshold = 100,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_mining:surface_drill_ext",

  description = "Surface Drill Extension",

  codex_entry_id = "yatm_mining:surface_drill_ext",

  groups = {
    cracky = nokore.dig_class("copper"),
    surface_drill_ext = 1
  },

  drop = surface_drill_ext_yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_surface_drill_top.off.png",
    "yatm_surface_drill_bottom.png",
    "yatm_surface_drill_side.ext.off.png",
    "yatm_surface_drill_side.ext.off.png",
    "yatm_surface_drill_side.ext.off.png",
    "yatm_surface_drill_side.ext.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",
  yatm_network = surface_drill_ext_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_surface_drill_top.error.png",
      "yatm_surface_drill_bottom.png",
      "yatm_surface_drill_side.ext.error.png",
      "yatm_surface_drill_side.ext.error.png",
      "yatm_surface_drill_side.ext.error.png",
      "yatm_surface_drill_side.ext.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_surface_drill_top.on.png",
      "yatm_surface_drill_bottom.png",
      "yatm_surface_drill_side.ext.on.png",
      "yatm_surface_drill_side.ext.on.png",
      "yatm_surface_drill_side.ext.on.png",
      "yatm_surface_drill_side.ext.on.png",
    },
  }
})

minetest.register_node("yatm_mining:surface_drill_bit", {
  description = "Surface Drill Bit",

  codex_entry_id = "yatm_mining:surface_drill_bit",

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    surface_drill_bit = 1,
    not_in_creative_inventory = 1
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_surface_drill_bit.top.png",
    "yatm_surface_drill_bit.bottom.png",
    "yatm_surface_drill_bit.side.png",
    "yatm_surface_drill_bit.side.png",
    "yatm_surface_drill_bit.side.png",
    "yatm_surface_drill_bit.side.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, -- NodeBox2
    }
  }
})
