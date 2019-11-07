local SawingRegistry = yatm_core.Class:extends("SawingRegistry")
local ic = SawingRegistry.instance_class

function ic:initialize()
  ic._super.initialize(self)

  self.g_recipe_id = 0
  self.m_recipes = {}

  self.m_item_to_recipe_id = {}
end

function ic:register_sawing_recipe(name, input_item_stack, output_item_stacks, sawdust_rate)
  self.g_recipe_id = self.g_recipe_id + 1
  local recipe_id = self.g_recipe_id

  local recipe = {
    id = recipe_id,
    input_item_stack = input_item_stack,
    output_item_stacks = output_item_stacks,
    sawdust_rate = sawdust_rate, -- how much sawdust is produced from this action, can be less than 1, it will build up in the sawmill instead.
  }

  self.m_recipes[recipe_id] = recipe
  self.m_item_to_recipe_id[recipe.input_item_stack:get_name()] = recipe_id

  return recipe
end

function ic:get_sawing_recipe(recipe_id)
  return self.m_recipes[recipe_id]
end

function ic:find_sawing_recipe(input_item_stack)
  if input_item_stack:is_empty() then
    return nil, "input is empty"
  end

  local recipe_id = self.m_item_to_recipe_id[input_item_stack:get_name()]
  local recipe = self.m_recipes[recipe_id]

  if recipe then
    if recipe.input_item_stack:get_count() <= input_item_stack:get_count() then
      return recipe
    end
  end

  return nil, "no matching recipe"
end

yatm_woodcraft.SawingRegistry = SawingRegistry
