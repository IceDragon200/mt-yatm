--
-- The pressing registry contains recipes for the mechanical press.
--
local PressingRegistry = foundation.com.Class:extends('yatm.brewery.PressingRegistry')
local ic = PressingRegistry.instance_class

--
--
--
function ic:initialize()
  self.m_recipe_id = 0
  self.m_recipes = {}
  self.m_recipes_name_to_id = {}
end

-- @spec #register_pressing_recipe(name: String, PressingRecipeDefinition): PressingRecipe
function ic:register_pressing_recipe(name, recipe_def)
  self.m_recipe_id = self.m_recipe_id + 1
  local recipe_id = self.m_recipe_id

  recipe_def.id = recipe_id
  recipe_def.name = name

  self.m_recipes[recipe_id] = recipe_def
  self.m_recipes_name_to_id[recipe_def.name] = recipe_id

  return recipe_def
end

-- Retrieve a pressing recipe by its id if it exists
--
-- @spec #get_pressing_recipe(recipe_id: Integer): AgingRecipe | nil
function ic:get_pressing_recipe(recipe_id)
  return self.m_recipes[recipe_id]
end

-- @spec #get_pressing_recipe_by_name(name: String): BrewingRecipe | nil
function ic:get_pressing_recipe_by_name(name)
  local recipe_id = self.m_recipes_name_to_id[name]

  if recipe_id then
    return self.m_recipes[recipe_id]
  end

  return nil
end

yatm_brewery.PressingRegistry = PressingRegistry
