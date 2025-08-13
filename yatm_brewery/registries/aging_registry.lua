--
-- The AgingRegistry contains recipes for an aging barrel
--
local table_bury = assert(foundation.com.table_bury)
local assertions = assert(foundation.com.assertions)
local ItemIngredient = assert(yatm.recipe_component.ItemIngredient)
local ItemOutput = assert(yatm.recipe_component.ItemOutput)
local FluidIngredient = assert(yatm.recipe_component.FluidIngredient)
local FluidOutput = assert(yatm.recipe_component.FluidOutput)

--- @namespace yatm_brewery

---
--- @type AgingRecipeInput: {
---   item: ItemIngredient,
---   fluid: FluidIngredient,
--- }

--- Duration is in seconds
---
--- @type AgingRecipeDefinition: {
---   inputs: AgingRecipeInput,
---   outputs: {
---     item?: ItemIngredient,
---     fluid: FluidIngredient,
---   },
---   duration: Float,
--- }

--- @class AgingRecipe
local AgingRecipe = foundation.com.Class:extends("yatm.brewery.AgingRecipe")
do
  local ic = AgingRecipe.instance_class

  --- @spec #initialize(AgingRecipeDefinition): void
  function ic:initialize(def)
    assertions.is_table(def)
    ic._super.initialize(self)
    --- @member id: String
    self.id = def.id
    --- @member name: String
    self.name = def.name
    --- @member inputs: AgingRecipeInput
    local inputs = def.inputs
    self.inputs = {
      item = ItemIngredient:new(inputs.item),
      fluid = FluidIngredient:new(inputs.fluid),
    }
    --- @member outputs: { item: ItemOutput, fluid: FluidOutput }
    local outputs = def.outputs
    self.outputs = {
      item = outputs.item and ItemOutput:new(outputs.item),
      fluid = outputs.fluid and FluidOutput:new(outputs.fluid),
    }
    --- @member duration: Float
    self.duration = assertions.is_number(def.duration)
  end

  --- Utility function for AgingRegistry to determine if the inputs have valid minimum amounts
  --- for the selected recipe.
  ---
  --- @spec #matches_inputs_amounts(AgingRecipeInput): Boolean
  function ic:matches_inputs_amounts(inputs)
    local item = inputs.item
    local fluid = inputs.fluid

    if self.inputs.fluid.amount <= fluid.amount then
      if self.inputs.item.amount <= item:get_count() then
        return true
      end
    end
    return false
  end
end

--- @class AgingRegistry
local AgingRegistry = foundation.com.Class:extends('yatm.brewery.AgingRegistry')
do
  local ic = AgingRegistry.instance_class

  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)
    self.m_recipe_id = 0
    self.m_recipes = {}
    self.m_recipes_name_to_id = {}
    -- fluid => item => recipe_id
    self.m_recipes_index = {}
  end

  --- @spec #register_aging_recipe(name: String, AgingRecipeDefinition): AgingRecipe
  function ic:register_aging_recipe(name, recipe_def)
    assertions.is_string(name, "expected name")
    assertions.is_table(recipe_def, "expected recipe defintiion to be a table")
    assertions.is_table(recipe_def.inputs, "expected inputs")
    assertions.is_table(recipe_def.inputs.item, "expected inputs item")
    assertions.is_table(recipe_def.inputs.fluid, "expected inputs fluid")
    assertions.is_number(recipe_def.duration, "expected duration")
    assert(recipe_def.duration >= 0, "expected duration to be greater than or equal to zero")

    self.m_recipe_id = self.m_recipe_id + 1
    local recipe_id = self.m_recipe_id

    local recipe = AgingRecipe:new(recipe_def)
    recipe.id = recipe_id
    recipe.name = name

    self.m_recipes[recipe_id] = recipe
    self.m_recipes_name_to_id[recipe.name] = recipe_id

    table_bury(self.m_recipes_index, {
      recipe.inputs.fluid.name,
      recipe.inputs.item.name
    }, recipe_id)

    return recipe
  end

  --- Retrieve a recipe by given inputs, note that this function will not check
  --- the item and fluid amounts in the input.
  ---
  --- @spec #get_aging_recipe_by_inputs_indifferent(RecipeInputs): AgingRecipe | nil
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

  --- Retrieve a recipe by given inputs, note that this function will check
  --- the input amounts and may return nil if the amounts are insufficient
  ---
  --- @spec #get_aging_recipe_by_inputs(RecipeInputs): AgingRecipe | nil
  function ic:get_aging_recipe_by_inputs(inputs)
    local recipe = self:get_aging_recipe_indifferent(inputs)

    if recipe then
      if recipe:matches_inputs_amounts(inputs) then
        return recipe
      end
    end

    return nil
  end

  --- Retrieve an aging recipe by its id if it exists
  ---
  --- @spec #get_aging_recipe(recipe_id: Integer): AgingRecipe | nil
  function ic:get_aging_recipe(recipe_id)
    return self.m_recipes[recipe_id]
  end

  --- Retrieve an aging recipe by its mod given name, useful since the recipe_id
  --- may be unstable between replays.
  ---
  --- @spec #get_aging_recipe_by_name(name: String): AgingRecipe | nil
  function ic:get_aging_recipe_by_name(name)
    local recipe_id = self.m_recipes_name_to_id[name]

    if recipe_id then
      return self.m_recipes[recipe_id]
    end

    return nil
  end
end

yatm_brewery.AgingRegistry = AgingRegistry
