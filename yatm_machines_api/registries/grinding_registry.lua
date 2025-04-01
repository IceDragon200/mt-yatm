--[[

  The GrindingRegistry contains recipes for the grinders

]]
--- @namespace yatm_machines_api

--- @class GrindingRegistry
local GrindingRegistry = foundation.com.Class:extends("yatm_machines.GrindingRegistry")
do
  local ic = GrindingRegistry.instance_class

  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)
    self.g_recipe_id = 0
    self.m_recipes = {}
    self.m_item_to_recipe_id = {}
  end

  ---
  --- @spec register_grinding_recipe(
  ---   name: String,
  ---   input_item_stack: ItemStack,
  ---   output_item_stack: ItemStack[],
  ---   duration: Number
  --- ): self
  ---
  function ic:register_grinding_recipe(name, input_item_stack, output_item_stacks, duration)
    assert(name, "requires a name")
    assert(input_item_stack, "requires an input stack")
    assert(output_item_stacks, "requires a result list")
    assert(duration, "requires a duration")

    local item_name = input_item_stack:get_name()

    self.g_recipe_id = self.g_recipe_id + 1
    local recipe_id = self.g_recipe_id

    local recipe = {
      id = recipe_id,
      name = name,
      input_item_stack = input_item_stack,
      output_item_stacks = output_item_stacks,
      duration = duration
    }

    self.m_recipes[recipe_id] = recipe

    self.m_item_to_recipe_id[recipe.input_item_stack:get_name()] = recipe_id

    return self
  end

  --- @spec #find_grinding_recipe(ItemStack): GrindingRecipe
  function ic:find_grinding_recipe(input_item_stack)
    if input_item_stack:is_empty() then
      return nil, "input is empty"
    end
    local recipe_id = self.m_item_to_recipe_id[input_item_stack:get_name()]
    if recipe_id then
      local recipe = self.m_recipes[recipe_id]

      if recipe.input_item_stack:get_count() <= input_item_stack:get_count() then
        return recipe
      end
    end
    return nil, "no matching recipe"
  end
end

yatm_machines_api.GrindingRegistry = GrindingRegistry
