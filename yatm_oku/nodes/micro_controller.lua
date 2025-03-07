--
-- OKU Micro Controller
-- The micro controler is a limited computer, it doesn't have any extra
-- built-in memory, so the load and store instructions are no-ops.
-- They can only execute 16 instructions, since they only have space for those 16 instructions.
-- And they can only communicate with 16 ports total, these specific 16 ports can
-- be selected in the interface, allowing the use of a multi bus.
--
-- Despite all these limitations, it doesn't require a YATM energy source.
--
-- Even the designer is baffled by that.
--
local mod = assert(yatm_oku)
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local random_string62 = assert(foundation.com.random_string62)
local data_network = assert(yatm.data_network)

-- need at least 256 for the zero-page and then another for the stack, so addressable memory is really only
-- 512 bytes
local MEMORY_SIZE = 256 * 4
local PORT_COUNT = 16

local function get_micro_controller_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local meta = minetest.get_meta(pos)
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "computer")

  for i = 0,PORT_COUNT-1 do
    local x = 0.25 + math.floor(i % 4)
    local y = 0.5 + math.floor(i / 4)
    local port_id = i + 1
    local port_value = meta:get_int("p" .. port_id)
    formspec =
      formspec ..
      "field[" .. x .. "," .. y .. ";1,1;p" .. port_id .. ";Port " .. port_id .. ";" .. port_value .. "]" ..
      "field_close_on_enter[p" .. port_id .. ",false]"
  end

  formspec =
    formspec ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]"

  return formspec
end

local function micro_controller_on_receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)

  for i = 1,PORT_COUNT do
    local field_name = "p" .. i
    if fields[field_name] then
      local port_id = math.min(256, math.max(0, math.floor(tonumber(fields[field_name]))))
      meta:set_int(field_name, port_id)
    end
  end

  return true
end

local function micro_controller_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    "Micro Controller\n" ..
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local micro_controller_data_network_device = {
  type = "device",
  groups = {
    updatable = 1,
  }
}

local function maybe_initialize_secret(pos)
  local meta = minetest.get_meta(pos)
  local secret = meta:get_string("secret")
  if not secret then
    secret = random_string62(8)
    meta:set_string("secret", "mctl." .. secret)
  end
end

local function on_construct(pos)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)

  -- Initialize the controller ports
  for i = 1,PORT_COUNT do
    meta:set_int("p"..i, 0)
  end

  -- Initialize secret
  maybe_initialize_secret(pos)
  data_network:add_node(pos, node)

  yatm.computers:create_computer_at_pos(pos, node, secret, {
    memory_size = MEMORY_SIZE,
  })
end

local function on_destruct(pos)
  data_network:remove_node(pos)
  yatm.computers:destroy_computer_at_pos(pos)
end

local micro_controller_data_interface = {}

function micro_controller_data_interface.on_load(self, pos, node)
  --
end

function micro_controller_data_interface.update(self, pos, node, dt)
  --
  --print("Executing micro controller", dt, minetest.pos_to_string(pos), node.name)
end

function micro_controller_data_interface.receive_pdu(self, pos, node, dir, port, value)
end

local function register_computer(pos, node)
  local meta = minetest.get_meta(pos)
  maybe_initialize_secret(pos)
  yatm.computers:upsert_computer_at_pos(pos, node, meta:get_string("secret"), {
    arch = "mos6502",
    memory_size = MEMORY_SIZE,
  })
end

local function on_rightclick(pos, node, user)
  local formspec_name = "yatm_oku:oku_micro_controller:" .. minetest.pos_to_string(pos)
  local assigns = { pos = pos, node = node }
  local formspec = get_micro_controller_formspec(pos, user, assigns)

  nokore.formspec_bindings:show_formspec(user:get_player_name(), formspec_name, formspec, {
    state = assigns,
    on_receive_fields = micro_controller_on_receive_fields
  })
end

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  yatm_data_device = 1,
  yatm_computer = 1,
}

local micro_controller_nodebox = {
  type = "connected",
  fixed          = ng(3, 0, 3,10, 4,10),
  connect_top    = ng(5, 4, 5, 6,12, 6), -- y+
  connect_bottom = ng(2, 0, 2,12, 1,12), -- y-
  connect_front  = ng(4, 0, 0, 8, 3, 4), -- z-
  connect_back   = ng(4, 0,12, 8, 3, 4), -- z+
  connect_left   = ng(0, 0, 4, 4, 3, 8), -- x-
  connect_right  = ng(12,0, 4, 4, 3, 8), -- x+
}

local connects_to = {
  "group:data_cable_bus",
  --"group:mesecon",
}

local rules = {}
if mesecon then
  rules = assert(mesecon.rules.default)
else
  print("yatm_oku", "mesecons is unavailable, micro controller cannot be stepped with mesecon")
end

local micro_controller_mesecons = {
  effector = {
    rules = rules,

    action_on = function (pos, node)
      local nodedef = minetest.registered_nodes[node.name]
      -- TODO: pulse computer
    end,

    action_off = function (pos, node)
      -- Do, absolutely nothing.
    end,
  }
}

mod:register_node("oku_micro_controller", {
  basename = mod:make_name("oku_micro_controller"),

  description = mod.S("OKU Micro Controller [MOS6502]"),

  codex_entry_id = mod:make_name("oku_micro_controller"),

  groups = groups,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_oku_micro_controller_top.png",
    "yatm_oku_micro_controller_bottom.png",
    "yatm_oku_micro_controller_side.png",
    "yatm_oku_micro_controller_side.png",
    "yatm_oku_micro_controller_side.png",
    "yatm_oku_micro_controller_side.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = micro_controller_nodebox,

  connects_to = connects_to,

  data_network_device = micro_controller_data_network_device,

  data_interface = micro_controller_data_interface,

  refresh_infotext = micro_controller_refresh_infotext,

  on_construct = on_construct,
  on_destruct = on_destruct,

  on_rightclick = on_rightclick,

  register_computer = register_computer,

  mesecons = micro_controller_mesecons,
})
