local Luna = assert(foundation.com.Luna)

local Subject = assert(yatm_brewery.AgingRegistry)
local case = Luna:new("yatm_brewery.AgingRegistry")

case:describe("register_aging_recipe/2", function (t2)
  t2:test("can register a new aging recipe", function (t3)
    local subject = Subject:new()

    subject:register_aging_recipe("my_mod:new_recipe", {
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


  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
