local MetaRef = assert(yatm_core.FakeMetaRef)
local Luna = assert(yatm.Luna)

local m = assert(yatm.fluids.FluidMeta)
local FluidStack = assert(yatm.fluids.FluidStack)

local case = Luna:new("yatm.fluids.FluidMeta")

case:describe("set_fluid/4", function (t2)
  t2:test("will not modify meta if commit is false", function (t3)
    local meta = MetaRef:new()

    m.set_fluid(meta, "tank", FluidStack.new("default:water", 1000), false)

    t3:refute(m.get_fluid_stack(meta, "tank"))
  end)

  t2:test("will modify meta if commit is true", function (t3)
    local meta = MetaRef:new()

    m.set_fluid(meta, "tank", FluidStack.new("default:water", 1000), true)

    local fluid_stack = m.get_fluid_stack(meta, "tank")

    t3:assert(fluid_stack, "expected a fluid stack")
    t3:assert_eq(fluid_stack.name, "default:water")
    t3:assert_eq(fluid_stack.amount, 1000)
  end)

  t2:test("can modify meta and replace fluid if commit is true", function (t3)
    local meta = MetaRef:new()

    m.set_fluid(meta, "tank", FluidStack.new("default:water", 1000), true)

    m.set_fluid(meta, "tank", FluidStack.new("yatm_fluids:steam", 4000), true)

    local fluid_stack = m.get_fluid_stack(meta, "tank")

    t3:assert(fluid_stack, "expected a fluid stack")
    t3:assert_eq(fluid_stack.name, "yatm_fluids:steam")
    t3:assert_eq(fluid_stack.amount, 4000)
  end)

  t2:test("can set multiple keys", function (t3)
    local meta = MetaRef:new()

    m.set_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), true)
    m.set_fluid(meta, "steam_tank", FluidStack.new("yatm_fluids:steam", 4000), true)

    local fluid_stack = m.get_fluid_stack(meta, "water_tank")
    t3:assert(fluid_stack, "expected a fluid stack")
    t3:assert_eq(fluid_stack.name, "default:water")
    t3:assert_eq(fluid_stack.amount, 1000)

    local fluid_stack = m.get_fluid_stack(meta, "steam_tank")

    t3:assert(fluid_stack, "expected a fluid stack")
    t3:assert_eq(fluid_stack.name, "yatm_fluids:steam")
    t3:assert_eq(fluid_stack.amount, 4000)
  end)
end)

case:describe("drain_fluid/6", function (t2)
  t2:test("will not modify meta if commit is false", function (t3)
    local meta = MetaRef:new()

    m.set_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), true)

    local used_stack, new_stack = m.drain_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), 1000, 1000, false)

    t3:assert(used_stack, "expected a fluid stack")
    t3:assert_eq(used_stack.name, "default:water")
    t3:assert_eq(used_stack.amount, 1000)

    t3:assert(new_stack, "expected a fluid stack")
    t3:assert_eq(new_stack.name, "default:water")
    t3:assert_eq(new_stack.amount, 0)

    local fluid_stack = m.get_fluid_stack(meta, "water_tank")
    t3:assert(fluid_stack, "expected a fluid stack")
    t3:assert_eq(fluid_stack.name, "default:water")
    t3:assert_eq(fluid_stack.amount, 1000)
  end)

  t2:test("will modify meta if commit is true", function (t3)
    local meta = MetaRef:new()

    m.set_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), true)

    local used_stack, new_stack = m.drain_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), 1000, 1000, true)

    t3:assert(used_stack, "expected a fluid stack")
    t3:assert_eq(used_stack.name, "default:water")
    t3:assert_eq(used_stack.amount, 1000)

    t3:assert(new_stack, "expected a fluid stack")
    t3:assert_eq(new_stack.name, "default:water")
    t3:assert_eq(new_stack.amount, 0)

    local fluid_stack = m.get_fluid_stack(meta, "water_tank")
    t3:refute(fluid_stack)
  end)
end)

case:describe("fill_fluid/6", function (t2)
  t2:test("will not modify meta if commit is false", function (t3)
    local meta = MetaRef:new()

    local used_stack, new_stack = m.fill_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), 1000, 1000, false)

    t3:assert(used_stack)
    t3:assert(used_stack.name, "default:water")
    t3:assert(used_stack.amount, 1000)

    t3:assert(new_stack)
    t3:assert(new_stack.name, "default:water")
    t3:assert(new_stack.amount, 1000)

    local fluid_stack = m.get_fluid_stack(meta, "water_tank")
    t3:refute(fluid_stack)
  end)

  t2:test("will modify meta if commit is true", function (t3)
    local meta = MetaRef:new()

    local used_stack, new_stack = m.fill_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), 1000, 1000, true)

    t3:assert(used_stack)
    t3:assert(used_stack.name, "default:water")
    t3:assert(used_stack.amount, 1000)

    t3:assert(new_stack)
    t3:assert(new_stack.name, "default:water")
    t3:assert(new_stack.amount, 1000)

    local fluid_stack = m.get_fluid_stack(meta, "water_tank")

    t3:assert(fluid_stack)
    t3:assert(fluid_stack.name, "default:water")
    t3:assert(fluid_stack.amount, 1000)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
