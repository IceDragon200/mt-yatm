--
-- FluidInterface implementation used for fluid tanks
--
local FluidStack = assert(yatm_fluids.FluidStack)
local FluidInterface = assert(yatm_fluids.FluidInterface)
local FluidTanks = assert(yatm_fluids.FluidTanks)
local FluidRegistry = assert(yatm_fluids.FluidRegistry)

local fluid_tank_fluid_interface = FluidInterface.new_simple("tank", 16000)
fluid_tank_fluid_interface.bandwidth = assert(fluid_tank_fluid_interface.capacity)

function fluid_tank_fluid_interface:on_fluid_changed(pos, dir, new_stack)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)
  if new_stack and new_stack.amount > 0 then
    local tank_name = FluidRegistry.fluid_name_to_tank_name(new_stack.name)
    assert(tank_name, "expected fluid tank for " .. dump(new_stack.name))
    local level = math.floor(63 * new_stack.amount / self.capacity)
    if node.param2 ~= level then
      node.param2 = level
      node.name = tank_name
      minetest.swap_node(pos, node)
    end
    meta:set_string("infotext", "Tank <" .. FluidStack.to_string(new_stack, self.capacity) .. ">")
  else
    node.name = "yatm_fluids:fluid_tank"
    node.param2 = 0
    minetest.swap_node(pos, node)
    meta:set_string("infotext", "Tank <EMPTY>")
  end
end

local old_fill = fluid_tank_fluid_interface.fill

function fluid_tank_fluid_interface:fill(pos, dir, fluid_stack, commit)
  local used_stack = old_fill(self, pos, dir, fluid_stack, commit)

  local left_stack = nil
  if used_stack then
    left_stack = FluidStack.dec_amount(fluid_stack, used_stack.amount)
  else
    used_stack = FluidStack.new_empty()
    left_stack = fluid_stack
  end

  if left_stack.amount > 0 then
    local new_pos = vector.add(pos, yatm_core.V3_UP)
    local new_node = minetest.get_node(new_pos)
    if minetest.get_item_group(new_node.name, "fluid_tank") > 0 then
      local used_stack2 = FluidTanks.fill_fluid(new_pos, dir, left_stack, commit)
      used_stack = FluidStack.merge(used_stack, used_stack2)
    end
  end
  return used_stack
end

yatm_fluids.fluid_tank_fluid_interface = fluid_tank_fluid_interface
