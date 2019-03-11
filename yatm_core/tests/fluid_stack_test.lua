local MetaRef = yatm_core.FakeMetaRef
local Luna = assert(yatm_core.Luna)

local case = Luna.new("yatm_core.FluidStack")

case:describe("new/2", function (t2)
  t2:test("creates a new FluidStack", function (t3)
    local fluid_stack = yatm_core.FluidStack.new("default:water", 1000)
    t3:assert(fluid_stack, "expected a FluidStack")
    t3:assert_eq(fluid_stack.name, "default:water")
    t3:assert_eq(fluid_stack.amount, 1000)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
