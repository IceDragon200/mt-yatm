local Luna = assert(yatm.Luna)

local FluidInventory = assert(yatm_fluids.FluidInventory)

local FluidStack = assert(yatm.fluids.FluidStack)

local case = Luna:new("yatm.fluids.FluidInventory")

case:describe("new/3", function (t2)
  t2:test("creates a new fluid inventory object", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory", 256, 16000)

    t3:assert(fi)
  end)
end)

case:describe("is_empty/0", function (t2)
  t2:test("reports if a fluid inventory is empty", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory", 256, 16000)

    -- new inventorys should be empty
    t3:assert(fi:is_empty())
  end)

  t2:test("will report false if the inventory contains fluids", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory", 256, 16000)

    t3:assert(fi:is_empty())

    fi:add_fluid_stack(FluidStack.new("default:water", 100))

    t3:refute(fi:is_empty())
  end)
end)

case:describe("set_fluid_stack/2", function (t2)
  t2:test("set fluid stack at specified index", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory", 256, 16000)

    fi:set_fluid_stack(1, FluidStack.new("default:water", 100))
    local fs = fi:get_fluid_stack(1)

    t3:assert_eq("default:water", fs.name)
    t3:assert_eq(100, fs.amount)
  end)

  t2:test("setting nil will clear a specified slot", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory", 256, 16000)

    fi:set_fluid_stack(1, FluidStack.new("default:water", 100))
    local fs = fi:get_fluid_stack(1)

    t3:assert_eq("default:water", fs.name)
    t3:assert_eq(100, fs.amount)

    fi:set_fluid_stack(1, nil)
    local fs = fi:get_fluid_stack(1)
    t3:refute(fs)
  end)
end)

case:describe("add_fluid_stack/1", function (t2)
  t2:test("will add a fluid stack fo an inventory", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory", 256, 16000)

    fi:add_fluid_stack(FluidStack.new("default:water", 100))

    local fs = fi:get_fluid_stack(1)

    t3:assert_eq("default:water", fs.name)
    t3:assert_eq(100, fs.amount)
  end)

  t2:test("will not replace an existing slot if the fluids do not match", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory", 256, 16000)

    fi:add_fluid_stack(FluidStack.new("default:water", 100))
    fi:add_fluid_stack(FluidStack.new("default:lava", 300))

    local fs = fi:get_fluid_stack(1)

    t3:assert_eq("default:water", fs.name)
    t3:assert_eq(100, fs.amount)

    local fs = fi:get_fluid_stack(2)

    t3:assert_eq("default:lava", fs.name)
    t3:assert_eq(300, fs.amount)
  end)

  t2:test("will not occupy a new slot if an existing slot has enough capacity", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory", 256, 16000)

    fi:add_fluid_stack(FluidStack.new("default:water", 100))
    fi:add_fluid_stack(FluidStack.new("default:water", 100))

    local fs = fi:get_fluid_stack(1)

    t3:assert_eq("default:water", fs.name)
    t3:assert_eq(200, fs.amount)
  end)

  t2:test("will rollover if amount exceeds available capacity", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory", 256, 16000)

    fi:add_fluid_stack(FluidStack.new("default:water", 12000))
    fi:add_fluid_stack(FluidStack.new("default:water", 12000))

    local fs = fi:get_fluid_stack(1)

    t3:assert_eq("default:water", fs.name)
    t3:assert_eq(16000, fs.amount)

    local fs = fi:get_fluid_stack(2)
    t3:assert_eq("default:water", fs.name)
    t3:assert_eq(8000, fs.amount)
  end)
end)
