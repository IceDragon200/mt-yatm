local Luna = assert(foundation.com.Luna)

local FluidStack = assert(yatm_fluids.FluidStack)
local case = Luna:new("yatm_fluids.FluidStack")

case:describe("is_fluid_stack/1", function (t2)
  t2:test("reports whether or not an object is a FluidStack", function (t3)
    local a = FluidStack.new("my_mod:fluid", 10)

    t3:assert_eq(FluidStack.is_fluid_stack(a), true)
    t3:assert_eq(FluidStack.is_fluid_stack({}), false)
  end)
end)

case:describe("new/2", function (t2)
  t2:test("creates a new FluidStack", function (t3)
    local fluid_stack = FluidStack.new("default:water", 1000)
    t3:assert(fluid_stack, "expected a FluidStack")
    t3:assert_matches(fluid_stack, {
      name = "default:water",
      amount = 1000
    })
  end)
end)

case:describe("new_wildcard/2", function (t2)
  t2:test("creates a new wildcard FluidStack", function (t3)
    local fluid_stack = FluidStack.new_wildcard(1000)
    t3:assert(fluid_stack, "expected a FluidStack")
    t3:assert_matches(fluid_stack, {
      name = "*",
      amount = 1000,
    })
  end)
end)

case:describe("copy/1", function (t2)
  t2:test("can copy a fluid stack", function (t3)
    local a = FluidStack.new("default:water", 1000)
    local b = FluidStack.copy(a)

    t3:assert_eq(a, b, "expected fluids to match, based on equality operator")
    t3:assert(FluidStack.equals(a, b), "expected fluids to match, based on equality operator")
  end)
end)

case:describe("set_amount/2", function (t2)
  t2:test("creates a new FluidStack from a given FluidStack and amount", function (t3)
    local fluid_stack = FluidStack.new("default:water", 1000)

    local new_stack = FluidStack.set_amount(fluid_stack, 2000)

    t3:assert_matches(fluid_stack, {
      name = "default:water",
      amount = 1000
    })

    t3:assert_matches(fluid_stack, {
      name = "default:water",
      amount = 2000,
    })
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

case:describe("merge/1+", function (t2)
  t2:test("can merge multiple fluidstacks together", function (t3)
    local fluid_stack = FluidStack.new("default:water", 1000)

    FluidStack.merge(
      fluid_stack,
      FluidStack.new("default:water", 10),
      FluidStack.new("default:steam", 10)
    )

    t3:assert_matches(
      fluid_stack,
      {
        name = "default:water",
        amount = 1010,
      }
    )
  end)
end)

case:describe("merge_new/1+", function (t2)
  t2:test("can merge multiple fluidstacks together", function (t3)
    local fluid_stack = FluidStack.new("default:water", 1000)

    local result = FluidStack.merge_new(
      fluid_stack,
      FluidStack.new("default:water", 10),
      FluidStack.new("default:steam", 10)
    )

    t3:assert_matches(
      fluid_stack,
      {
        name = "default:water",
        amount = 1000,
      }
    )

    t3:assert_matches(
      result,
      {
        name = "default:water",
        amount = 1010,
      }
    )
  end)
end)

case:describe("add/1+", function (t2)
  t2:test("can add multiple fluidstacks together", function (t3)
    local fluid_stack = FluidStack.new("default:water", 1000)

    FluidStack.add(
      fluid_stack,
      FluidStack.new("default:water", 10),
      FluidStack.new("default:steam", 10)
    )

    t3:assert_matches(
      fluid_stack,
      {
        name = "default:water",
        amount = 1010,
      }
    )
  end)
end)

case:describe("subtract/1+", function (t2)
  t2:test("can subtract multiple fluidstacks", function (t3)
    local fluid_stack = FluidStack.new("default:water", 1000)

    FluidStack.subtract(
      fluid_stack,
      FluidStack.new("default:water", 10),
      FluidStack.new("default:steam", 10)
    )

    t3:assert_matches(
      fluid_stack,
      {
        name = "default:water",
        amount = 990,
      }
    )
  end)
end)

case:describe("#+/1", function (t2)
  t2:test("can add fluid stacks using native operator", function (t3)
    local a = FluidStack.new("default:water", 1000)
    local b = FluidStack.new("default:water", 10)
    local result = a + b

    t3:assert_matches(
      a,
      {
        name = "default:water",
        amount = 1000,
      }
    )

    t3:assert_matches(
      b,
      {
        name = "default:water",
        amount = 10,
      }
    )

    t3:assert_matches(
      result,
      {
        name = "default:water",
        amount = 1010,
      }
    )
  end)
end)

case:describe("#-/1", function (t2)
  t2:test("can subtract fluid stacks from each other", function (t3)
    local a = FluidStack.new("default:water", 1000)
    local b = FluidStack.new("default:water", 10)
    local result = a - b

    t3:assert_matches(
      a,
      {
        name = "default:water",
        amount = 1000,
      }
    )

    t3:assert_matches(
      b,
      {
        name = "default:water",
        amount = 10,
      }
    )

    t3:assert_matches(
      result,
      {
        name = "default:water",
        amount = 990,
      }
    )
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
