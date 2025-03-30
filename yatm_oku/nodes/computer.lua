--
--
--
local mod = assert(yatm_oku)

local random_string62 = assert(foundation.com.random_string62)
local random_string = assert(foundation.com.random_string)

local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local data_network = assert(yatm.data_network)
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)

local function render_formspec(pos, user, assigns)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "computer" }, function (loc, rect)
    if loc == "main_body" then
      return ""
    elseif loc == "footer" then
      return fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)

  --[[for i = 1,16 do
    local field_name = "p" .. i
    if fields[field_name] then
      local port_id = math.min(256, math.max(0, math.floor(tonumber(fields[field_name]))))
      meta:set_int(field_name, port_id)
    end
  end]]

  return true
end

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local function on_construct(pos)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)

  local secret = random_string62(8)
  meta:set_string("secret", "comp." .. secret)

  yatm.devices.device_on_construct(pos)
  yatm.computers:create_computer_at_pos(pos, node, secret, {})
  data_network:add_node(pos, node)
end

local function on_destruct(pos)
  data_network:remove_node(pos)
  yatm.computers:destroy_computer_at_pos(pos)
  yatm.devices.device_on_destruct(pos)
end

local function on_rightclick(pos, node, user)
  local formspec_name = "yatm_oku:computer:" .. minetest.pos_to_string(pos)
  local assigns = { pos = pos, node = node }
  local formspec = render_formspec(pos, user, assigns)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    formspec_name,
    formspec,
    {
      state = assigns,
      on_receive_fields = on_receive_fields
    }
  )
end

local computer_data_interface = {
  on_load = function (self, pos, node)
  end,

  receive_pdu = function (self, pos, node, dir, port, value)
  end,

  get_programmer_formspec = {
    default_tab = "ports",
    tabs = {
      {
        tab_id = "ports",
        title = "Ports",
        header = "Port Configuration",
        render = {
          {
            component = "io_ports",
            mode = "io",
            input_vector = 16,
            output_vector = 16,
          }
        },
      },
    }
  },

  receive_programmer_fields = {
    tabbed = true, -- notify the solver that tabs are in use
    tabs = {
      {
        components = {
          {
            component = "io_ports",
            mode = "io",
            input_vector = 16,
            output_vector = 16,
          }
        }
      },
    }
  }
}

local computer_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = mod:make_name("computer_error"),
    error = mod:make_name("computer_error"),
    off = mod:make_name("computer_off"),
    on = mod:make_name("computer_on"),
  },
  energy = {
    capacity = 4000,
    passive_lost = 100,
    startup_threshold = 100,
    network_charge_bandwidth = 500,
  }
}

function computer_yatm_network:work(ctx)
  local energy_consumed = 0
  local nodedef = ctx.nodedef
  -- TODO
  return energy_consumed
end

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  yatm_data_device = 1,
  yatm_network_device = 1,
  yatm_energy_device = 1,
  yatm_computer = 1,
  data_programmable = 1,
}

yatm.devices.register_stateful_network_device({
  basename = mod:make_name("computer"),

  description = mod.S("Computer"),

  codex_entry_id = mod:make_name("computer"),

  groups = groups,

  drop = computer_yatm_network.states.off,

  tiles = {
    "yatm_computer_top.off.png",
    "yatm_computer_bottom.png",
    "yatm_computer_side.off.png",
    "yatm_computer_side.off.png^[transformFX",
    "yatm_computer_back.png",
    "yatm_computer_front.off.png"
  },
  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = computer_yatm_network,

  data_network_device = {
    type = "device",
  },

  data_interface = computer_data_interface,

  refresh_infotext = refresh_infotext,

  on_construct = on_construct,
  on_destruct = on_destruct,

  on_rightclick = on_rightclick,

  register_computer = function (pos, node)
    local meta = minetest.get_meta(pos)
    local secret = meta:get_string("secret")
    if not secret then
      secret = random_string(8)
      meta:set_string("secret", "comp." .. secret)
    end
    yatm.computers:upsert_computer_at_pos(pos, node, meta:get_string("secret"), {})
  end,
}, {
  error = {
    tiles = {
      "yatm_computer_top.error.png",
      "yatm_computer_bottom.png",
      "yatm_computer_side.error.png",
      "yatm_computer_side.error.png^[transformFX",
      "yatm_computer_back.png",
      "yatm_computer_front.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_computer_top.on.png",
      "yatm_computer_bottom.png",
      "yatm_computer_side.on.png",
      "yatm_computer_side.on.png^[transformFX",
      "yatm_computer_back.png",
      {
        name = "yatm_computer_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      }
    },
  }
})
