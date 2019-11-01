local Luna = assert(yatm_core.Luna)
local m = yatm_core

local case = Luna:new("yatm_core-util/direction")

case:describe("invert_dir", function (t2)
  t2:test("inverts given direction", function (t3)
    t3:assert_eq(m.D_NORTH, m.invert_dir(m.D_SOUTH))
    t3:assert_eq(m.D_SOUTH, m.invert_dir(m.D_NORTH))
    t3:assert_eq(m.D_EAST, m.invert_dir(m.D_WEST))
    t3:assert_eq(m.D_WEST, m.invert_dir(m.D_EAST))
    t3:assert_eq(m.D_UP, m.invert_dir(m.D_DOWN))
    t3:assert_eq(m.D_DOWN, m.invert_dir(m.D_UP))

    t3:assert_eq(m.D_NONE, m.invert_dir(m.D_NONE))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
