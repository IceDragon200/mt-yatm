local Luna = assert(yatm.Luna)

local FluidStack = assert(yatm_fluids.FluidStack)
local FluidContainers = assert(yatm_fluids.FluidContainers)

local case = Luna:new("yatm.fluids.FluidContainers")

case:describe("is_fluid_container/1", function (t2)
  t2:test("can confirm that an item is a fluid container", function (t3)
    local bogus_item = ItemStack("_:dont_exist")
    t3:assert_eq(FluidContainers.is_fluid_container(bogus_item), false)

    local empty_bucket = ItemStack("yatm_fluids:empty_bucket")
    t3:assert_eq(FluidContainers.is_fluid_container(empty_bucket), true, "expected empty buckets to be fluid container")

    local crude_oil_bucket = ItemStack("yatm_fluids:bucket_crude_oil")
    t3:assert_eq(FluidContainers.is_fluid_container(crude_oil_bucket), true)
  end)
end)

case:describe("is_empty/1", function (t2)
  t2:test("can confirm that an item is a fluid container and empty", function (t3)
    local bogus_item = ItemStack("_:dont_exist")
    t3:assert_eq(FluidContainers.is_empty(bogus_item), true)

    local empty_bucket = ItemStack("yatm_fluids:empty_bucket")
    t3:assert_eq(FluidContainers.is_empty(empty_bucket), true, "expected empty buckets to be empty")

    local crude_oil_bucket = ItemStack("yatm_fluids:bucket_crude_oil")
    t3:assert_eq(FluidContainers.is_empty(crude_oil_bucket), false)
  end)
end)

case:describe("get_fluid_stack/1", function (t2)
  t2:test("can retrieve a fluid stack from the fluid container", function (t3)
    local bogus_item = ItemStack("_:dont_exist")
    t3:assert_matches(FluidContainers.get_fluid_stack(bogus_item), nil)

    local empty_bucket = ItemStack("yatm_fluids:empty_bucket")
    t3:assert_matches(FluidContainers.get_fluid_stack(empty_bucket), {
      name = nil,
      amount = 0,
    })

    local crude_oil_bucket = ItemStack("yatm_fluids:bucket_crude_oil")
    t3:assert_matches(FluidContainers.get_fluid_stack(crude_oil_bucket), {
      name = "yatm_fluids:crude_oil",
      amount = 1000,
    })
  end)
end)

case:describe("set_fluid_stack/3", function (t2)
  t2:test("can set a fluid stack in a fluid container", function (t3)
    local bucket = ItemStack("yatm_fluids:empty_bucket")

    local a, b = FluidContainers.set_fluid_stack(
      bucket,
      FluidStack.new("yatm_fluids:crude_oil", 1000),
      true
    )

    t3:assert_matches(bucket:get_name(), "yatm_fluids:bucket_crude_oil")

    t3:assert_matches(a, {
      name = "yatm_fluids:crude_oil",
      amount = 1000,
    })

    t3:assert_matches(b, {
      name = "yatm_fluids:crude_oil",
      amount = 1000,
    })

    local a, b = FluidContainers.set_fluid_stack(
      bucket,
      FluidStack.new(nil, 0),
      true
    )

    t3:assert_matches(bucket:get_name(), "yatm_fluids:empty_bucket")

    t3:assert_matches(a, {
      name = nil,
      amount = 0,
    })

    t3:assert_matches(b, {
      name = nil,
      amount = 0,
    })
  end)

  t2:test("can handle oversetting fluid", function (t3)
    local bucket = ItemStack("yatm_fluids:empty_bucket")

    local a, b = FluidContainers.set_fluid_stack(
      bucket,
      FluidStack.new("yatm_fluids:crude_oil", 2000),
      true
    )

    t3:assert_matches(bucket:get_name(), "yatm_fluids:bucket_crude_oil")

    t3:assert_matches(a, {
      name = "yatm_fluids:crude_oil",
      amount = 1000,
    })

    t3:assert_matches(b, {
      name = "yatm_fluids:crude_oil",
      amount = 1000,
    })

    local a, b = FluidContainers.set_fluid_stack(
      bucket,
      FluidStack.new(nil, 0),
      true
    )

    t3:assert_matches(bucket:get_name(), "yatm_fluids:empty_bucket")

    t3:assert_matches(a, {
      name = nil,
      amount = 0,
    })

    t3:assert_matches(b, {
      name = nil,
      amount = 0,
    })
  end)
end)

