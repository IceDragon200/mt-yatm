local suite = yatm_autotest.att:new_suite("YATM Foundry")

suite:describe("Carbon Steel Block", function (t1)
  t1:setup(t1:method("clear_test_area"))

  t1:test("can place a carbon steel block", function (t2)
    local pos = vector.new(0, 0, 0)
    local node = { name = "yatm_foundry:carbon_steel_block" }

    minetest.place_node(pos, node)

    t2:yield()
  end)
end)

suite:describe("Concrete", function (t1)
  t1:setup(t1:method("clear_test_area"))

  local colors = {
    {"white", "White"}
  }

  -- If the dye module is available, use the colors from there instead.
  if dye then
    colors = dye.dyes
  end

  local variants =
    {"bare",
     "dotted",
     "circles",
     "striped",
     "ornated",
     "tiled",
     "meshed",
     "rosy"}

  for _,variant_basename in ipairs(variants) do
    for _,color_pair in ipairs(colors) do
      local color_basename = color_pair[1]

      t1:test("can place a " .. variant_basename .. " concrete block " .. color_basename, function (t2)
        local pos = vector.new(0, 0, 0)
        local node = { name = "yatm_foundry:concrete_" .. variant_basename .. "_" .. color_basename }

        minetest.place_node(pos, node)

        t2:yield()
      end)

      t1:test("can place a " .. variant_basename .. " concrete plate " .. color_basename, function (t2)
        local pos = vector.new(0, 0, 0)
        local node = { name = "yatm_foundry:concrete_plate_" .. variant_basename .. "_" .. color_basename }

        minetest.place_node(pos, node)

        t2:yield()
      end)

      if stairs then
        -- TODO: test for stairs instead
      else
        t1:test("can place a " .. variant_basename .. " concrete slab " .. color_basename, function (t2)
          local pos = vector.new(0, 0, 0)
          local node = { name = "yatm_foundry:concrete_slab_" .. variant_basename .. "_" .. color_basename }

          minetest.place_node(pos, node)

          t2:yield()
        end)
      end
    end
  end
end)
