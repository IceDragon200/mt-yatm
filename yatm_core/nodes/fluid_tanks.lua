local fluid_tanks = {
  fluid_name_to_tank_name = {}
}

function fluid_tanks.get(pos, dir)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.fluids_interface then
      if nodedef.fluids_interface.get then
        return nodedef.fluids_interface.get(pos, dir, node)
      end
    end
  end
  return nil
end

function fluid_tanks.replace(pos, dir, fluid_name, amount, commit)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.fluids_interface then
      if nodedef.fluids_interface.replace then
        return nodedef.fluids_interface.replace(pos, dir, node, fluid_name, amount, commit)
      end
    end
  end
  return nil
end

function fluid_tanks.drain(pos, dir, fluid_name, amount, commit)
  if amount <= 0 then
    return nil
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.fluids_interface then
      if nodedef.fluids_interface.drain then
        return nodedef.fluids_interface.drain(pos, dir, node, fluid_name, amount, commit)
      end
    end
  end
  return nil
end

function fluid_tanks.fill(pos, dir, fluid_name, amount, commit)
  if amount <= 0 then
    return nil
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.fluids_interface then
      if nodedef.fluids_interface.fill then
        return nodedef.fluids_interface.fill(pos, dir, node, fluid_name, amount, commit)
      end
    end
  end
  return nil
end

function fluid_tanks.trigger_on_fluid_changed(pos, dir, node, stack, new_amount, capacity)
  assert(node, "expected a valid node")
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.fluids_interface then
      if nodedef.fluids_interface.on_fluid_changed then
        return nodedef.fluids_interface.on_fluid_changed(pos, dir, node, stack, new_amount, capacity)
      end
    end
  end
  return nil
end

local function get_fluid_tile(fluid)
  if fluid.tiles then
    return assert(fluid.tiles.source)
  else
    local name = assert(fluid.node.source, "expected a source " .. fluid.name)
    local node = assert(minetest.registered_nodes[name], "expected node to exist " .. name)
    return node.tiles[1]
  end
end

local function refresh_level(pos, dir, node, stack, amount, capacity)
  local meta = minetest.get_meta(pos)
  if stack and amount > 0 then
    local tank_name = fluid_tanks.fluid_name_to_tank_name[stack.name]
    assert(tank_name, "expected fluid tank for " .. dump(stack.name))
    local level = math.floor(63 * amount / capacity)
    if node.param2 ~= level then
      node.param2 = level
      node.name = tank_name
      minetest.swap_node(pos, node)
    end
    meta:set_string("infotext", "Tank: " .. stack.name .. " " .. amount .. " / " .. capacity)
  else
    node.name = "yatm_core:fluid_tank"
    node.param2 = 0
    minetest.swap_node(pos, node)
    meta:set_string("infotext", "Tank: Empty")
  end
end

local TANK_CAPACITY = 16000 -- 16 buckets
local TANK_DRAIN_BANDWIDTH = TANK_CAPACITY
local tank_fluids_interface = yatm_core.new_simple_fluids_interface("tank", TANK_CAPACITY)
tank_fluids_interface.on_fluid_changed = refresh_level
local old_fill = tank_fluids_interface.fill
function tank_fluids_interface.fill(pos, dir, node, fluid_name, amount, commit)
  local stack = old_fill(pos, dir, node, fluid_name, amount, commit)
  if stack and stack.amount > 0 then
    --print("FILL", pos.x, pos.y, pos.z, node.name, stack.name, stack.amount)
    return stack
  else
    local new_pos = vector.add(pos, yatm_core.V3_UP)
    local new_node = minetest.get_node(new_pos)
    if minetest.get_item_group(new_node.name, "fluid_tank") > 0 then
      return fluid_tanks.fill(new_pos, dir, fluid_name, amount, commit)
    else
      return nil
    end
  end
end

minetest.register_node("yatm_core:fluid_tank", {
  description = "Fluid Tank",
  groups = {
    cracky = 1,
    fluid_tank = 1,
  },
  tiles = {
    "yatm_fluid_tank_top.png",
    "yatm_fluid_tank_side.png",
    "yatm_fluid_tank_top.png",
  },
  special_tiles = {
  },
  drawtype = "glasslike_framed",
  paramtype = "light",
  paramtype2 = "glasslikeliquidlevel",
  is_ground_content = false,
  sunlight_propogates = true,
  sounds = default.node_sound_glass_defaults(),
  fluids_interface = tank_fluids_interface,
})

yatm_core.measurable.reduce_members_of(yatm_core.fluids, "fluid", 0, function (name, fluid, acc)
  local fluid_tank_def = {
    description = "Fluid Tank (" .. (fluid.description or name) .. ")",
    groups = {
      cracky = 1,
      fluid_tank = 1,
      filled_fluid_tank = 1,
      not_in_creative_inventory = 1,
    },
    tiles = {
      "yatm_fluid_tank_top.png",
      "yatm_fluid_tank_side.png",
      "yatm_fluid_tank_top.png",
    },
    special_tiles = {
      get_fluid_tile(fluid),
    },
    drawtype = "glasslike_framed",
    paramtype = "light",
    paramtype2 = "glasslikeliquidlevel",
    is_ground_content = false,
    sunlight_propogates = true,
    sounds = default.node_sound_glass_defaults(),
    after_place_node = function (pos)
      fluid_tanks.replace(pos, yatm_core.D_NONE, fluid.name, TANK_CAPACITY, true)
    end,
    fluids_interface = tank_fluids_interface,
  }

  -- sunlight_propagates = true,
  -- light_source = default.LIGHT_MAX,
  local fluid_tank_name = "yatm_core:fluid_tank_" .. fluid.safe_name
  minetest.register_node(fluid_tank_name, fluid_tank_def)
  fluid_tanks.fluid_name_to_tank_name[fluid.name] = fluid_tank_name
  return true, acc + 1
end)

minetest.register_abm({
  label = "yatm_core:fluid_tank_sync",
  nodenames = {
    "group:filled_fluid_tank",
  },
  interval = 1,
  chance = 1,
  action = function (pos, node)
    local stack = fluid_tanks.drain(pos, yatm_core.V3_DOWN, "*", TANK_DRAIN_BANDWIDTH, false)
    if stack and stack.amount > 0 then
      local below_pos = vector.add(pos, yatm_core.V3_DOWN)
      local filled_stack = fluid_tanks.fill(below_pos, yatm_core.D_NONE, stack.name, stack.amount, true)
      if filled_stack then
        fluid_tanks.drain(pos, yatm_core.V3_DOWN, stack.name, filled_stack.amount, true)
      end
    end
  end
})

yatm_core.fluid_tanks = fluid_tanks
