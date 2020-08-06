local m = yatm_mesecon_hubs.NetworkMeta
local Luna = assert(foundation.com.Luna)
local FakeMetaRef = assert(foundation.com.FakeMetaRef)

local case = Luna:new("yatm_mesecon_hubs-util")

case:describe("generate_hub_address/0", function (t2)
  t2:test("can generate a hub address", function (t3)
    local a = m.generate_hub_address()
    local b = m.generate_hub_address()

    t3:assert(type(a) == "string")
    t3:assert(type(b) == "string")
    t3:refute_eq(a, b)
  end)
end)

case:describe("get_hub_address/2", function (t2)
  t2:test("can retrieve a hub address given a metaref", function (t3)
    local meta = FakeMetaRef:new({
      mesehub_hub_address = "this_is_my_address",
    })

    t3:assert_eq(m.get_hub_address(meta), "this_is_my_address")
  end)
end)

case:describe("set_hub_address/2", function (t2)
  t2:test("can set a hub address in a meta", function (t3)
    local meta = FakeMetaRef:new({
      mesehub_hub_address = "this_is_my_address",
    })

    m.set_hub_address(meta, "this_is_my_new_address")
    t3:assert_eq(m.get_hub_address(meta), "this_is_my_new_address")
  end)
end)

case:describe("patch_hub_address/2", function (t2)
  t2:test("can fill in a missing hub_address", function (t3)
    local meta = FakeMetaRef:new()

    m.patch_hub_address(meta, "this_is_my_new_address")
    t3:assert_eq(m.get_hub_address(meta), "this_is_my_new_address")
  end)

  t2:test("will not replace an existing hub_address", function (t3)
    local meta = FakeMetaRef:new({
      mesehub_hub_address = "old_address",
    })

    m.patch_hub_address(meta, "this_is_my_new_address")
    t3:assert_eq(m.get_hub_address(meta), "old_address")
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
