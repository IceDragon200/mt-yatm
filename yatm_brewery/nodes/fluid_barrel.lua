--
-- FluidBarrels as their name states contain fluids.
-- Unlike the brewing barrel used to age booze.
--
local mod = yatm_brewery
local Directions = assert(foundation.com.Directions)
local list_concat = assert(foundation.com.list_concat)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)

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

local BARREL_CAPACITY = 36000 -- 36 buckets
local BARREL_DRAIN_BANDWIDTH = BARREL_CAPACITY

local function barrel_on_construct(pos)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

local function barrel_on_destruct(pos)
  --
end

local function barrel_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local stack = FluidTanks.get_fluid(pos, Directions.D_NONE)
  if stack and stack.amount > 0 then
    meta:set_string("infotext", "Barrel: " .. stack.name .. " " .. stack.amount .. " / " .. BARREL_CAPACITY)
  else
    meta:set_string("infotext", "Barrel: Empty")
  end
end

local barrel_fluid_interface = FluidInterface.new_simple("tank", BARREL_CAPACITY)

function barrel_fluid_interface:on_fluid_changed(pos, dir, _fluid_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

for _,row in ipairs(yatm.colors_with_default) do
  local color_basename = row.name
  local color_name = row.description

  minetest.register_node("yatm_brewery:fluid_barrel_wood_" .. color_basename, {
    codex_entry_id = "yatm_brewery:fluid_barrel_wood",

    basename = "yatm_brewery:fluid_barrel_wood",
    base_description = mod.S("Fluid Barrel (Wood)"),

    description = mod.S("Fluid Barrel (Wood / " .. color_name .. ")"),

    groups = {
      fluid_barrel = 1,
      wood_fluid_barrel = 1,
      choppy = 2,
      fluid_interface_in = 1,
      fluid_interface_out = 1,
    },
    sounds = yatm.node_sounds:build("wood"),
    tiles = {
      "yatm_barrel_wood_fluid_" .. color_basename .. "_top.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
    },
    use_texture_alpha = "opaque",

    paramtype = "none",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = barrel_nodebox,

    dye_color = color_basename,

    stack_max = 1,

    on_construct = barrel_on_construct,
    on_destruct = barrel_on_destruct,

    fluid_interface = barrel_fluid_interface,

    refresh_infotext = barrel_refresh_infotext,
  })

  minetest.register_node("yatm_brewery:fluid_barrel_metal_" .. color_basename, {
    codex_entry_id = "yatm_brewery:fluid_barrel_metal",

    basename = "yatm_brewery:fluid_barrel_metal",
    base_description = mod.S("Fluid Barrel (Metal)"),

    description = mod.S("Fluid Barrel (Metal / " .. color_name .. ")"),

    groups = {
      fluid_barrel = 1,
      metal_fluid_barrel = 1,
      cracky = 1,
      fluid_interface_in = 1,
      fluid_interface_out = 1,
    },
    sounds = yatm.node_sounds:build("metal"),
    tiles = {
      "yatm_barrel_metal_fluid_" .. color_basename .. "_top.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
    },
    use_texture_alpha = "opaque",

    paramtype = "none",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = barrel_nodebox,

    dye_color = color_basename,

    stack_max = 1,

    on_construct = barrel_on_construct,
    on_destruct = barrel_on_destruct,

    fluid_interface = barrel_fluid_interface,

    refresh_infotext = barrel_refresh_infotext,
  })
end
