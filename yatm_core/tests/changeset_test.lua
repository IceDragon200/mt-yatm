local Luna = assert(foundation.com.Luna)
local Changeset = yatm_core.Changeset

local case = Luna:new("yatm_core-Changeset")

local schema = {
  int = {
    type = "integer"
  }
}

case:describe(":new", function (d)
  d:test("can initialize a new changeset", function (t)
    Changeset:new(schema, {})
  end)
end)
