--
-- Belt Loader
--
-- Handles automatically arming a belt magazine with given cartridges.
local mod = assert(yatm_armoury)

if not yatm_machines then
  return
end

local Directions = assert(foundation.com.Directions)
local ItemInterface = assert(yatm.items.ItemInterface)

local belt_loader_item_interface =
  ItemInterface.new_directional(function (self, pos, dir)
    local node = minetest.get_node(pos)
    local new_dir = Directions.facedir_to_face(node.param2, dir)

    if new_dir == Directions.D_EAST and new_dir == Directions.D_WEST then
      return "belt_items"
    else
      return "ammo_items"
    end
  end)

local yatm_network = {
  basename = "yatm_armoury:belt_loader",
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_armoury:belt_loader_error",
    conflict = "yatm_armoury:belt_loader_error",
    off = "yatm_armoury:belt_loader_off",
    on = "yatm_armoury:belt_loader_on",

    error_loaded = "yatm_armoury:belt_loader_error_loaded",
    conflict_loaded = "yatm_armoury:belt_loader_error_loaded",
    off_loaded = "yatm_armoury:belt_loader_off_loaded",
    on_loaded = "yatm_armoury:belt_loader_on_loaded",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 100,
    passive_lost = 10,
    startup_threshold = 500,
  },
}

function yatm_network:work(ctx)
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
  return mod:make_name("belt_loader:"..Vector3.to_string(pos))
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

local function on_construct(pos)
  yatm.devices.device_on_construct(pos)

  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
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
  codex_entry_id = "yatm_armoury:belt_loader",

  basename = "yatm_armoury:belt_loader",

  description = mod.S("Ammo Belt Loader"),

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    item_interface_in = 1,
    item_interface_out = 1,
  },

  tiles = {
    "yatm_belt_loader_top.unloaded.off.png",
    "yatm_belt_loader_bottom.unloaded.off.png",
    "yatm_belt_loader_side.unloaded.off.png",
    "yatm_belt_loader_side.unloaded.off.png^[transformFX",
    "yatm_belt_loader_side.unloaded.off.png^[transformFX",
    "yatm_belt_loader_side.unloaded.off.png",
  },

  on_construct = on_construct,

  on_rightclick = on_rightclick,

  yatm_network = yatm_network,
}, {
  off_loaded = {
    tiles = {
      "yatm_belt_loader_top.loaded.off.png",
      "yatm_belt_loader_bottom.loaded.off.png",
      "yatm_belt_loader_side.loaded.off.png",
      "yatm_belt_loader_side.loaded.off.png^[transformFX",
      "yatm_belt_loader_side.loaded.off.png^[transformFX",
      "yatm_belt_loader_side.loaded.off.png",
    }
  },

  error = {
    tiles = {
      "yatm_belt_loader_top.unloaded.error.png",
      "yatm_belt_loader_bottom.unloaded.error.png",
      "yatm_belt_loader_side.unloaded.error.png",
      "yatm_belt_loader_side.unloaded.error.png^[transformFX",
      "yatm_belt_loader_side.unloaded.error.png^[transformFX",
      "yatm_belt_loader_side.unloaded.error.png",
    },
  },

  error_loaded = {
    tiles = {
      "yatm_belt_loader_top.loaded.error.png",
      "yatm_belt_loader_bottom.loaded.error.png",
      "yatm_belt_loader_side.loaded.error.png",
      "yatm_belt_loader_side.loaded.error.png^[transformFX",
      "yatm_belt_loader_side.loaded.error.png^[transformFX",
      "yatm_belt_loader_side.loaded.error.png",
    },
  },

  on = {
    tiles = {
      "yatm_belt_loader_top.unloaded.on.png",
      "yatm_belt_loader_bottom.unloaded.on.png",
      "yatm_belt_loader_side.unloaded.on.png",
      "yatm_belt_loader_side.unloaded.on.png^[transformFX",
      "yatm_belt_loader_side.unloaded.on.png^[transformFX",
      "yatm_belt_loader_side.unloaded.on.png",
    },
  },

  on_loaded = {
    tiles = {
      {
        name = "yatm_belt_loader_top.loaded.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1,
        },
      },
      {
        name = "yatm_belt_loader_bottom.loaded.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1,
        },
      },
      {
        name = "yatm_belt_loader_side.loaded.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1,
        },
      },
      {
        name = "yatm_belt_loader_side.loaded.on.png^[transformFX",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1,
        },
      },
      {
        name = "yatm_belt_loader_side.loaded.on.png^[transformFX",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1,
        },
      },
      {
        name = "yatm_belt_loader_side.loaded.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1,
        },
      },
    },
  },
})
