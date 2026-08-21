local Luna = assert(foundation.com.Luna)
local M = yatm_oku.Computers

local case = Luna:new("yatm_oku.Computers")

case:describe("&new/1", function (t2)
  t2:test("can initialize a new instance an instance of the computers context without a root dir", function (t3)
    local _m = M:new()
  end)
end)

case:describe("#create_computer/2", function (t2)
  t2:test("can create a new computer instance", function (t3)
    local m = M:new()

    local s = m:create_computer("a_secret", {})
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
