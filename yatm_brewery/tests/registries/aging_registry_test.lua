local FluidStack = assert(yatm.fluids.FluidStack)
local Luna = assert(foundation.com.Luna)

local Subject = assert(yatm_brewery.AgingRegistry)
local case = Luna:new("yatm_brewery.AgingRegistry")

case:describe("register_aging_recipe/2", function (t2)
  t2:test("can register a new aging recipe", function (t3)
    local subject = Subject:new()

    local reg_recipe = subject:register_aging_recipe("my_mod:new_recipe", {
      inputs = {
        item = {
          name = "my_mod:fire_yeast",
        },
        fluid = {
          name = "my_mod:apple_cider",
        },
      },
      outputs = {
        fluid = {
          name = "my_mod:apple_cider_spicy",
        }
      },
      duration = 1,
    })

    t3:assert_eq(subject:get_aging_recipe(reg_recipe.id), reg_recipe)

    local item_tree = subject.m_recipes_index["my_mod:apple_cider"]
    t3:assert_matches(item_tree, {
      ["my_mod:fire_yeast"] = reg_recipe.id,
    })
    local recipe =
      subject:get_aging_recipe_by_inputs({
        item = ItemStack("my_mod:fire_yeast"),
        fluid = FluidStack.new("my_mod:apple_cider", 1),
      })

    t3:assert_matches(recipe, {
      name = "my_mod:new_recipe",
    })
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
