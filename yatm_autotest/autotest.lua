local Cuboid = assert(foundation.com.Cuboid)
local table_copy = assert(foundation.com.table_copy)
local table_merge = assert(foundation.com.table_merge)
local table_keys = assert(foundation.com.table_keys)
local list_sort = assert(foundation.com.list_sort)
local string_pad_leading = assert(foundation.com.string_pad_leading)

--
-- Autotest Luna
--
local AutotestReporter = {}

function AutotestReporter:report(...)
  print(...)
  minetest.chat_send_all(table.concat({...}, "\t"))
end

-- @class AutotestSuite
local AutotestSuite = foundation.com.Class:extends("AutotestSuite")
do
  local ic = AutotestSuite.instance_class

  --- @spec #initialize(): void
  function ic:initialize(name)
    ic._super.initialize(self)

    -- @member reporter: Table
    self.reporter = AutotestReporter

    -- @member name: String
    self.name = name

    -- @member m_properties: Table
    self.m_properties = {}

    -- @member m_models: Table
    self.m_models = {}
  end

  --- @spec #define_property(name: String, def: Table): void
  function ic:define_property(name, def)
    assert(type(name) == "string", "expected a property name")

    if not def.tests then
      error("expected tests for property_name=" .. name)
    end

    self.m_properties[name] = def
  end

  --- @spec #import_properties(AutotestSuite): void
  function ic:import_properties(other)
    for property_name, property in pairs(other.m_properties) do
      self.m_properties[property_name] = property
    end
  end

  --- @spec #import_property(AutotestSuite, name: String): void
  function ic:import_property(other, property_name)
    local prop = assert(other.m_properties[property_name])
    self.m_properties[property_name] = prop
  end

  --- @spec #define_model(name: String, def: Table): void
  function ic:define_model(name, def)
    assert(type(name) == "string", "expected a model name")
    self.m_models[name] = def
  end

  function ic:set_cuboid(cuboid, node)
    local positions = {}
    local y2 = cuboid.y + cuboid.h
    local z2 = cuboid.z + cuboid.d
    local x2 = cuboid.x + cuboid.w
    for y = cuboid.y,y2 do
      for z = cuboid.z,z2 do
        for x = cuboid.x,x2 do
          table.insert(positions, vector.new(x, y, z))
        end
      end
    end

    minetest.bulk_set_node(positions, node)
  end

  function ic:clear_test_area(center_pos)
    center_pos = center_pos or { x = 0, y = 0, z = 0 }
    minetest.chat_send_all("Clearing area 16x32x16 for next test")
    local cuboid =
      Cuboid.new(
        center_pos.x - 8,
        center_pos.y - 8,
        center_pos.z - 8,
        16,
        32,
        16
      )

    self:set_cuboid(cuboid, { name = "air" })
  end

  function ic:yield(...)
    return coroutine.yield(...)
  end

  function ic:wait(time)
    return self:yield("wait", { time })
  end

  function ic:main(depth)
    local model_names = list_sort(table_keys(self.m_models))

    for _, model_name in ipairs(model_names) do
      local model = self.m_models[model_name]
      print(string_pad_leading("", depth, "\t") .. model_name)

      for _, item in ipairs(model.properties) do
        local property_name = item.property
        local property = self.m_properties[property_name]

        if not property then
          error("property not found property_name=" .. property_name)
        end

        print(string_pad_leading("", depth + 1, "\t") .. property_name)

        local all_state = table_merge(model.state or {}, item.state or {})

        if property.setup_all then
          property.setup_all(self, all_state)
        end

        assert(property.tests, "expected tests")

        local test_names = list_sort(table_keys(property.tests))

        for _, test_name in ipairs(test_names) do
          self:yield() -- yield at least once before each test

          local test_func = property.tests[test_name]
          local test_state = table_copy(all_state)

          if property.setup then
            property.setup(self, test_state)
          end

          print(string_pad_leading("", depth + 2, "\t") .. test_name)

          local success, err = xpcall(function ()
            test_func(self, test_state)
          end, debug.traceback)

          if success then
            print(string_pad_leading("", depth + 3, "\t") .. "OK")
          else
            print(string_pad_leading("", depth + 3, "\t") .. "FAILED " .. err)
          end

          if property.teardown then
            property.teardown(self, test_state)
          end

          self:yield() -- yield at least once after every test
        end

        if property.teardowm_all then
          property.teardowm_all(self, all_state)
        end
      end
    end
  end
end

--
-- Autotest
--

-- @class Autotest
local Autotest = foundation.com.Class:extends("Autotest")
do
  local ic = Autotest.instance_class

  -- @spec #initialize(): void
  function ic:initialize()
    self.suites = {}
    self.only = nil
    self.active = false
    self.running = false
    self.fiber = nil
    self.wait_time = 0
  end

  function ic:only_run(name)
    if not self.only then
      self.only = {}
    end
    table.insert(self.only, name)
  end

  function ic:activate()
    self.active = true
  end

  -- @spec #new_suite(): Suite
  function ic:new_suite(name)
    print("New Suite", name)
    local suite = AutotestSuite:new(name)

    table.insert(self.suites, suite)
    return suite
  end

  function ic:run_suites()
    local autotest = self
    return coroutine.create(function ()
      local active_suites = table_copy(autotest.suites)

      for _,suite in pairs(active_suites) do
        minetest.chat_send_all("Running autotest suite: " .. suite.name)

        local should_run = true

        if self.only then
          should_run = false

          for _, name in ipairs(self.only) do
            if suite.name == name then
              should_run = true
              break
            end
          end
        end

        if should_run then
          print(suite.name)

          local success, err = xpcall(function ()
            suite:main(1)
          end, debug.traceback)

          if success then
            -- nothing to do here
            print("\tSUITE OK")
          else
            print("\tSUITE FAILED: " .. err)
          end
        end
      end

      coroutine.yield("finalize", {})
    end)
  end

  function ic:on_shutdown()
    print("Autotest", "shutdown")
  end

  function ic:update(dtime)
    if not self.active then
      return
    end

    if self.wait_time > 0 then
      self.wait_time = math.max(self.wait_time - dtime, 0)
      return
    end

    if not self.running then
      self.running = true
      self.co = self:run_suites()
      minetest.chat_send_all("YATM Autotest is now running")
      print("YATM Autotest is now running")
    end

    if self.co then
      local valid, command, parameters = coroutine.resume(self.co, dtime)

      if valid then
        if command then
          self["command_" .. command](self, unpack(parameters))
        end
      else
        self.co = nil
        error(command)
      end
    end
  end

  function ic:command_finalize()
    self.active = false
    self.running = false
  end

  function ic:command_wait(time)
    self.wait_time = time
  end
end

Autotest.Suite = AutotestSuite

yatm_autotest.Autotest = Autotest
