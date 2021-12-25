--
--
--
local random_string62 = assert(foundation.com.random_string62)
local random_string = assert(foundation.com.random_string)

local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local data_network = assert(yatm.data_network)
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)

local function get_computer_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, 4, 4, { bg = "computer" }, function (loc, rect)
    if loc == "main_body" then
      return ""
    elseif loc == "footer" then
      return fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function computer_on_receive_fields(player, formname, fields, assigns)
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

local function computer_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local function computer_after_place_node(pos, _placer, _item_stack, _pointed_thing)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)

  local secret = random_string62(8)
  meta:set_string("secret", "comp." .. secret)

  yatm.computers:create_computer(pos, node, secret, {})
  data_network:add_node(pos, node)
  yatm.devices.device_after_place_node(pos, node)
end

local function computer_on_destruct(pos)
  yatm.devices.device_on_destruct(pos)
end

local function computer_after_destruct(pos, old_node)
  data_network:remove_node(pos, old_node)
  yatm.computers:destroy_computer(pos, old_node)
  yatm.devices.device_after_destruct(pos, old_node)
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
    conflict = "yatm_oku:computer_error",
    error = "yatm_oku:computer_error",
    off = "yatm_oku:computer_off",
    on = "yatm_oku:computer_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 0,
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
  cracky = 1,
  yatm_data_device = 1,
  yatm_network_device = 1,
  yatm_energy_device = 1,
  yatm_computer = 1,
  data_programmable = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_oku:computer",

  description = "Computer",

  codex_entry_id = "yatm_oku:computer",

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

  refresh_infotext = computer_refresh_infotext,

  after_place_node = computer_after_place_node,
  on_destruct = computer_on_destruct,
  after_destruct = computer_after_destruct,

  on_rightclick = function (pos, node, user)
    local formspec_name = "yatm_oku:computer:" .. minetest.pos_to_string(pos)
    local assigns = { pos = pos, node = node }
    local formspec = get_computer_formspec(pos, user)

    nokore.formspec_bindings:show_formspec(user:get_player_name(), formspec_name, formspec, {
      state = assigns,
      on_receive_fields = computer_on_receive_fields
    })
  end,

  register_computer = function (pos, node)
    local meta = minetest.get_meta(pos)
    local secret = meta:get_string("secret")
    if not secret then
      secret = random_string(8)
      meta:set_string("secret", "comp." .. secret)
    end
    yatm.computers:upsert_computer(pos, node, meta:get_string("secret"), {})
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
