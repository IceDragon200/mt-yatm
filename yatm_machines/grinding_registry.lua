--[[

  The GrindingRegistry contains recipes for the grinders

]]
local GrindingRegistry = yatm_core.Class:extends()
local ic = GrindingRegistry.instance_class

function ic:initialize()
  ic._super.initialize(self)
  self.g_recipe_id = 0
  self.recipes = {}
end

--
-- @spec register_grinding_recipe(String, ItemStack, {ItemStack}, Number) :: self
--
function ic:register_grinding_recipe(name, input_item_stack, result_item_stacks, duration)
  assert(name, "requires a name")
  assert(input_item_stack, "requires an input stack")
  assert(result_item_stacks, "requires a result list")
  assert(duration, "requires a duration")

  local item_name = input_item_stack:get_name()

  self.g_recipe_id = self.g_recipe_id + 1
  local id = self.g_recipe_id

  self.recipes[item_name] = {
    id = id,
    name = name,
    input_item_stack = input_item_stack,
    result_item_stacks = result_item_stacks,
    duration = duration
  }
  return self
end

function ic:find_grinding_recipe(item_stack)
  if item_stack then
    return self.recipes[item_stack:get_name()]
  end
  return nil
end

yatm_machines.GrindingRegistry = GrindingRegistry
