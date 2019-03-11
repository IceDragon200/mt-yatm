local MetaRef = yatm_core.FakeMetaRef
local Luna = assert(yatm_core.Luna)

local m = assert(yatm_core.fluids)
local FluidStack = assert(yatm_core.FluidStack)

local case = Luna.new("yatm_core.fluids")

case:describe("get_item_fluid_name/1", function (t2)
  t2:test("can retrieve fluid names for registered fluid source blocks", function (t3)
    t3:assert(m.get_item_fluid_name("default:water_source"))
    t3:assert(m.get_item_fluid_name("default:river_water_source"))
    t3:assert(m.get_item_fluid_name("default:lava_source"))
    t3:assert(m.get_item_fluid_name("yatm_core:oil_source"))
    t3:assert(m.get_item_fluid_name("yatm_core:heavy_oil_source"))
    t3:assert(m.get_item_fluid_name("yatm_core:light_oil_source"))
  end)
end)

case:describe("is_valid_name/1", function (t2)
  t2:test("given a valid fluid_name, will return true", function (t3)
    t3:assert(m.is_valid_name("default:water"), "expected `default:water` to be a valid name")
  end)

  t2:test("given a nil fluid name, will return false", function (t3)
    t3:refute(m.is_valid_name(nil), "expected `nil` to be invalid")
  end)

  t2:test("given a empty fluid name, will return false", function (t3)
    t3:refute(m.is_valid_name(""), "expected empty string to be invalid")
  end)

  t2:test("given a group name, will return false", function (t3)
    t3:refute(m.is_valid_name("group:water"), "expected `group:name` to be invalid")
  end)
end)

case:describe("can_replace/3", function (t2)
  t2:test("given a nil fluid_name, and a valid source fluid name, it can replace", function (t3)
    t3:assert(m.can_replace(nil, "default:water", 1000))
  end)

  t2:test("given a blank fluid_name, and a valid source fluid name, it can replace", function (t3)
    t3:assert(m.can_replace("", "default:water", 1000))
  end)

  t2:test("given a valid fluid_name, a valid source fluid name and 0 amount, it can replace", function (t3)
    t3:assert(m.can_replace("default:lava", "default:water", 0))
  end)

  t2:test("given a valid fluid name, a valid source fluid name and a non-zero amount, it cannot replace", function (t3)
    t3:refute(m.can_replace("default:lava", "default:water", 1000))
  end)
end)

case:describe("matches/2", function (t2)
  t2:test("can match 2 fluid names", function (t3)
    t3:assert_eq(m.matches("default:lava", "default:lava"), "default:lava")
  end)

  t2:test("can match a fluid name with a fluid group", function (t3)
    t3:assert_eq(m.matches("group:lava", "default:lava"), "default:lava")
    t3:assert_eq(m.matches("default:lava", "group:lava"), "default:lava")
    t3:assert_eq(m.matches("group:water", "default:water"), "default:water")
    t3:assert_eq(m.matches("default:water", "group:water"), "default:water")
    t3:assert_eq(m.matches("group:water", "default:lava"), nil)
    t3:assert_eq(m.matches("default:lava", "group:water"), nil)
    t3:assert_eq(m.matches("group:lava", "default:water"), nil)
    t3:assert_eq(m.matches("default:water", "group:lava"), nil)
  end)

  t2:test("cannot match 2 groups", function (t3)
    t3:refute(m.matches("group:lava", "group:lava"), "2 matching groups shouldn't be matchable")
    t3:refute(m.matches("group:lava", "group:water"), "2 different groups shouldn't be matchable")
  end)

  t2:test("can wilcard match any fluid given *", function (t3)
    t3:assert_eq(m.matches("default:water", "*"), "default:water")
    t3:assert_eq(m.matches("*", "default:water"), "default:water")
  end)

  t2:test("cannot wildcard a group", function (t3)
    t3:refute(m.matches("*", "group:water"))
    t3:refute(m.matches("group:lava", "*"))
  end)

  t2:test("cannot wildcard a wildcard", function (t3)
    t3:refute(m.matches("*", "*"))
  end)
end)

