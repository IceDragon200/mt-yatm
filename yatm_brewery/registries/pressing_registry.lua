--
-- The pressing registry contains recipes for the mechanical press.
--
local assertions = assert(foundation.com.assertions)
local list_map = assert(foundation.com.list_map)
local ItemIngredient = assert(yatm.recipe_component.ItemIngredient)

--- @namespace yatm_brewery

--- @class PressingRegistry
local PressingRegistry = foundation.com.Class:extends('yatm.brewery.PressingRegistry')
local ic = PressingRegistry.instance_class

--- @type PressingRecipeDefinition: {
---   input_items = {},
---   input_fluids = {},
--- }

---
---
--- @spec #initialize(): void
function ic:initialize()
  --- @member m_g_recipe_id: Integer
  self.m_g_recipe_id = 0

  --- @member m_recipes: {
  ---   [recipe_id: Integer]: PressingRecipe
  --- }
  self.m_recipes = {}

  --- @member m_recipes_name_to_id: {
  ---   [name: String]: Integer
  --- }
  self.m_recipes_name_to_id = {}
end

--- @spec #register_pressing_recipe(name: String, PressingRecipeDefinition): PressingRecipe
function ic:register_pressing_recipe(name, recipe_def)
  assertions.is_string(name, "expected a name for recipe")

  self.m_g_recipe_id = self.m_g_recipe_id + 1
  local recipe_id = self.m_g_recipe_id

  recipe_def.id = recipe_id
  recipe_def.name = name
  if recipe_def.input_items then
    recipe_def.input_items = list_map(recipe_def.input_items, function (item)
      return ItemIngredient:new(item)
    end)
  end

  if self.m_recipes_name_to_id[recipe_def.name] then
    error("pressing recipe name=" .. recipe_def.name .. " already exists")
  end

  self.m_recipes[recipe_id] = recipe_def
  self.m_recipes_name_to_id[recipe_def.name] = recipe_id

  return recipe_def
end

--- Retrieve a pressing recipe by its id if it exists, ids may change between runtime so this should
--- never be relied upon, instead use the recipe's name when possible.
---
--- @spec #get_pressing_recipe(recipe_id: Integer): PressingRecipe | nil
function ic:get_pressing_recipe(recipe_id)
  return self.m_recipes[recipe_id]
end

--- Retrieve a pressing recipe by its name.
---
--- @spec #get_pressing_recipe_by_name(name: String): PressingRecipe | nil
function ic:get_pressing_recipe_by_name(name)
  local recipe_id = self.m_recipes_name_to_id[name]

  if recipe_id then
    return self.m_recipes[recipe_id]
  end

  return nil
end

yatm_brewery.PressingRegistry = PressingRegistry
