--
-- YATM Autotest
--
local mod = foundation.new_module("yatm_autotest", "0.0.0")

local Cuboid = assert(foundation.com.Cuboid)
local table_copy = assert(foundation.com.table_copy)

--
-- Autotest Luna
--
local AutotestReporter = {}
function AutotestReporter:report(...)
  print(...)
  minetest.chat_send_all(table.concat({...}, "\t"))
end

local AutotestLuna = assert(foundation.com.Luna):extends()
local ic = AutotestLuna.instance_class

function ic:initialize(...)
  ic._super.initialize(self, ...)
  self.reporter = AutotestReporter
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

function ic:clear_test_area()
  minetest.chat_send_all("Clearing area 16x32x16 for next test")
  self:set_cuboid(Cuboid:new(-8, 0, -8, 16, 32, 16), { name = "air" })
end

function ic:yield(...)
  coroutine.yield(...)
end

function ic:wait(time)
  self:yield("wait", { time })
end

--
-- Autotest
--
local Autotest = foundation.com.Class:extends("Autotest")
local ic = Autotest.instance_class

function ic:initialize()
  self.suites = {}
  self.active = false
  self.running = false
  self.fiber = nil
  self.wait_time = 0
end

function ic:new_suite(name)
  print("New Suite", name)
  local suite = AutotestLuna:new(name)

  table.insert(self.suites, suite)
  return suite
end

function ic:run_suites()
  local autotest = self
  return coroutine.create(function ()
    local active_suites = table_copy(autotest.suites)

    for _,suite in pairs(active_suites) do
      minetest.chat_send_all("Running autotest suite: " .. suite.name)

      suite:execute()
      suite:display_stats()
      suite:maybe_error()
    end
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
    self.fiber = self:run_suites()
    minetest.chat_send_all("YATM Autotest is now running")
  end

  if self.fiber then
    local valid, command, parameters = coroutine.resume(self.fiber)

    if valid then
      if command == "wait" then
        self.wait_time = parameters[1]
      end
    else
      self.fiber = nil
      print(command)
    end
  end
end

local autotest = Autotest:new()

minetest.register_on_shutdown(function ()
  autotest:on_shutdown()
end)

minetest.register_globalstep(function (dtime)
  autotest:update(dtime)
end)

minetest.register_chatcommand("yatm.autotest", {
  params = "<state>",
  description = "Activate yatm autotest framework",
  func = function (player_name, param)
    print(param)
    autotest.active = param == "on"
    print("Autotest.active", autotest.active)
  end
})

yatm_autotest.att = autotest

-- Tests
dofile(yatm_autotest.modpath .. "/tests.lua")
