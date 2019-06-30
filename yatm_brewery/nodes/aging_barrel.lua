local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidInterface = assert(yatm.fluids.FluidInterface)

local barrel_nodebox = {
  type = "fixed",
  fixed = {
    {-0.4375, -0.4375, -0.4375, 0.4375, 0.4375, 0.4375}, -- NodeBox1
    {-0.5, -0.5, -0.5, 0.5, 0.5, -0.4375}, -- NodeBox2
    {-0.5, -0.5, 0.4375, 0.5, 0.5, 0.5}, -- NodeBox3
    {-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5}, -- NodeBox4
    {0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox5
  }
}

local function barrel_on_timer(pos, dt)
  -- loop
  get_node_timer(pos).start(1.0)
end

local function barrel_on_construct(pos)
  assert(yatm_core.queue_refresh_infotext(pos))
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  inv:set_size("culture_slot", 1)
end

local function barrel_on_destruct(pos)
  -- Barrel exit stage left
end

local function barrel_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  node = node or minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  local stack = FluidTanks.get_fluid(pos, yatm_core.D_NONE)
  if stack and stack.amount > 0 then
    meta:set_string("infotext",
      "Brewing Barrel: " ..
      stack.name ..
      " " ..
      stack.amount ..
      " / " ..
      nodedef.fluid_interface.capacity
    )
  else
    meta:set_string("infotext", "Barrel: Empty")
  end
end

local BARREL_CAPACITY = 4000 -- 4 buckets
local BARREL_DRAIN_BANDWIDTH = BARREL_CAPACITY
local barrel_fluid_interface = FluidInterface.new_simple("tank", BARREL_CAPACITY)
function barrel_fluid_interface:on_fluid_changed(pos, dir, stack)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  nodedef.refresh_infotext(pos, node)
end

local barrel_item_interface = ItemInterface.new_simple("culture_slot")


local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  get_node_timer(pos).start(1.0)
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
  get_node_timer(pos).start(1.0)
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
  get_node_timer(pos).start(1.0)
end


local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

colors = yatm_core.list_concat({{"default", "Default"}}, colors)

for _,pair in ipairs(colors) do
  local color_basename = pair[1]
  local color_name = pair[2]

  local node_name = "yatm_brewery:aging_barrel_wood_" .. color_basename
  minetest.register_node(node_name, {
    description = "Aging Barrel (Wood / " .. color_name .. ")",

    groups = {
      aging_barrel = 1,
      cracky = 1,
      fluid_interface_in = 1,
      fluid_interface_out = 1,
    },

    sounds = default.node_sound_wood_defaults(),
    tiles = {
      "yatm_barrel_wood_brewing_" .. color_basename .. "_top.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_bottom.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
    },

    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = barrel_nodebox,

    dye_color = color_basename,

    on_construct = barrel_on_construct,
    on_destruct = barrel_on_destruct,
    on_timer = barrel_on_timer,

    fluid_interface = barrel_fluid_interface,
    item_interface = barrel_item_interface,

    on_metadata_inventory_move = on_metadata_inventory_move,
    on_metadata_inventory_put = on_metadata_inventory_put,
    on_metadata_inventory_take = on_metadata_inventory_take,

    refresh_infotext = barrel_refresh_infotext,
  })
end
