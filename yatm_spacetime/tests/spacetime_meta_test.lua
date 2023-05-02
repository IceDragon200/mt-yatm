local HeadlessMetaDataRef = assert(foundation.com.headless.MetaDataRef)

local m = yatm_spacetime.SpacetimeMeta
local Luna = assert(foundation.com.Luna)

local case = Luna:new("yatm_spacetime.SpacetimeMeta")

case:describe("get_address/2", function (t2)
  t2:test("can retrieve an address given a metaref", function (t3)
    local meta = HeadlessMetaDataRef:new({
      spaddr_address = "this_is_my_address",
    })

    t3:assert_eq(m.get_address(meta), "this_is_my_address")
  end)
end)

case:describe("set_address/2", function (t2)
  t2:test("can set an address in a meta", function (t3)
    local meta = HeadlessMetaDataRef:new({
      spaddr_address = "this_is_my_address",
    })

    m.set_address(meta, "this_is_my_new_address")
    t3:assert_eq(m.get_address(meta), "this_is_my_new_address")
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
