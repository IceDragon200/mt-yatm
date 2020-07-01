local Luna = assert(yatm.Luna)

local m = assert(yatm.fluids.Utils)

local case = Luna:new("yatm.fluids.Utils")

case:describe("is_valid_name/1", function (t2)
  t2:test("given a valid fluid_name, will return true", function (t3)
    t3:assert(m.is_valid_name("yatm_fluids:steam"), "expected `yatm_fluids:steam` to be a valid name")
  end)

  t2:test("given a nil fluid name, will return false", function (t3)
    t3:refute(m.is_valid_name(nil), "expected `nil` to be invalid")
  end)

  t2:test("given a empty fluid name, will return false", function (t3)
    t3:refute(m.is_valid_name(""), "expected empty string to be invalid")
  end)

  t2:test("given a group name, will return false", function (t3)
    t3:refute(m.is_valid_name("group:steam"), "expected `group:name` to be invalid")
  end)
end)

case:describe("can_replace/3", function (t2)
  t2:test("given a nil fluid_name, and a valid source fluid name, it can replace", function (t3)
    t3:assert(m.can_replace(nil, "yatm_fluids:steam", 1000))
  end)

  t2:test("given a blank fluid_name, and a valid source fluid name, it can replace", function (t3)
    t3:assert(m.can_replace("", "yatm_fluids:steam", 1000))
  end)

  t2:test("given a valid fluid_name, a valid source fluid name and 0 amount, it can replace", function (t3)
    t3:assert(m.can_replace("yatm_fluids:crude_oil", "yatm_fluids:steam", 0))
  end)

  t2:test("given a valid fluid name, a valid source fluid name and a non-zero amount, it cannot replace", function (t3)
    t3:refute(m.can_replace("yatm_fluids:crude_oil", "yatm_fluids:steam", 1000))
  end)
end)

case:describe("matches/2", function (t2)
  t2:test("can match 2 fluid names", function (t3)
    t3:assert_eq(m.matches("yatm_fluids:crude_oil", "yatm_fluids:crude_oil"), "yatm_fluids:crude_oil")
  end)

  t2:test("can match a fluid name with a fluid group", function (t3)
    t3:assert_eq(m.matches("group:oil", "yatm_fluids:crude_oil"), "yatm_fluids:crude_oil")
    t3:assert_eq(m.matches("yatm_fluids:crude_oil", "group:oil"), "yatm_fluids:crude_oil")
    t3:assert_eq(m.matches("group:steam", "yatm_fluids:steam"), "yatm_fluids:steam")
    t3:assert_eq(m.matches("yatm_fluids:steam", "group:steam"), "yatm_fluids:steam")
    t3:assert_eq(m.matches("group:steam", "yatm_fluids:crude_oil"), nil)
    t3:assert_eq(m.matches("yatm_fluids:crude_oil", "group:steam"), nil)
    t3:assert_eq(m.matches("group:oil", "yatm_fluids:steam"), nil)
    t3:assert_eq(m.matches("yatm_fluids:steam", "group:oil"), nil)
  end)

  t2:test("cannot match 2 groups", function (t3)
    t3:refute(m.matches("group:oil", "group:oil"), "2 matching groups shouldn't be matchable")
    t3:refute(m.matches("group:oil", "group:steam"), "2 different groups shouldn't be matchable")
  end)

  t2:test("can wilcard match any fluid given *", function (t3)
    t3:assert_eq(m.matches("yatm_fluids:steam", "*"), "yatm_fluids:steam")
    t3:assert_eq(m.matches("*", "yatm_fluids:steam"), "yatm_fluids:steam")
  end)

  t2:test("cannot wildcard a group", function (t3)
    t3:refute(m.matches("*", "group:steam"))
    t3:refute(m.matches("group:oil", "*"))
  end)

  t2:test("cannot wildcard a wildcard", function (t3)
    t3:refute(m.matches("*", "*"))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
