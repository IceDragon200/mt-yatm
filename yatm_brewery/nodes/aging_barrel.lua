--
-- The Aging or fermenting barrel is a fluid barrel responsible for transforming fluids
-- into other fluids normally with a catalyst item.
-- Aging recipes tend to be fairly slow to process, but work on large quantities of fluids.
--
local Vector3 = assert(foundation.com.Vector3)
local fspec = assert(foundation.com.formspec.api)
local fluid_fspec = assert(yatm.fluids.formspec)
local list_concat = assert(foundation.com.list_concat)
local Directions = assert(foundation.com.Directions)
local aging_registry = assert(yatm.brewing.aging_registry)
local ItemInterface = assert(yatm.items.ItemInterface)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local player_service = assert(nokore.player_service)

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
      nodedef.fluid_interface:get_capacity(pos, 0)
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

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  -- local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, 8, 4, { bg = "wood" }, function (loc, rect)
    if loc == "main_body" then
      local fluid_stack = FluidMeta.get_fluid_stack(meta, "tank")

      return fluid_fspec.render_fluid_stack(rect.x, rect.y, 1, cis(4), fluid_stack, BARREL_CAPACITY)
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_brewery:aging_barrel:"..Vector3.to_string(pos)
end

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, user)
  local state = {
    pos = pos,
  }
  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
      timers = {
        -- steam turbines have a fluid tank, so their formspecs need to be routinely updated
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
end

-- Normally the side and lid of the barrel is dyed, this is mostly for identification.
-- By default only the white and default (i.e. no dye) variant is available.
for _,row in ipairs(yatm.colors_with_default) do
  local color_basename = row.name
  local color_name = row.description

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
    use_texture_alpha = "opaque",

    paramtype = "none",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = barrel_nodebox,

    dye_color = color_basename,

    on_rightclick = on_rightclick,

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
