local clusters = assert(yatm.clusters)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local hash_node_position = assert(minetest.hash_node_position)
local table_sample = assert(foundation.com.table_sample)
local Vector3 = assert(foundation.com.Vector3)
--
local EnergyDevices = assert(yatm.energy.EnergyDevices)

-- local random_energy_provider = yatm_machines.autotest_suite.utils.random_energy_provider
local wait_for_next_tick_on_clusters = yatm_machines.autotest_suite.utils.wait_for_next_tick_on_clusters
local set_node_to_air = yatm_machines.autotest_suite.utils.set_node_to_air
local random_pos = yatm_machines.autotest_suite.utils.random_pos

yatm_energy_storage_array.autotest_suite:define_property("is_array_energy_controller", {
  description = "Is Array Energy Controller",
  detail = [[
  The device is an array energy controller
  ]],

  setup = function (suite, state)
    state.pos = random_pos()
    state.node_id = hash_node_position(state.pos)
    minetest.set_node(state.pos, assert(state.node))

    return state
  end,

  tests = {
    ["Will create a device network on construction"] = function (suite, state)
      -- so the controller will need at least one cell to be considered "up" for leadership
      -- for this test, the creative cell is being used, since it will always report having
      -- energy
      local cell_name = "yatm_energy_storage_array:array_energy_cell_creative"
      local cell_pos = Vector3.add({}, state.pos, { x = 0, y = 0, z = 1 })

      minetest.set_node(cell_pos, { name = cell_name })

      -- wait for network - to resolve first stage events
      wait_for_next_tick_on_clusters(suite, state, 2.0)
      -- wait for network again - to resolve refresh stage events
      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local cluster = cluster_devices:get_node_cluster(state.pos)

      if not cluster then
        error("device cluster not available")
      end

      if cluster:size() ~= 2 then
        error("expected only 2 devices to be in cluster")
      end

      local node_entry = cluster:get_node(state.pos)
      local nodedef = minetest.registered_nodes[node_entry.node.name]

      if not nodedef.groups.yatm_cluster_device then
        error("expected to be part of the yatm_cluster_device node group")
      end

      if not node_entry.groups["device_controller"] then
        error("invalid array energy controller, expected to be in device_controller group")
      end

      if cluster.assigns.controller_state ~= "up" then
        error("cluster is expected to be up (got " .. cluster.assigns.controller_state .. ")")
      end

      if not cluster.assigns.controller_id then
        error("expected a controller_id to be present")
      end

      if cluster.assigns.controller_id ~= state.node_id then
        error("device node was expected to be controller of cluster (expected " ..
          state.node_id .. ", got " .. cluster.assigns.controller_id .. ")")
      end
    end,

    ["Will teardown network upon node removal"] = function (suite, state)
      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local cluster = cluster_devices:get_node_cluster(state.pos)

      if not cluster then
        error("device cluster not available")
      end

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      set_node_to_air(state.pos)

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local node = minetest.get_node(state.pos)

      if node.name ~= "air" then
        error("node should have been air (got " .. node.name .. " instead)")
      end

      cluster = cluster_devices:get_node_cluster(state.pos)

      if cluster then
        error("cluster should have been removed (id " .. cluster.id .. ")")
      end
    end,

    ["Will pair with array energy cells"] = function (suite, state)
      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local cell_name = "yatm_energy_storage_array:array_energy_cell_stage0"
      local cell_center = Vector3.add({}, state.pos, { x = 0, y = 0, z = 2 })

      for z = -1,1 do
        for x = -1,1 do
          local cell_pos = Vector3.add({}, cell_center, { x = x, y = 0, z = z })

          minetest.set_node(cell_pos, { name = cell_name })
        end
      end

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local node = minetest.get_node_or_nil(state.pos)

      local en = EnergyDevices.get_usable_stored_energy(state.pos, node)
      assert(en == 0, "expected no energy to be stored yet")

      local cluster = cluster_devices:get_node_cluster(state.pos)
      local count = cluster:count_nodes_of_group("array_energy_cell")
      assert(count == 9, "expected to be 9 energy cells")

      local used = EnergyDevices.receive_energy(state.pos, node, 90, 1.0)
      assert(used == 90, "expected to use all given energy")

      en = EnergyDevices.get_usable_stored_energy(state.pos, node)
      assert(en == 90, "expected the same amount of energy that was received to be stored")

      en = EnergyDevices.use_stored_energy(state.pos, node, 90, 1.0)
      assert(en == 90, "expected the same amount of energy that was stored to be used")

      en = EnergyDevices.get_usable_stored_energy(state.pos, node)
      assert(en == 0, "expected no energy to be stored after using it")
    end,
  },

  teardown = function (suite, state)
    suite:clear_test_area(state.pos)

    wait_for_next_tick_on_clusters(suite, state, 1.0)
  end,
})
