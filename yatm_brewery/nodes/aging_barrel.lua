--
-- The Aging or fermenting barrel is a fluid barrel responsible for transforming fluids
-- into other fluids normally with a catalyst item.
-- Aging recipes tend to be fairly slow to process, but work on large quantities of fluids.
--
local list_concat = assert(foundation.com.list_concat)
local Directions = assert(foundation.com.Directions)
local aging_registry = assert(yatm.brewing.aging_registry)
local ItemInterface = assert(yatm.items.ItemInterface)
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

local function barrel_get_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  -- TODO: display fluid bar
  --       as of this writing, YATM doesn't ever show it's fluids actually...

  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "wood") ..
    "list[nodemeta:" .. spos .. ";culture_slot;1,1;1,1]" ..
    "list[current_player;main;1,4.85;8,1;]" ..
    "list[current_player;main;1,6.08;8,3;8]"

  return formspec
end

local function barrel_on_timer(pos, dt)
  -- TODO: process the aging recipe here
  return true
end

local function barrel_on_construct(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()
  -- accepts one culture or catalyst item
  inv:set_size("culture_slot", 1)

  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

local function barrel_on_destruct(pos)
  -- Barrel exit stage left
end

local function barrel_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  node = node or minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  local stack = FluidTanks.get_fluid(pos, Directions.D_NONE)

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
  minetest.get_node_timer(pos):start(1.0)
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
  minetest.get_node_timer(pos):start(1.0)
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
  minetest.get_node_timer(pos):start(1.0)
end

-- Normally the side and lid of the barrel is dyed, this is mostly for identification.
-- By default only the white and default (i.e. no dye) variant is available.
local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

-- Add the 'default' case for barrels, barrels can either be dyed or not.
colors = list_concat({{"default", "Default"}}, colors)

for _,pair in ipairs(colors) do
  local color_basename = pair[1]
  local color_name = pair[2]

  local node_name = "yatm_brewery:aging_barrel_wood_" .. color_basename
  minetest.register_node(node_name, {
    basename = "yatm_brewery:aging_barrel_wood",
    base_description = "Aging Barrel (Wood)",

    description = "Aging Barrel (Wood / " .. color_name .. ")",

    groups = {
      aging_barrel = 1,
      cracky = 1,
      fluid_interface_in = 1,
      fluid_interface_out = 1,
    },

    sounds = yatm.node_sounds:build("wood"),

    tiles = {
      "yatm_barrel_wood_brewing_" .. color_basename .. "_top.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_bottom.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_brewing_" .. color_basename .. "_side.png",
    },
    use_texture_alpha = false,

    paramtype = "none",
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
