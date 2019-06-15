--
-- OKU Micro Controller
-- The micro controler is a limited computer, it doesn't have any extra
-- built-in memory, so the load and strore instructions are no-ops.
-- They can only execute 16 instructions, since they only have space for those 16 instructions.
-- And they can only communicate with 16 ports total, these specific 16 ports can
-- be selected in the interface, allowing the use of a multi bus.
--
-- Despite all these limitations, it doesn't require a YATM energy source.
--
-- Even the designer is baffled by that.
--
local data_network = assert(yatm.data_network)

local function micro_controller_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local micro_controller_data_network_device = {
  type = "device",
  groups = {
    updatable = 1,
  }
}

local function micro_controller_after_place_node(pos, _placer, _item_stack, _pointed_thing)
  local node = minetest.get_node(pos)
  data_network:register_member(pos, node)
end

local function micro_controller_on_destruct(pos)
end

local function micro_controller_after_destruct(pos, old_node)
  data_network:unregister_member(pos, old_node)
end

local micro_controller_data_interface = {}

function micro_controller_data_interface.update(pos, node, dt)
  --
end

function micro_controller_data_interface.receive_pdu(pos, node, port, value)
end

local groups = {
  cracky = 1,
  yatm_data_device = 1,
}

minetest.register_node("yatm_oku:oku_micro_controller", {
  description = "OKU Micro Controller",

  groups = groups,

  tiles = {
    "yatm_computer_top.off.png",
    "yatm_computer_bottom.png",
    "yatm_computer_side.off.png",
    "yatm_computer_side.off.png^[transformFX",
    "yatm_computer_back.png",
    "yatm_computer_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  data_network_device = micro_controller_data_network_device,

  data_interface = micro_controller_data_interface,

  refresh_infotext = micro_controller_refresh_infotext,

  after_place_node = micro_controller_after_place_node,
  on_destruct = micro_controller_on_destruct,
  after_destruct = micro_controller_after_destruct,
})
