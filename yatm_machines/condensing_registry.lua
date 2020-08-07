local FluidStack = assert(yatm.fluids.FluidStack)

local CondensingRecipe = foundation.com.Class:extends("CondensingRecipe")
do
  local ic = CondensingRecipe.instance_class

  function ic:initialize(opts)
    ic._super.initialize(self)

    self.id = opts.id
    self.name = opts.name
    self.input_fluid_stack = opts.input_fluid_stack
    self.output_fluid_stack = opts.output_fluid_stack
    self.duration = opts.duration
  end
end

--
-- Registry
--
local CondensingRegistry = foundation.com.Class:extends("CondensingRegistry")
do
  local ic = CondensingRegistry.instance_class

  function ic:initialize()
    ic._super.initialize(self)

    self.g_recipe_id = 0
    self.m_recipes = {}
    self.m_fluid_to_recipe = {}
  end

  function ic:get_condensing_recipe(recipe_id)
    return self.m_recipes[recipe_id]
  end

  function ic:register_condensing_recipe(name, input_fluid, output_fluid, duration)
    assert(type(name) == "string", "expected a name")
    assert(input_fluid, "expected an input fluid")
    assert(output_fluid, "expected an output item")
    assert(type(duration) == "number", "expected a duration")

    self.g_recipe_id = self.g_recipe_id + 1
    local recipe_id = self.g_recipe_id

    local recipe =
      CondensingRecipe:new({
        id = recipe_id,
        name = name,
        input_fluid_stack = input_fluid,
        output_fluid_stack = output_fluid,
        duration = duration,
      })

    self.m_recipes[recipe.id] = recipe
    self.m_fluid_to_recipe[recipe.input_fluid_stack.name] = recipe_id

    return recipe
  end

  function ic:find_condensing_recipe(input_fluid)
    if FluidStack.is_empty(input_fluid) then
      return nil, "input is empty"
    end
    local recipe_id = self.m_fluid_to_recipe[input_fluid.name]

    if recipe_id then
      local recipe = assert(self.m_recipes[recipe_id])

      if recipe.input_fluid_stack.amount > input_fluid.amount then
        return nil, "not enough input fluid"
      else
        return recipe
      end
    end
    return nil, "no matching recipe"
  end
end

yatm_machines.CondensingRegistry = CondensingRegistry
