local FluidStack = assert(yatm.fluids.FluidStack)
local Luna = assert(foundation.com.Luna)

local Subject = assert(yatm_brewery.PressingRegistry)
local case = Luna:new("yatm_brewery.PressingRegistry")

case:describe("register_pressing_recipe/2", function (t2)
  t2:test("can register a new pressing recipe", function (t3)
    local subject = Subject:new()

    local cid = assert(core.get_content_id("yatm_brewery:yeast_brewers"))

    -- just some garbage recipe
    local reg_recipe = subject:register_pressing_recipe("my_mod:new_recipe", {
      input = {
        items = {
          -- we need to use something existing
          -- and it should support the short hand string and table
          "yatm_brewery:yeast_brewers",
          "yatm_brewery:yeast_brewers",
          { name = "yatm_brewery:yeast_brewers" },
          { name = "yatm_brewery:yeast_brewers" },
        },
      },
      output = {
        fluids = {
          {
            name = "yatm_fluids:hydrogen",
            amount = 1000,
          }
        }
      },
      duration = 1,
    })

    local root = subject.m_ingredient_tree
    t3:assert(root)
    for _ = 1,4 do
      root = root.children[cid] -- yeasts
      t3:assert(root)
    end
    t3:assert(root.recipes[reg_recipe.id], "expected a recipe")

    t3:assert_eq(subject:get_pressing_recipe(reg_recipe.id), reg_recipe)

    local recipe =
      subject:get_pressing_recipe_by_input({
        items = {
          ItemStack("yatm_brewery:yeast_brewers"),
          ItemStack("yatm_brewery:yeast_brewers"),
          ItemStack("yatm_brewery:yeast_brewers"),
          ItemStack("yatm_brewery:yeast_brewers"),
        },
      })

    t3:assert_matches(recipe, {
      name = "my_mod:new_recipe",
    })

    recipe =
      subject:get_pressing_recipe_by_input({
        -- make it purposely short a yeast
        items = {
          ItemStack("yatm_brewery:yeast_brewers"),
          ItemStack("yatm_brewery:yeast_brewers"),
          ItemStack("yatm_brewery:yeast_brewers"),
        },
      })

    t3:assert_matches(recipe, nil)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
