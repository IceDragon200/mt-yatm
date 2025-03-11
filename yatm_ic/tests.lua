local mod = assert(yatm_ic)
local Luna = assert(foundation.com.Luna)

local case = Luna:new("yatm_ic.formspec")

case:describe("render_logic_editor/7", function (t2)
  for name, _ in pairs(mod.TEXTURES) do
    t2:test("can render component="..name, function (t3)
      local map = {
        w = 1,
        h = 1,
        data = {
          name,
        }
      }
      local state = {
        --- This covers all cases, as most components only have a maximum of 3 parameters
        {
          x = nil,
          y = nil,
          t = nil,
        }
      }
      mod.formspec.render_logic_editor("test_ic", 0, 0, 1, 1, map, state)
    end)
  end
end)

case:execute()
case:display_stats()
case:maybe_error()
