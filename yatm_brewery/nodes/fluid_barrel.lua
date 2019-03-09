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

local BARREL_CAPACITY = 36000 -- 4 buckets
local BARREL_DRAIN_BANDWIDTH = BARREL_CAPACITY

local function barrel_on_construct(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.refresh_infotext then
    nodedef.refresh_infotext(pos, yatm_core.D_NONE, node, nil, 0, 0)
  end
end

local function barrel_on_destruct(pos)
end

local function barrel_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local stack = yatm_core.fluid_tanks.get(pos, yatm_core.D_NONE)
  if stack and stack.amount > 0 then
    meta:set_string("infotext", "Barrel: " .. stack.name .. " " .. stack.amount .. " / " .. BARREL_CAPACITY)
  else
    meta:set_string("infotext", "Barrel: Empty")
  end
end

local barrel_fluids_interface = yatm_core.new_simple_fluids_interface("tank", BARREL_CAPACITY)

function barrel_fluids_interface.on_fluid_changed(pos, dir, node, _stack, _amount, _capacity)
  local nodedef = minetest.registered_nodes[node.name]
  nodedef.refresh_infotext(pos)
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

  minetest.register_node("yatm_brewery:fluid_barrel_wood_" .. color_basename, {
    description = "Fluid Barrel (Wood / " .. color_name .. ")",
    groups = {fluid_barrel = 1, cracky = 2},
    sounds = default.node_sound_wood_defaults(),
    tiles = {
      "yatm_barrel_wood_fluid_" .. color_basename .. "_top.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
    },

    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = barrel_nodebox,

    dye_color = color_basename,

    on_construct = barrel_on_construct,
    on_destruct = barrel_on_destruct,

    fluids_interface = barrel_fluids_interface,

    refresh_infotext = barrel_refresh_infotext,
  })

  minetest.register_node("yatm_brewery:fluid_barrel_metal_" .. color_basename, {
    description = "Fluid Barrel (Metal / " .. color_name .. ")",
    groups = {fluid_barrel = 1, cracky = 1},
    sounds = default.node_sound_metal_defaults(),
    tiles = {
      "yatm_barrel_metal_fluid_" .. color_basename .. "_top.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
    },

    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = barrel_nodebox,

    dye_color = color_basename,

    on_construct = barrel_on_construct,
    on_destruct = barrel_on_destruct,

    fluids_interface = barrel_fluids_interface,

    refresh_infotext = barrel_refresh_infotext,
  })
end
