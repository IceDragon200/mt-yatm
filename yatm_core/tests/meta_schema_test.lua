local MetaSchema = assert(yatm_core.MetaSchema)
local Luna = assert(yatm_core.Luna)

local case = Luna:new("yatm_core.MetaSchema")

case:describe(".new/3", function (t2)
  t2:test("accepts a schema of scalar types", function (t3)
    local meta_schema = MetaSchema:new("test.schema", "", {
      x = { type = "integer" },
      name = { type = "string" },
      delta = { type = "float" },
    })

    t3:assert(meta_schema)
    t3:assert_eq(meta_schema.name, "test.schema")
    t3:assert_eq(meta_schema.prefix, "")
  end)
end)

case:describe(":compile/1", function (t2)
  t2:setup_all(function (tags)
    tags.meta_schema = MetaSchema:new("test.schema", "", {
      x = { type = "integer" },
      name = { type = "string" },
      delta = { type = "float" },
    })
    return tags
  end)

  t2:test("compiles a MetaSchema into a fixed schema", function (t3, tags)
    local schema = tags.meta_schema:compile("base_")

    t3:assert(schema.set_x)
    t3:assert(schema.get_x)
    t3:assert(schema.set_name)
    t3:assert(schema.get_name)
    t3:assert(schema.set_delta)
    t3:assert(schema.get_delta)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