case:describe("decrease_fluid/3", function (t2)
  t2:test("cannot partially decrease the fluid in a static container", function (t3)
    local bucket = ItemStack("yatm_fluids:bucket_crude_oil")

    local a, b = FluidContainers.decrease_fluid(
      bucket,
      FluidStack.new("yatm_fluids:crude_oil", 500),
      true
    )

    t3:assert_matches(a, {
      amount = 0,
    })
    t3:assert_matches(b, {
      name = "yatm_fluids:crude_oil",
      amount = 500,
    })
  end)

  t2:test("can properly decrease fluid completely in a static container", function (t3)
    local bucket = ItemStack("yatm_fluids:bucket_crude_oil")

    local a, b = FluidContainers.decrease_fluid(
      bucket,
      FluidStack.new("yatm_fluids:crude_oil", 1000),
      true
    )

    t3:assert_matches(a, {
      name = "yatm_fluids:crude_oil",
      amount = 1000,
    })
    t3:assert_matches(b, {
      name = nil,
      amount = 0,
    })
  end)
end)

case:describe("increase_fluid/3", function (t2)
  t2:test("cannot partially increase the fluid in a static container", function (t3)
    local bucket = ItemStack("yatm_fluids:empty_bucket")

    local a, b = FluidContainers.increase_fluid(
      bucket,
      FluidStack.new("yatm_fluids:crude_oil", 500),
      true
    )

    t3:assert_matches(a, {
      amount = 0,
    })
    t3:assert_matches(b, {
      name = nil,
      amount = 0,
    })
  end)

  t2:test("can fully increase the fluid in a static container", function (t3)
    local bucket = ItemStack("yatm_fluids:empty_bucket")

    local a, b = FluidContainers.increase_fluid(
      bucket,
      FluidStack.new("yatm_fluids:crude_oil", 1000),
      true
    )

    t3:assert_eq(bucket:get_name(), "yatm_fluids:bucket_crude_oil")

    t3:assert_matches(a, {
      name = "yatm_fluids:crude_oil",
      amount = 1000,
    })
    t3:assert_matches(b, {
      name = "yatm_fluids:crude_oil",
      amount = 1000,
    })
  end)
end)

case:describe("drain_fluid/3", function (t2)
  t2:test("cannot partially decrease the fluid in a static container", function (t3)
    local bucket = ItemStack("yatm_fluids:bucket_crude_oil")

    local a, b = FluidContainers.drain_fluid(
      bucket,
      FluidStack.new(nil, 0),
      true
    )

    t3:assert_matches(a, {
      amount = 0,
    })
    t3:assert_matches(b, {
      name = "yatm_fluids:crude_oil",
      amount = 500,
    })

    local a, b = FluidContainers.drain_fluid(
      bucket,
      FluidStack.new("yatm_fluids:crude_oil", 500),
      true
    )

    t3:assert_matches(a, {
      amount = 0,
    })
    t3:assert_matches(b, {
      name = "yatm_fluids:crude_oil",
      amount = 500,
    })
  end)

  t2:test("can properly decrease fluid completely in a static container", function (t3)
    local bucket = ItemStack("yatm_fluids:bucket_crude_oil")

    local a, b = FluidContainers.drain_fluid(
      bucket,
      FluidStack.new("yatm_fluids:crude_oil", 1000),
      true
    )

    t3:assert_matches(a, {
      name = "yatm_fluids:crude_oil",
      amount = 1000,
    })
    t3:assert_matches(b, {
      name = nil,
      amount = 0,
    })
  end)
end)

case:describe("fill_fluid/3", function (t2)
  t2:test("cannot partially increase the fluid in a static container", function (t3)
    local bucket = ItemStack("yatm_fluids:empty_bucket")

    local a, b = FluidContainers.fill_fluid(
      bucket,
      FluidStack.new("yatm_fluids:crude_oil", 500),
      true
    )

    t3:assert_matches(a, {
      amount = 0,
    })
    t3:assert_matches(b, {
      name = nil,
      amount = 0,
    })
  end)

  t2:test("can fully increase the fluid in a static container", function (t3)
    local bucket = ItemStack("yatm_fluids:empty_bucket")

    local a, b = FluidContainers.fill_fluid(
      bucket,
      FluidStack.new("yatm_fluids:crude_oil", 1000),
      true
    )

    t3:assert_eq(bucket:get_name(), "yatm_fluids:bucket_crude_oil")

    t3:assert_matches(a, {
      name = "yatm_fluids:crude_oil",
      amount = 1000,
    })
    t3:assert_matches(b, {
      name = "yatm_fluids:crude_oil",
      amount = 1000,
    })
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()

error("NOPE")
