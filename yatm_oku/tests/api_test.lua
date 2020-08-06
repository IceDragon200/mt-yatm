local Luna = assert(foundation.com.Luna)
local m = yatm_oku

local case = Luna:new("yatm_oku.API")

case:describe("is_stack_floppy_disk/1", function (t1)
  t1:test("determines if given item stack is a floppy disk", function (t2)
    -- white is guaranteed to exist
    local stack = ItemStack("yatm_oku:floppy_disk_white 1")
    t2:assert(m.is_stack_floppy_disk(stack))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
