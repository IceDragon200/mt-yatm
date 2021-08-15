--
-- The AgingRegistry contains recipes for an aging barrel
--
local table_bury = assert(foundation.com.table_bury)

local AgingRegistry = foundation.com.Class:extends('yatm.brewery.AgingRegistry')
local ic = AgingRegistry.instance_class

-- @type ItemIngredient: {
--   name: String,
--   amount: Integer = 0,
--   metadata?: Table
-- }
-- @type FluidIngredient: {
--   name: String,
--   amount: Integer = 0
-- }
-- @type AgingRecipeDefinition: {
--   inputs: {
--     item: ItemIngredient,
--     fluid: FluidIngredient,
--   },
--   outputs: {
--     item?: ItemIngredient,
--     fluid: FluidIngredient,
--   },
--   duration: Float, -- in seconds
-- }
-- @type AgingRecipe: {
--   id: integer,
-- } extends AgingRecipeDefinition

-- @spec #initialize(): void
function ic:initialize()
  self.m_recipe_id = 0
  self.m_recipes = {}
  self.m_recipes_name_to_id = {}
  -- fluid => item => recipe_id
  self.m_recipes_index = {}
end

-- @spec #register_aging_recipe(name: String, AgingRecipeDefinition): AgingRecipeDefinition
function ic:register_aging_recipe(name, recipe_def)
  assert(type(name) == "string", "expected name")
  assert(type(recipe_def) == "table", "expected recipe defintiion to be a table")
  assert(type(recipe_def.inputs) == "table", "expected inputs")
  assert(type(recipe_def.inputs.item) == "table", "expected inputs item")
  assert(type(recipe_def.inputs.fluid) == "table", "expected inputs fluid")
  assert(type(recipe_def.outputs) == "table", "expected outputs")
  assert(type(recipe_def.outputs.fluid) == "table", "expected outputs fluid")
  assert(type(recipe_def.duration) == "number", "expected duration")
  assert(recipe_def.duration >= 0, "expected duration to be greater than or equal to zero")

  self.m_recipe_id = self.m_recipe_id + 1
  local recipe_id = self.m_recipe_id

  recipe_def.id = recipe_id
  recipe_def.name = name

  self.m_recipes[recipe_id] = recipe_def
  self.m_recipes_name_to_id[recipe_def.name] = recipe_id

  table_bury(self.m_recipes_index, {
    recipe_def.inputs.fluid.name,
    recipe_def.inputs.item.name
  }, recipe_id)

  return recipe_def
end

-- Retrieve a recipe by given inputs, note that this function will not check
-- the item and fluid amounts in the input.
--
-- @spec #get_aging_recipe_by_inputs_indifferent(RecipeInputs): AgingRecipe | nil
function ic:get_aging_recipe_by_inputs_indifferent(inputs)
  assert(type(inputs) == "table", "expected inputs as table")

  if inputs.fluid and inputs.item then
    local fluid_name = inputs.fluid.name

    local items = self.m_recipes_index[fluid_name]
    if items then
      local item_name = inputs.item:get_name()

      if item_name then
        local recipe_id = items[item_name]
        if recipe_id then
          return self.m_recipes[recipe_id]
        end
      end
    end
  end

  return nil
end

-- Retrieve a recipe by given inputs, note that this function will check
-- the input amounts and may return nil if the amounts are insufficient
--
-- @spec #get_aging_recipe_by_inputs(RecipeInputs): AgingRecipe | nil
function ic:get_aging_recipe_by_inputs(inputs)
  local recipe = self:get_aging_recipe_indifferent(inputs)

  if recipe then
    if recipe.inputs.fluid.amount <= inputs.fluid.amount then
      if recipe.inputs.item.amount <= inputs.item:get_count() then
        return recipe
      end
    end
  end

  return nil
end

-- Retrieve an aging recipe by its id if it exists
--
-- @spec get_aging_recipe(recipe_id: Integer): AgingRecipe | nil
function ic:get_aging_recipe(recipe_id)
  return self.m_recipes[recipe_id]
end

-- Retrieve an aging recipe by its mod given name, useful since the recipe_id
-- may be unstable between replays.
--
-- @spec #get_aging_recipe_by_name(name: String): AgingRecipe | nil
function ic:get_aging_recipe_by_name(name)
  local recipe_id = self.m_recipes_name_to_id[name]

  if recipe_id then
    return self.m_recipes[recipe_id]
  end

  return nil
end

yatm_brewery.AgingRegistry = AgingRegistry
