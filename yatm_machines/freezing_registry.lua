local FluidStack = assert(yatm.fluids.FluidStack)

--
-- Item recipe
--
local FreezingItemRecipe = yatm_core.Class:extends("FreezingItemRecipe")
local ic = FreezingItemRecipe.instance_class

function ic:initialize(opts)
  ic._super.initialize(self)

  self.id = opts.id
  self.name = opts.name
  self.input_item_stack = opts.input_item_stack
  self.output_item_stack = opts.output_item_stack
  self.duration = opts.duration
end

--
-- Fluid recipe
--
local FreezingFluidRecipe = yatm_core.Class:extends("FreezingFluidRecipe")
local ic = FreezingFluidRecipe.instance_class

function ic:initialize(opts)
  ic._super.initialize(self)

  self.id = opts.id
  self.name = opts.name
  self.input_fluid_stack = opts.input_fluid_stack
  self.output_item_stack = opts.output_item_stack
  self.duration = opts.duration
end

--
-- Registry
--
local FreezingRegistry = yatm_core.Class:extends("FreezingRegistry")
local ic = FreezingRegistry.instance_class

function ic:initialize()
  ic._super.initialize(self)

  self.g_recipe_id = 0

  self.m_item_recipes = {}
  self.m_fluid_recipes = {}

  self.m_item_input_to_recipe = {}
  self.m_fluid_input_to_recipe = {}
end

function ic:get_item_freezing_recipe(recipe_id)
  return self.m_item_recipes[recipe_id]
end

function ic:get_fluid_freezing_recipe(recipe_id)
  return self.m_fluid_recipes[recipe_id]
end

function ic:register_item_freezing_recipe(name, input_item, output_item, duration)
  assert(type(name) == "string", "expected a name")
  assert(input_item, "expected an input item")
  assert(output_item, "expected an output item")
  assert(type(duration) == "number", "expected a duration")

  self.g_recipe_id = self.g_recipe_id + 1
  local recipe_id = self.g_recipe_id

  local recipe =
    FreezingItemRecipe:new({
      id = recipe_id,
      name = name,
      input_item_stack = input_item,
      output_item_stack = output_item,
      duration = duration,
    })

  self.m_item_recipes[recipe.id] = recipe

  self.m_item_input_to_recipe[recipe.input_item_stack:get_name()] = recipe_id

  return recipe
end

function ic:register_fluid_freezing_recipe(name, input_fluid, output_item, duration)
  assert(type(name) == "string", "expected a name")
  assert(input_fluid, "expected an input fluid")
  assert(output_item, "expected an output item")
  assert(type(duration) == "number", "expected a duration")

  self.g_recipe_id = self.g_recipe_id + 1
  local recipe_id = self.g_recipe_id

  local recipe =
    FreezingFluidRecipe:new({
      id = recipe_id,
      name = name,
      input_fluid_stack = input_fluid,
      output_item_stack = output_item,
      duration = duration,
    })

  self.m_fluid_recipes[recipe.id] = recipe

  self.m_fluid_input_to_recipe[recipe.input_fluid_stack.name] = recipe_id

  return recipe
end

function ic:find_item_freezing_recipe(input_item)
  if input_item:is_empty() then
    return nil, "input is empty"
  end
  local recipe_id = self.m_item_input_to_recipe[input_item:get_name()]

  if recipe_id then
    local recipe = assert(self.m_item_recipes[recipe_id])

    if recipe.input_item_stack:get_count() > input_item:get_count() then
      return nil, "not enough input items"
    else
      return recipe
    end
  end
  return nil, "no matching recipe"
end

function ic:find_fluid_freezing_recipe(input_fluid)
  if FluidStack.is_empty(input_fluid) then
    return nil, "input is empty"
  end
  local recipe_id = self.m_fluid_input_to_recipe[input_fluid.name]

  if recipe_id then
    local recipe = assert(self.m_fluid_recipes[recipe_id])

    if recipe.input_fluid_stack.amount > input_fluid.amount then
      return nil, "not enough input fluid"
    else
      return recipe
    end
  end
  return nil, "no matching recipe"
end

yatm_machines.FreezingRegistry = FreezingRegistry
