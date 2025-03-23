local mod = assert(yatm_blasts)

local Subject = assert(mod.BlastsSystem)

local case = foundation.com.Luna:new("yatm_blasts.BlastsSystem")

local test_file = foundation.com.path_join(
  foundation.com.path_join(core.get_worldpath(), "test"),
  "yatm_blasts"
)

case:describe("#init/0", function (t2)
  t2:test("can init a blast system", function (t3)
    local subject = Subject:new{
      filename = test_file
    }

    subject:init()
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
