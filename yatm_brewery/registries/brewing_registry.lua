--
-- The BrewingRegistry provides retrieval and registration services
-- for 'brewing' recipes, these are recipes used by the kettle.
-- The recipes themselves can be quite complicated.
--
local table_bury = assert(foundation.com.table_bury)

local BrewingRegistry = foundation.com.Class:extends('yatm.brewery.BrewingRegistry')
local ic = BrewingRegistry.instance_class

-- @type RecipeID: integer
--
-- @type ItemIngredient: {
--   name: String,
--   amount: Integer = 0,
--   metadata: Table
-- }
--
-- @type FluidIngredient: {
--   name: String,
--   amount: Integer = 0
-- }
--
-- @type BrewingRecipeDefinition: {
--   inputs: {
--     item: ItemIngredient,
--     fluid: FluidIngredient,
--   },
--   outputs: {
--     item: ItemIngredient,
--     fluid: FluidIngredient
--   },
--   duration: Float, -- time in seconds
--   heat_rate: Integer, -- heat per second, how much heat is consumed while brewing per second.
-- }
--
-- @type BrewingRecipe: {
--   id: RecipeID,
--   name: String,
-- } extends BrewingRecipeDefinition
--
-- @type Recipes: { [RecipeID]: BrewingRecipeDefinition }
--
-- @type RecipesIndex: {
--   [fluid_name: String]: {
--     [item_name: String]: RecipeID
--   }
-- }
--
-- @type output_fluid_to_recipes: { [fluid_name: String] = { [RecipeID] = true } }
--
-- @type output_item_to_recipes: { [item_name: String] = { [RecipeID] = true } }
--

function ic:initialize()
  self.m_recipe_id = 0
  self.m_recipes = {}
  self.m_recipes_name_to_id = {}
  self.m_recipes_index = {}
  self.m_output_fluid_to_recipes = {}
  self.m_output_item_to_recipes = {}
end

--
--
-- @mutative
-- @spec #register_brewing_recipe(name: String, RecipeDefinition): BrewingRecipe
function ic:register_brewing_recipe(name, recipe_def)
  assert(type(name) == "string", "expected name")
  assert(type(recipe_def) == "table", "expected recipe definition to be a table")
  assert(recipe_def.inputs, "expected an input")
  assert(recipe_def.outputs, "expected an output")
  assert(recipe_def.duration, "expected a duration")
  assert(recipe_def.heat_rate, "expected a heat rate")

  self.m_recipe_id = self.m_recipe_id + 1
  local recipe_id = self.m_recipe_id
  recipe_def.id = recipe_id
  recipe_def.name = name
  self.m_recipes[recipe_id] = recipe_def

  self.m_recipes_name_to_id[recipe_def.name] = recipe_def.id

  -- index by fluid name and then by item name
  table_bury(self.m_recipes_index,
             {recipe_def.input.fluid.name, recipe_def.input.item.name},
             recipe_id)

  if recipe_def.outputs.fluid then
    table_bury(self.m_output_fluid_to_recipes, {recipe_def.output.fluid.name, recipe_id}, true)
  end

  if recipe_def.outputs.item then
    table_bury(self.m_output_item_to_recipes, {recipe_def.output.item.name, recipe_id}, true)
  end

  return self
end

-- @spec #get_brewing_recipe_by_inputs_indifferent(RecipeInput): BrewingRecipe | nil
function ic:get_brewing_recipe_by_inputs_indifferent(inputs)
  if inputs.fluid and inputs.fluid.amount > 0 and inputs.item and not inputs.item:is_empty() then
    if inputs.fluid.name then
      local item_name_to_recipe_id = self.m_recipes_index[inputs.fluid.name]

      if item_name_to_recipe_id then
        local recipe_id = item_name_to_recipe_id[inputs.item:get_name()]

        if recipe_id then
          return self.m_recipes[recipe_id]
        end
      end
    end
  end

  return nil
end

-- @spec #get_brewing_recipe_by_inputs(RecipeInput): BrewingRecipe | nil
function ic:get_brewing_recipe_by_inputs(inputs)
  local recipe = self:get_brewing_recipe_by_inputs_indifferent(inputs)
  if recipe then
    -- check if recipe amounts have been met
    if recipe.input.fluid.amount <= input.fluid.amount and
       recipe.input.item.amount <= input.item:get_count() then
      return recipe
    end
  end

  return nil
end

-- Retrieve a brewing recipe by its id if it exists
--
-- @spec get_brewing_recipe(recipe_id: Integer): AgingRecipe | nil
function ic:get_brewing_recipe(recipe_id)
  return self.m_recipes[recipe_id]
end

-- @spec #get_brewing_recipe_by_name(name: String): BrewingRecipe | nil
function ic:get_brewing_recipe_by_name(name)
  local recipe_id = self.m_recipes_name_to_id[name]

  if recipe_id then
    return self.m_recipes[recipe_id]
  end

  return nil
end

yatm_brewery.BrewingRegistry = BrewingRegistry
