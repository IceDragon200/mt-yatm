--[[
Luna is a test framework to replace knife.test, this has been extracted from my own personal project for use in minetest.

You are free to copy and use this module/class
]]
local Luna = yatm_core.Class.extends()

local c = Luna.instance_class

function c:initialize(name)
  self.name = name
  self.stats = {
    time_elapsed = 0.0,
    assertions_passed = 0,
    assertions_failed = 0,
    tests_passed = 0,
    tests_failed = 0,
  }
  self.tests = {}
  self.children = {}
  self.setup_callbacks = {}
  self.setup_all_callbacks = {}
end

function c:setup(callback)
  table.insert(self.setup_callbacks, callback)
end

function c:setup_all(callback)
  table.insert(self.setup_all_callbacks, callback)
end

function c:describe(name, func)
  local luna = Luna.new(name)
  table.insert(self.tests, {"describe", name, luna})
  table.insert(self.children, luna)
  func(luna)
  return luna
end

function c:test(name, func)
  table.insert(self.tests, {"test", name, func})
  return self
end

function c:assert(truth_value, message)
  message = message or "expected value to be truthy"
  if truth_value then
    self.stats.assertions_passed = self.stats.assertions_passed + 1
  else
    self.stats.assertions_failed = self.stats.assertions_failed + 1
    error("assertion failed: " .. message)
  end
end

function c:assert_eq(a, b, message)
  message = message or ("expected " .. dump(a) .. " to be equal to " .. dump(b))
  self:assert(a == b, message)
end

function c:assert_neq(a, b, message)
  message = message or ("expected " .. dump(a) .. " to not be equal to " .. dump(b))
  self:assert(a ~= b, message)
end

function c:assert_table_eq(a, b, message)
  message = message or ("expected " .. dump(a) .. " to be equal to " .. dump(b))
  self:assert(yatm_core.table_equals(a, b), message)
end

function c:assert_in(item, list, message)
  message = message or ("expected " .. dump(item) .. " to be included in " .. dump(list))
  self:assert(yatm_core.table_includes_value(list, item), message)
end

function c:refute(truth_value, message)
  return self:assert(not truth_value, message)
end

function c:refute_eq(a, b, message)
  message = message or ("expected " .. dump(a) .. " to not be equal to " .. dump(b))
  self:refute(a == b, message)
end

function c:execute(depth, prefix, tags)
  tags = yatm_core.table_copy(tags or {})
  depth = depth or 0
  prefix = prefix or self.name
  for _,callback in ipairs(self.setup_all_callbacks) do
    tags = callback(tags)
  end
  for _,test in ipairs(self.tests) do
    local test_tags = yatm_core.table_copy(tags)
    for _,callback in ipairs(self.setup_callbacks) do
      test_tags = callback(test_tags)
    end
    if test[1] == "describe" then
      local prefix2 = prefix .. "  " .. test[2]
      test[3]:execute(depth + 1, prefix2, test_tags)
    elseif test[1] == "test" then
      local test_func = test[3]
      --print("* " .. prefix, test[2])
      local x_us = minetest.get_us_time()
      local success, err = xpcall(test_func, debug.traceback, self, test_tags)
      local y_us = minetest.get_us_time()
      local diff_us = y_us - x_us
      local diff = diff_us / 1000000.0
      local elapsed = yatm_core.format_pretty_unit(diff, "s")
      if success then
        print("* O " .. prefix, test[2], "OK", elapsed)
        self.stats.tests_passed = self.stats.tests_passed + 1
      else
        print("* X " .. prefix, test[2], "ERROR", elapsed, "\n\t" .. err)
        self.stats.tests_failed = self.stats.tests_failed + 1
      end
    end
  end
  return self
end

function c:bake_stats()
  local stats = {
    assertions_passed = self.stats.assertions_passed,
    assertions_failed = self.stats.assertions_failed,
    tests_passed = self.stats.tests_passed,
    tests_failed = self.stats.tests_failed,
  }

  for _, luna in ipairs(self.children) do
    local baked_stats = luna:bake_stats()
    stats.assertions_passed = stats.assertions_passed + baked_stats.assertions_passed
    stats.assertions_failed = stats.assertions_failed + baked_stats.assertions_failed
    stats.tests_passed = stats.tests_passed + baked_stats.tests_passed
    stats.tests_failed = stats.tests_failed + baked_stats.tests_failed
  end

  return stats
end

function c:display_stats()
  local stats = self:bake_stats()
  local total_tests = stats.tests_passed + stats.tests_failed
  local total_assertions = stats.assertions_passed + stats.assertions_failed
  print("\n")
  print(stats.tests_passed .. " passed", stats.tests_failed .. " failed", total_tests .. " total")
  print(stats.assertions_passed .. " assertions passed", stats.assertions_failed .. " assertions failed", total_assertions .. " total assertions")
  print("\n")
  return self
end

function c:maybe_error()
  local stats = self:bake_stats()
  if stats.tests_failed > 0 then
    error("one or more tests have failed")
  end
  return self
end

yatm_core.Luna = Luna
