local suite = yatm_autotest.att:new_suite("YATM Decor")

suite:describe("Jukebox", function (t1)
  t1:setup(t1:method("clear_test_area"))

  t1:test("can place a jukebox", function (t2)
    local pos = vector.new(0, 0, 0)
    local node = { name = "yatm_decor:jukebox_off" }

    minetest.place_node(pos, node)

    t2:yield()
  end)
end)

suite:describe("Meshes", function (t1)
  t1:setup(t1:method("clear_test_area"))

  t1:test("can place dense mesh", function (t2)
    local pos = vector.new(0, 0, 0)
    local node = { name = "yatm_decor:mesh_dense" }

    minetest.place_node(pos, node)

    t2:yield()
  end)

  t1:test("can place wide mesh", function (t2)
    local pos = vector.new(0, 0, 0)
    local node = { name = "yatm_decor:mesh_wide" }

    minetest.place_node(pos, node)

    t2:yield()
  end)
end)

suite:describe("Vents", function (t1)
  t1:setup(t1:method("clear_test_area"))

  t1:test("can place vent block", function (t2)
    local pos = vector.new(0, 0, 0)
    local node = { name = "yatm_decor:vent" }

    minetest.place_node(pos, node)

    t2:yield()
  end)
end)

suite:describe("Warning Checkers", function (t1)
  t1:setup(t1:method("clear_test_area"))
end)

suite:describe("Warning Stripes", function (t1)
  t1:setup(t1:method("clear_test_area"))

  local colors = {"white", "red", "yellow", "fiber"}
  local sizes = {"2x", "4x", "8x"}

  for _,color in ipairs(colors) do
    for _,size in ipairs(sizes) do
      if size ~= "2x" and color == "fiber" then
        -- skip it
      else
        t1:test("can place " .. size .. " " .. color .. " warning stripe", function (t2)
          local pos = vector.new(0, 0, 0)
          local node = { name = "yatm_decor:warning_stripes_" .. size .. "_" .. color }

          minetest.place_node(pos, node)

          t2:yield()
        end)
      end
    end
  end
end)
