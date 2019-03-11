local FluidStack = assert(yatm_core.FluidStack)

local function get_fluid_tile(fluid)
  if fluid.tiles then
    return assert(fluid.tiles.source)
  else
    local name = assert(fluid.node.source, "expected a source " .. fluid.name)
    local node = assert(minetest.registered_nodes[name], "expected node to exist " .. name)
    return node.tiles[1]
  end
end

local tank_fluids_interface = yatm_core.new_simple_fluids_interface("tank", 16000)
local TANK_DRAIN_BANDWIDTH = assert(tank_fluids_interface.capacity)

function tank_fluids_interface:on_fluid_changed(pos, dir, new_stack)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)
  if new_stack and new_stack.amount > 0 then
    local tank_name = yatm_core.fluid_tanks.fluid_name_to_tank_name[new_stack.name]
    assert(tank_name, "expected fluid tank for " .. dump(new_stack.name))
    local level = math.floor(63 * new_stack.amount / self.capacity)
    if node.param2 ~= level then
      node.param2 = level
      node.name = tank_name
      minetest.swap_node(pos, node)
    end
    meta:set_string("infotext", "Tank: " .. yatm_core.FluidStack.to_string(new_stack, self.capacity))
  else
    node.name = "yatm_core:fluid_tank"
    node.param2 = 0
    minetest.swap_node(pos, node)
    meta:set_string("infotext", "Tank: Empty")
  end
end

local old_fill = tank_fluids_interface.fill

function tank_fluids_interface:fill(pos, dir, fluid_stack, commit)
  local used_stack = old_fill(self, pos, dir, fluid_stack, commit)

  local left_stack = nil
  if used_stack then
    left_stack = FluidStack.dec_amount(fluid_stack, used_stack.amount)
  else
    left_stack = fluid_stack
  end

  if left_stack.amount > 0 then
    local new_pos = vector.add(pos, yatm_core.V3_UP)
    local new_node = minetest.get_node(new_pos)
    if minetest.get_item_group(new_node.name, "fluid_tank") > 0 then
      local used_stack2 = yatm_core.fluid_tanks.fill(new_pos, dir, left_stack, commit)
      used_stack = FluidStack.merge(used_stack, used_stack2)
    end
  end
  return used_stack
end

local fluid_tank_tiles = {
  "yatm_fluid_tank_edge.png",
  "yatm_fluid_tank_detail.png",
}

minetest.register_node("yatm_core:fluid_tank", {
  description = "Fluid Tank",
  groups = {
    cracky = 1,
    fluid_tank = 1,
  },
  tiles = fluid_tank_tiles,
  special_tiles = {
  },
  drawtype = "glasslike_framed",
  paramtype = "light",
  paramtype2 = "glasslikeliquidlevel",
  is_ground_content = false,
  sunlight_propogates = true,
  sounds = default.node_sound_glass_defaults(),
  after_place_node = function (pos)
    yatm_core.fluid_tanks.replace(pos, yatm_core.D_NONE,
      FluidStack.new(nil, 0), true)
  end,
  fluids_interface = tank_fluids_interface,
  connects_to = {"group:fluid_tank"},
})

function yatm_core.fluid_tanks.register_fluid_tank(name, fluiddef)
  local fluid_tank_def = {
    description = "Fluid Tank (" .. (fluiddef.description or name) .. ")",
    groups = {
      cracky = 1,
      fluid_tank = 1,
      filled_fluid_tank = 1,
      not_in_creative_inventory = 1,
    },
    drop = "yatm_core:fluid_tank",
    tiles = fluid_tank_tiles,
    special_tiles = {
      get_fluid_tile(fluiddef),
    },
    drawtype = "glasslike_framed",
    paramtype = "light",
    paramtype2 = "glasslikeliquidlevel",
    is_ground_content = false,
    sunlight_propogates = true,
    sounds = default.node_sound_glass_defaults(),
    after_place_node = function (pos, _placer, _itemstack, _pointed_thing)
      yatm_core.fluid_tanks.replace(pos, yatm_core.D_NONE,
        FluidStack.new(fluiddef.name, tank_fluids_interface.capacity), true)
    end,
    fluids_interface = tank_fluids_interface,
    connects_to = {"group:fluid_tank"},
  }

  -- sunlight_propagates = true,
  -- light_source = default.LIGHT_MAX,
  local fluid_tank_name = "yatm_core:fluid_tank_" .. assert(fluiddef.safe_name)
  minetest.register_node(fluid_tank_name, fluid_tank_def)
  yatm_core.fluid_tanks.fluid_name_to_tank_name[fluiddef.name] = fluid_tank_name
end

yatm_core.measurable.reduce_members_of(yatm_core.fluids, "fluid", 0, function (name, fluiddef, acc)
  yatm_core.fluid_tanks.register_fluid_tank(name, fluiddef)
  return true, acc + 1
end)

minetest.register_abm({
  label = "yatm_core:fluid_tank_sync",
  nodenames = {
    "group:filled_fluid_tank",
  },
  interval = 0,
  chance = 1,
  action = function (pos, node)
    local fluid_stack = yatm_core.fluid_tanks.drain(
      pos,
      yatm_core.V3_DOWN,
      FluidStack.new_wildcard(TANK_DRAIN_BANDWIDTH),
      false
    )
    if fluid_stack and fluid_stack.amount > 0 then
      local below_pos = vector.add(pos, yatm_core.V3_DOWN)
      local filled_stack = yatm_core.fluid_tanks.fill(below_pos, yatm_core.D_UP, fluid_stack, true)
      if filled_stack and filled_stack.amount > 0 then
        yatm_core.fluid_tanks.drain(pos, yatm_core.V3_DOWN, filled_stack, true)
      end
    end
  end
})
