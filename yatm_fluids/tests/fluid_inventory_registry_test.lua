local Luna = assert(yatm.Luna)

local FluidInventoryRegistry = assert(yatm_fluids.FluidInventoryRegistry)

local FluidStack = assert(yatm.fluids.FluidStack)

local case = Luna:new("yatm.fluids.FluidInventoryRegistry")

case:describe("create_fluid_inventory/3", function (t2)
  t2:test("can create a new fluid inventory", function (t3)
    local fim = FluidInventoryRegistry:new()

    fim:create_fluid_inventory("yatm_fluids:test_inventory", 256, 16000)
  end)
end)

case:describe("get_fluid_inventory/1", function (t2)
  t2:test("can retrieve a fluid inventory by name", function (t3)
    local fim = FluidInventoryRegistry:new()

    fim:create_fluid_inventory("yatm_fluids:test_inventory", 256, 16000)

    local fi = fim:get_fluid_inventory("yatm_fluids:test_inventory")

    t3:assert(fi)
    t3:asser_eq("yatm_fluids:test_inventory", fi.name)
  end)

  t2:test("returns nil if an inventory does not exist", function (t3)
    local fim = FluidInventoryRegistry:new()

    local fi = fim:get_fluid_inventory("yatm_fluids:test_inventory")

    t3:refute(fi)
  end)
end)

case:describe("destroy_fluid_inventory/1", function (t2)
  t2:test("can remove an inventory by name", function (t3)
    local fim = FluidInventoryRegistry:new()

    fim:create_fluid_inventory("yatm_fluids:test_inventory", 256, 16000)

    local fi = fim:get_fluid_inventory("yatm_fluids:test_inventory")
    t3:assert(fi)

    fim:destroy_fluid_inventory("yatm_fluids:test_inventory")

    local fi = fim:get_fluid_inventory("yatm_fluids:test_inventory")
    t3:refute(fi)
  end)
end)
