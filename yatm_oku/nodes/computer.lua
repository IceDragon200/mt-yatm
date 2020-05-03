--
--
--
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local data_network = assert(yatm.data_network)
local Energy = assert(yatm.energy)

local function get_computer_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local meta = minetest.get_meta(pos)
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "computer")

  --[[for i = 0,15 do
    local x = 0.25 + math.floor(i % 4)
    local y = 0.5 + math.floor(i / 4)
    local port_id = i + 1
    local port_value = meta:get_int("p" .. port_id)
    formspec = formspec ..
      "field[" .. x .. "," .. y .. ";1,1;p" .. port_id .. ";Port " .. port_id .. ";" .. port_value .. "]" ..
      "field_close_on_enter[p" .. port_id .. ",false]"
  end]]

  formspec =
    formspec ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    default.get_hotbar_bg(0,4.85)

  return formspec
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
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local function computer_after_place_node(pos, _placer, _item_stack, _pointed_thing)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)

  local secret = yatm_core.random_string62(8)
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

local computer_data_interface = {}

function computer_data_interface.on_load(self, pos, node)
  --
end

function computer_data_interface.receive_pdu(self, pos, node, dir, port, value)
  --
end

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

function computer_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  local energy_consumed = 0
  local nodedef = minetest.registered_nodes[node.name]
  -- TODO
  return energy_consumed
end

local groups = {
  cracky = 1,
  yatm_data_device = 1,
  yatm_network_device = 1,
  yatm_energy_device = 1,
  yatm_computer = 1,
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
    yatm_core.bind_on_player_receive_fields(user, formspec_name,
                                            { pos = pos, node = node },
                                            computer_on_receive_fields)
    minetest.show_formspec(
      user:get_player_name(),
      formspec_name,
      get_computer_formspec(pos, user)
    )
  end,

  register_computer = function (pos, node)
    local meta = minetest.get_meta(pos)
    local secret = meta:get_string("secret")
    if not secret then
      secret = yatm_core.random_string(8)
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
