--[[

  This is just the empty tank.

]]
local mod = assert(yatm_fluids)
local Directions = assert(foundation.com.Directions)
local table_copy = assert(foundation.com.table_copy)
local FluidStack = assert(yatm_fluids.FluidStack)
local FluidTanks = assert(yatm_fluids.FluidTanks)
local FluidMeta = assert(yatm_fluids.FluidMeta)
local fluid_tank_sync_service = assert(yatm.fluids.fluid_tank_sync_service)

local fluid_tank_tiles = {
  "yatm_fluid_tank_edge.png",
  "yatm_fluid_tank_detail.png",
}

minetest.register_node("yatm_fluids:fluid_tank", {
  basename = "yatm_fluids:fluid_tank",

  description = mod.S("Fluid Tank"),

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    fluid_tank = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
  },

  connects_to = {"group:fluid_tank"},

  tiles = fluid_tank_tiles,

  special_tiles = {
  },
  use_texture_alpha = "clip",

  drawtype = "glasslike_framed",
  paramtype = "light",
  paramtype2 = "glasslikeliquidlevel",

  is_ground_content = false,
  sunlight_propagates = true,
  sounds = yatm.node_sounds:build("glass"),

  refresh_infotext = yatm_fluids.fluid_tank_refresh_infotext,

  on_construct = yatm_fluids.fluid_tank_on_construct,
  after_destruct = yatm_fluids.fluid_tank_after_destruct,
  after_place_node = function (pos)
    FluidTanks.replace_fluid(pos, Directions.D_NONE, FluidStack.new_empty(), true)
  end,

  fluid_interface = assert(yatm_fluids.fluid_tank_fluid_interface),

  on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
    return itemstack
  end,
})

local steel_tank_fluid_interface = table_copy(yatm_fluids.fluid_tank_fluid_interface)

steel_tank_fluid_interface._private.capacity = 32000

function steel_tank_fluid_interface:on_fluid_changed(pos, dir, new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
  fluid_tank_sync_service:mark_for_update(pos)
end

function steel_fluid_tank_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)
  local fluid_interface = FluidTanks.get_fluid_interface(pos)

  local fluid_stack = FluidMeta.get_fluid_stack(meta, "tank")
  if FluidStack.is_empty(fluid_stack) then
    meta:set_string("infotext", "Tank <EMPTY>")
  else
    local capacity = fluid_interface:get_capacity(pos, 0)
    meta:set_string("infotext", "Tank <" .. FluidStack.to_string(fluid_stack, capacity) .. ">")
  end
end

minetest.register_node("yatm_fluids:steel_fluid_tank", {
  basename = "yatm_fluids:steel_fluid_tank",

  description = mod.S("Steel Fluid Tank"),

  groups = {
    cracky = nokore.dig_class("copper"),
    --
    fluid_tank = 1,
    filled_fluid_tank = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
  },

  tiles = {
    "yatm_steel_fluid_tank_top.png",
    "yatm_steel_fluid_tank_bottom.png",
    "yatm_steel_fluid_tank_side.png",
    "yatm_steel_fluid_tank_side.png",
    "yatm_steel_fluid_tank_side.png",
    "yatm_steel_fluid_tank_side.png",
  },
  use_texture_alpha = "opaque",

  paramtype = "light",
  paramtype2 = "facedir",
  place_param2 = 0,

  is_ground_content = false,
  sunlight_propagates = true,
  sounds = yatm.node_sounds:build("glass"),

  refresh_infotext = steel_fluid_tank_refresh_infotext,

  on_construct = yatm_fluids.fluid_tank_on_construct,
  after_destruct = yatm_fluids.fluid_tank_after_destruct,
  after_place_node = function (pos)
    FluidTanks.replace_fluid(pos, Directions.D_NONE, FluidStack.new_empty(), true)
  end,

  fluid_interface = steel_tank_fluid_interface,

  connects_to = {"group:fluid_tank"},
})
