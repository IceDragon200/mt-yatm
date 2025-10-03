--
-- The pressing registry contains recipes for the mechanical press.
--
local assertions = assert(foundation.com.assertions)
local list_map = assert(foundation.com.list_map)
local list_sort_by = assert(foundation.com.list_sort_by)
local ItemIngredient = assert(yatm.recipe_component.ItemIngredient)
local FluidOutput = assert(yatm.recipe_component.FluidOutput)
local get_content_id = assert(core.get_content_id)

--- @namespace yatm_brewery

--- @class PressingRegistry
local PressingRegistry = foundation.com.Class:extends('yatm.brewery.PressingRegistry')

PressingRegistry.ERR_OK = "ERR_OK"
PressingRegistry.ERR_NO_RECIPE = "ERR_NO_RECIPE"

do
  local ic = PressingRegistry.instance_class

  --- @type PressingRecipeDefinition: {
  ---   input = {
  ---     items = {},
  ---   },
  ---   output = {
  ---     fluids = {},
  ---   },
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

    --- A tree structure with item ids
    --- @member m_ingredient_tree: {
    ---   [id: Number]: Any
    --- }
    self.m_ingredient_tree = {
      recipes = {}, -- root recipes should ALWAYS be empty
      children = {},
    }
  end

  --- @spec #sort_item_stacks_by_content_id(ItemIngredient[]): ItemIngredient[]
  function ic:sort_item_ingredients_by_content_id(items)
    return list_sort_by(items, function (item)
      return get_content_id(item.name)
    end)
  end

  --- @spec #sort_item_stacks_by_content_id(ItemStack[]): ItemStack[]
  function ic:sort_item_stacks_by_content_id(item_stacks)
    return list_sort_by(item_stacks, function (item_stack)
      return get_content_id(item_stack:get_name())
    end)
  end

  --- @spec #matches_recipe(ItemStack[], Any): Boolean
  function ic:matches_recipe(items, recipe)
    if #items == #recipe.input.items then
      for i, ingredient in ipairs(recipe.input.items) do
        if not ingredient:matches_item_stack(items[i]) then
          return false
        end
      end

      return true
    end
    return false
  end

  --- @spec #register_pressing_recipe(name: String, PressingRecipeDefinition): PressingRecipe
  function ic:register_pressing_recipe(name, recipe_def)
    assertions.is_string(name, "expected a name for recipe")

    self.m_g_recipe_id = self.m_g_recipe_id + 1
    local recipe_id = self.m_g_recipe_id

    recipe_def.id = recipe_id
    recipe_def.name = name
    if self.m_recipes_name_to_id[recipe_def.name] then
      error("pressing recipe name=" .. recipe_def.name .. " already exists")
    end

    if not recipe_def.input then
      error("pressing recipe input is required")
    end

    if not recipe_def.input.items then
      error("pressing recipe input items are required")
    end

    if not recipe_def.output then
      error("pressing recipe output is required")
    end

    if not recipe_def.output.fluids then
      error("pressing recipe output fluids is required")
    end

    recipe_def.input.items = list_map(recipe_def.input.items, function (item)
      return ItemIngredient:new(item)
    end)
    recipe_def.input.items = self:sort_item_ingredients_by_content_id(recipe_def.input.items)

    recipe_def.output.fluids = list_map(recipe_def.output.fluids, function (item)
      return FluidOutput:new(item)
    end)

    local root = self.m_ingredient_tree
    local cid
    for i,item in ipairs(recipe_def.input.items) do
      cid = assert(get_content_id(item.name))
      if not root.children[cid] then
        root.children[cid] = {
          recipes = {},
          children = {},
        }
      end
      root = root.children[cid]
    end
    root.recipes[recipe_id] = true

    self.m_recipes[recipe_id] = recipe_def
    self.m_recipes_name_to_id[recipe_def.name] = recipe_id

    return recipe_def
  end

  --- Retrieve a pressing recipe by its id if it exists, ids may change between
  --- runtime so this should never be relied upon, instead use the recipe's name when possible.
  ---
  --- @spec #get_pressing_recipe(recipe_id: Integer): PressingRecipe | nil
  function ic:get_pressing_recipe(recipe_id)
    local recipe = self.m_recipes[recipe_id]
    if recipe then
      return recipe, PressingRegistry.ERR_OK
    end

    return nil, PressingRegistry.ERR_NO_RECIPE
  end

  --- Retrieve a pressing recipe by its name.
  ---
  --- @spec #get_pressing_recipe_by_name(name: String): PressingRecipe | nil
  function ic:get_pressing_recipe_by_name(name)
    local recipe_id = self.m_recipes_name_to_id[name]

    if recipe_id then
      return self.m_recipes[recipe_id], PressingRegistry.ERR_OK
    end

    return nil, PressingRegistry.ERR_NO_RECIPE
  end

  --- Lookup a recipe by the given input which are presorted.
  --- If you don't wish to sort the items yourself by their content id, you can simply use
  --- get_pressing_recipe_by_input/1 instead
  ---
  --- @spec #get_pressing_recipe_by_input_presorted(input: { items: ItemStack[] }): PressingRecipe
  function ic:get_pressing_recipe_by_input_presorted(input)
    local root = self.m_ingredient_tree
    local name
    local cid
    for _,item_stack in ipairs(input.items) do
      name = item_stack:get_name()
      cid = get_content_id(name)
      root = root.children[cid]
      if not root then
        return nil, PressingRegistry.ERR_NO_RECIPE
      end
    end

    if root then
      local recipe
      for recipe_id,_ in pairs(root.recipes) do
        recipe = self.m_recipes[recipe_id]
        if recipe then
          if self:matches_recipe(input.items, recipe) then
            return recipe
          end
        end
      end
    end

    return nil, PressingRegistry.ERR_NO_RECIPE
  end

  --- @spec #get_pressing_recipe_by_input(input: { items: ItemStack[] }): PressingRecipe
  function ic:get_pressing_recipe_by_input(input)
    input.items = self:sort_item_stacks_by_content_id(input.items)
    return self:get_pressing_recipe_by_input_presorted(input)
  end
end

yatm_brewery.PressingRegistry = PressingRegistry
