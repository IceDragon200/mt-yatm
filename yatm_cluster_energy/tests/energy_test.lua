local Luna = assert(foundation.com.Luna)
local Energy = assert(yatm_cluster_energy.energy)

local case = Luna:new("yatm_cluster_energy.energy")

case:describe("allowed_energy/2", function (t2)
  t2:test("will limit energy by given bandwidth", function (t3)
    t3:assert_eq(Energy.allowed_energy(100, 10), 10)
  end)

  t2:test("will not limit energy given a nil bandwidth", function (t3)
    t3:assert_eq(Energy.allowed_energy(100, nil), 100)
  end)

  t2:test("will return energy if it is less than the given bandwidth", function (t3)
    t3:assert_eq(Energy.allowed_energy(10, 100), 10)
  end)
end)

case:describe("calc_received_energy/2", function (t2)
  t2:test("will calculate energy changes", function (t3)
    local new_energy, actual_amount = Energy.calc_received_energy(15, 10, 10, 20)
    t3:assert_eq(new_energy, 20, "expected new energy to be 20 but got " .. new_energy)
    t3:assert_eq(actual_amount, 5, "expected actual_amount to be lower than the given")
  end)
end)

case:describe("calc_consumed_energy/2", function (t2)
  t2:test("will calculate energy changes", function (t3)
    local new_energy, actual_amount = Energy.calc_consumed_energy(5, 15, 10, 20)
    t3:assert_eq(new_energy, 0, "expected new energy to be 0 but got " .. new_energy)
    t3:assert_eq(actual_amount, 5, "expected actual_amount to be lower than the given")
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
