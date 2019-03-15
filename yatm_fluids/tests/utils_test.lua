local Luna = assert(yatm.Luna)

local m = assert(yatm.fluids.Utils)

local case = Luna:new("yatm.fluids.Utils")

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

case:execute()
case:display_stats()
case:maybe_error()
