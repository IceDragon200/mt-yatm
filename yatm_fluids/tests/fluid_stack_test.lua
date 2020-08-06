local MetaRef = assert(foundation.com.FakeMetaRef)
local Luna = assert(foundation.com.Luna)

local FluidStack = assert(yatm_fluids.FluidStack)
local case = Luna:new("yatm_fluids.FluidStack")

case:describe("new/2", function (t2)
  t2:test("creates a new FluidStack", function (t3)
    local fluid_stack = FluidStack.new("default:water", 1000)
    t3:assert(fluid_stack, "expected a FluidStack")
    t3:assert_eq(fluid_stack.name, "default:water")
    t3:assert_eq(fluid_stack.amount, 1000)
  end)
end)

case:describe("new_wildcard/2", function (t2)
  t2:test("creates a new wildcard FluidStack", function (t3)
    local fluid_stack = FluidStack.new_wildcard(1000)
    t3:assert(fluid_stack, "expected a FluidStack")
    t3:assert_eq(fluid_stack.name, "*")
    t3:assert_eq(fluid_stack.amount, 1000)
  end)
end)

case:describe("set_amount/2", function (t2)
  t2:test("creates a new FluidStack from a given FluidStack and amount", function (t3)
    local fluid_stack = FluidStack.new("default:water", 1000)

    local new_stack = FluidStack.set_amount(fluid_stack, 2000)

    t3:assert_eq(fluid_stack.name, "default:water")
    t3:assert_eq(fluid_stack.amount, 1000)

    t3:assert_eq(new_stack.name, "default:water")
    t3:assert_eq(new_stack.amount, 2000)
  end)
end)

case:describe("dec_amount/2", function (t2)
  t2:test("decrements a given FluidStack's amount returning the new stack", function (t3)
    local fluid_stack = FluidStack.new("default:water", 1000)

    local new_stack = FluidStack.dec_amount(fluid_stack, 400)

    t3:assert_eq(fluid_stack.name, "default:water")
    t3:assert_eq(fluid_stack.amount, 1000)

    t3:assert_eq(new_stack.name, "default:water")
    t3:assert_eq(new_stack.amount, 600)
  end)
end)

case:describe("inc_amount/2", function (t2)
  t2:test("decrements a given FluidStack's amount returning the new stack", function (t3)
    local fluid_stack = FluidStack.new("default:water", 1000)

    local new_stack = FluidStack.inc_amount(fluid_stack, 400)

    t3:assert_eq(fluid_stack.name, "default:water")
    t3:assert_eq(fluid_stack.amount, 1000)

    t3:assert_eq(new_stack.name, "default:water")
    t3:assert_eq(new_stack.amount, 1400)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