case:describe("set_fluid/4", function (t2)
  t2:test("will not modify meta if commit is false", function (t3)
    local meta = MetaRef.new()

    m.set_fluid(meta, "tank", FluidStack.new("default:water", 1000), false)

    t3:refute(m.get_fluid(meta, "tank"))
  end)

  t2:test("will modify meta if commit is true", function (t3)
    local meta = MetaRef.new()

    m.set_fluid(meta, "tank", FluidStack.new("default:water", 1000), true)

    local fluid_stack = m.get_fluid(meta, "tank")

    t3:assert(fluid_stack, "expected a fluid stack")
    t3:assert_eq(fluid_stack.name, "default:water")
    t3:assert_eq(fluid_stack.amount, 1000)
  end)

  t2:test("can modify meta and replace fluid if commit is true", function (t3)
    local meta = MetaRef.new()

    m.set_fluid(meta, "tank", FluidStack.new("default:water", 1000), true)

    m.set_fluid(meta, "tank", FluidStack.new("yatm_core:steam", 4000), true)

    local fluid_stack = m.get_fluid(meta, "tank")

    t3:assert(fluid_stack, "expected a fluid stack")
    t3:assert_eq(fluid_stack.name, "yatm_core:steam")
    t3:assert_eq(fluid_stack.amount, 4000)
  end)

  t2:test("can set multiple keys", function (t3)
    local meta = MetaRef.new()

    m.set_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), true)
    m.set_fluid(meta, "steam_tank", FluidStack.new("yatm_core:steam", 4000), true)

    local fluid_stack = m.get_fluid(meta, "water_tank")
    t3:assert(fluid_stack, "expected a fluid stack")
    t3:assert_eq(fluid_stack.name, "default:water")
    t3:assert_eq(fluid_stack.amount, 1000)

    local fluid_stack = m.get_fluid(meta, "steam_tank")

    t3:assert(fluid_stack, "expected a fluid stack")
    t3:assert_eq(fluid_stack.name, "yatm_core:steam")
    t3:assert_eq(fluid_stack.amount, 4000)
  end)
end)

case:describe("drain_fluid/6", function (t2)
  t2:test("will not modify meta if commit is false", function (t3)
    local meta = MetaRef.new()

    m.set_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), true)

    local used_stack, new_stack = m.drain_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), 1000, 1000, false)

    t3:assert(used_stack, "expected a fluid stack")
    t3:assert_eq(used_stack.name, "default:water")
    t3:assert_eq(used_stack.amount, 1000)

    t3:assert(new_stack, "expected a fluid stack")
    t3:assert_eq(new_stack.name, "default:water")
    t3:assert_eq(new_stack.amount, 0)

    local fluid_stack = m.get_fluid(meta, "water_tank")
    t3:assert(fluid_stack, "expected a fluid stack")
    t3:assert_eq(fluid_stack.name, "default:water")
    t3:assert_eq(fluid_stack.amount, 1000)
  end)

  t2:test("will modify meta if commit is true", function (t3)
    local meta = MetaRef.new()

    m.set_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), true)

    local used_stack, new_stack = m.drain_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), 1000, 1000, true)

    t3:assert(used_stack, "expected a fluid stack")
    t3:assert_eq(used_stack.name, "default:water")
    t3:assert_eq(used_stack.amount, 1000)

    t3:assert(new_stack, "expected a fluid stack")
    t3:assert_eq(new_stack.name, "default:water")
    t3:assert_eq(new_stack.amount, 0)

    local fluid_stack = m.get_fluid(meta, "water_tank")
    t3:refute(fluid_stack)
  end)
end)

case:describe("fill_fluid/6", function (t2)
  t2:test("will not modify meta if commit is false", function (t3)
    local meta = MetaRef.new()

    local used_stack, new_stack = m.fill_fluid(meta, "water_tank", FluidStack.new("default:water", 1000), 1000, 1000, false)

    t3:assert(used_stack)
    t3:assert(used_stack.name, "default:water")
    t3:assert(used_stack.amount, 1000)

    t3:assert(new_stack)
    t3:assert(new_stack.name, "default:water")
    t3:assert(new_stack.amount, 1000)

    local fluid_stack = m.get_fluid(meta, "water_tank")
    t3:refute(fluid_stack)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
