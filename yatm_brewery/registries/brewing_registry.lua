--
-- The BrewingRegistry provides retrieval and registration services
-- for 'brewing' recipes, these are recipes used by the kettle.
-- The recipes themselves can be quite complicated.
--
local BrewingRegistry = yatm_core.Class:extends('yatm.brewery.BrewingRegistry')
local ic = BrewingRegistry.instance_class

-- @type item_def :: {
--   name :: string, amount :: integer = 0, metadata = table
-- }
-- @type fluid_def :: {
--   name :: string, amount :: integer = 0
-- }
-- @type RecipeDefinition :: {
--   inputs = {
--     item = item_def,
--     fluid = fluid_def,
--   },
--   outputs = {
--     item = item_def,
--     fluid = fluid_def
--   },
--   duration = float, -- time in seconds
--   heat_rate = integer, -- heat per second, how much heat is consumed while brewing per second.
-- }
--
-- @type recipe_id :: integer
-- @type recipes :: { [recipe_id] = RecipeDefinition }
-- @type recipes_index :: { [fluid_name :: string] = { [item_name :: string] = recipe_id }}
-- @type output_fluid_to_recipes :: { [fluid_name :: string] = { [recipe_id] = true } }
-- @type output_item_to_recipes :: { [item_name :: string] = { [recipe_id] = true } }
--

function ic:initialize()
  self.m_recipes = {}
  self.m_recipes_index = {}
  self.m_output_fluid_to_recipes = {}
  self.m_output_item_to_recipes = {}
  self.m_recipe_id = 0
end

--
--
-- @spec register_brewing_recipe(RecipeDefinition) :: void
function ic:register_brewing_recipe(recipe_def)
  assert(type(recipe_def) == "table", "expected recipe definition to be a table")
  assert(recipe_def.inputs, "expected an input")
  assert(recipe_def.outputs, "expected an output")
  assert(recipe_def.duration, "expected a duration")
  assert(recipe_def.heat_rate, "expected a heat rate")

  self.m_recipe_id = self.m_recipe_id + 1
  local recipe_id = self.m_recipe_id
  self.recipes[recipe_id] = recipe_def

  -- index by fluid name and then by item name
  yatm_core.table_bury(self.m_recipes_index,
                       {recipe_def.input.fluid.name, recipe_def.input.item.name},
                       recipe_id)

  if recipe_def.outputs.fluid then
    yatm_core.table_bury(self.m_output_fluid_to_recipes, {recipe_def.output.fluid.name, recipe_id}, true)
  end

  if recipe_def.outputs.item then
    yatm_core.table_bury(self.m_output_item_to_recipes, {recipe_def.output.item.name, recipe_id}, true)
  end

  return self
end

-- @spec get_brewing_recipe(input) :: recipe_def | nil
function ic:get_brewing_recipe(input)
  if input.fluid and input.fluid.amount > 0 and input.item and not input.item:is_empty() then
    if input.fluid.name then
      local item_name_to_recipe_id = self.m_recipes_index[input.fluid.name]
      if item_name_to_recipe_id then
        local recipe_id = item_name_to_recipe_id[input.item:get_name()]
        if recipe_id then
          local recipe = assert(self.m_recipes[recipe_id])
          -- check if recipe amounts have been met
          if recipe.input.fluid.amount <= input.fluid.amount and
             recipe.input.item.amount <= input.item:get_count() then
            return recipe
          end
        end
      end
    end
  end
  return nil
end

yatm_brewery.BrewingRegistry = BrewingRegistry
