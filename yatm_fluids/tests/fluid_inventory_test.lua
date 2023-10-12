local Luna = assert(yatm.Luna)

local FluidInventory = assert(yatm_fluids.FluidInventory)

local FluidStack = assert(yatm.fluids.FluidStack)

local case = Luna:new("yatm.fluids.FluidInventory")

case:describe("#new/3", function (t2)
  t2:test("creates a new fluid inventory object", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory", 256, 16000)

    t3:assert(fi)
  end)
end)

case:describe("#is_empty/0", function (t2)
  t2:test("reports if a fluid inventory is empty", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory")

    fi:set_size("main", 256)
    fi:set_max_stack_size("main", 16000)

    -- new inventorys should be empty
    t3:assert(fi:is_empty("main"))
  end)

  t2:test("will report false if the inventory contains fluids", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory")
    fi:set_size("main", 256)
    fi:set_max_stack_size("main", 16000)

    t3:assert(fi:is_empty("main"))

    fi:add_fluid_stack("main", FluidStack.new("yatm_fluids:crude_oil", 100))

    t3:refute(fi:is_empty("main"))
  end)
end)

case:describe("#set_fluid_stack/2", function (t2)
  t2:test("set fluid stack at specified index", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory")
    fi:set_size("main", 256)
    fi:set_max_stack_size("main", 16000)

    fi:set_fluid_stack("main", 1, FluidStack.new("yatm_fluids:crude_oil", 100))
    local fs = fi:get_fluid_stack("main", 1)

    t3:assert_eq("yatm_fluids:crude_oil", fs.name)
    t3:assert_eq(100, fs.amount)
  end)

  t2:test("setting nil will clear a specified slot", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory")
    fi:set_size("main", 256)
    fi:set_max_stack_size("main", 16000)

    fi:set_fluid_stack("main", 1, FluidStack.new("yatm_fluids:crude_oil", 100))
    local fs = fi:get_fluid_stack("main", 1)

    t3:assert_eq("yatm_fluids:crude_oil", fs.name)
    t3:assert_eq(100, fs.amount)

    fi:set_fluid_stack("main", 1, nil)
    local fs = fi:get_fluid_stack("main", 1)
    t3:refute(fs.name)
  end)
end)

case:describe("#add_fluid_stack/1", function (t2)
  t2:test("will add a fluid stack fo an inventory", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory")
    fi:set_size("main", 256)
    fi:set_max_stack_size("main", 16000)

    fi:add_fluid_stack("main", FluidStack.new("yatm_fluids:crude_oil", 100))

    local fs = fi:get_fluid_stack("main", 1)

    t3:assert_eq("yatm_fluids:crude_oil", fs.name)
    t3:assert_eq(100, fs.amount)
  end)

  t2:test("will not replace an existing slot if the fluids do not match", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory")
    fi:set_size("main", 256)
    fi:set_max_stack_size("main", 16000)

    fi:add_fluid_stack("main", FluidStack.new("yatm_fluids:crude_oil", 100))
    fi:add_fluid_stack("main", FluidStack.new("yatm_fluids:heavy_oil", 300))

    local fs = fi:get_fluid_stack("main", 1)

    t3:assert_eq("yatm_fluids:crude_oil", fs.name)
    t3:assert_eq(100, fs.amount)

    local fs = fi:get_fluid_stack("main", 2)

    t3:assert_eq("yatm_fluids:heavy_oil", fs.name)
    t3:assert_eq(300, fs.amount)
  end)

  t2:test("will not occupy a new slot if an existing slot has enough capacity", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory")
    fi:set_size("main", 256)
    fi:set_max_stack_size("main", 16000)

    fi:add_fluid_stack("main", FluidStack.new("yatm_fluids:crude_oil", 100))
    fi:add_fluid_stack("main", FluidStack.new("yatm_fluids:crude_oil", 100))

    local fs = fi:get_fluid_stack("main", 1)

    t3:assert_eq("yatm_fluids:crude_oil", fs.name)
    t3:assert_eq(200, fs.amount)
  end)

  t2:test("will rollover if amount exceeds available capacity", function (t3)
    local fs
    local fi = FluidInventory:new("yatm_fluids:test_inventory")
    fi:set_size("main", 256)
    fi:set_max_stack_size("main", 16000)

    fi:add_fluid_stack("main", FluidStack.new("yatm_fluids:crude_oil", 12000))
    fi:add_fluid_stack("main", FluidStack.new("yatm_fluids:crude_oil", 12000))

    fs = fi:get_fluid_stack("main", 1)

    t3:assert_eq("yatm_fluids:crude_oil", fs.name)
    t3:assert_eq(16000, fs.amount)

    fs = fi:get_fluid_stack("main", 2)
    t3:assert_eq("yatm_fluids:crude_oil", fs.name)
    t3:assert_eq(8000, fs.amount)
  end)
end)

case:describe("#to_table/0", function (t2)
  t2:test("can dump a FluidInventory to a table", function (t3)
    local fi = FluidInventory:new("yatm_fluids:test_inventory")

    local tab = fi:to_table()

    t3:assert_eq(type(tab), "table")
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
