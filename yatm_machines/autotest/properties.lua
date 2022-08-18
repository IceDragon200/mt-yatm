local clusters = assert(yatm.clusters)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local hash_node_position = assert(minetest.hash_node_position)
local table_sample = assert(foundation.com.table_sample)
local Vector3 = assert(foundation.com.Vector3)

local ENERGY_PROVIDERS = {}

ENERGY_PROVIDERS.combustion_engine = {
  setup = function (subject_pos)
    local node_name = "yatm_machines:creative_engine_off"

    local pos = Vector3.add({}, subject_pos, Vector3.new(0, 0, 1))

    minetest.set_node(pos, { name = node_name })
  end,
}

local function random_energy_provider()
  local _key, provider = table_sample(ENERGY_PROVIDERS)
  return provider
end

local function wait_for_next_tick_on_clusters(suite, state, timeout)
  local ticked = false
  clusters:on_next_tick(function (_instance, _dtime)
    ticked = true
  end)

  local elapsed = 0
  local dtime
  while not ticked do
    dtime = assert(suite:yield(), "expected dtime")
    elapsed = elapsed + dtime
    if elapsed > timeout then
      error("timeout while waiting for next tick on cluster")
    end
  end
end

local function set_node_to_air(pos)
  minetest.set_node(pos, { name = "air" })
end

yatm_machines.autotest_suite:define_property("is_network_controller_like", {
  description = "Is Network Controller Like",
  detail = [[
  The device acts like a network controller, this is intended for network_controller group nodes that
  have a value greater than 1.
  ]],

  setup = function (suite, state)
    suite:clear_test_area()

    state.pos = vector.new(0, 0, 0)
    state.node_id = hash_node_position(state.pos)
    minetest.set_node(state.pos, assert(state.node))

    return state
  end,

  tests = {
    ["Will create a device network on construction"] = function (suite, state)
      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local cluster = cluster_devices:get_node_cluster(state.pos)

      if not cluster then
        error("device cluster not available")
      end

      if cluster.assigns.controller_id ~= state.node_id then
        error("device node was expected to be controller of cluster")
      end
    end,

    ["Will teardown network upon node removal"] = function (suite, state)
      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local cluster = cluster_devices:get_node_cluster(state.pos)

      if not cluster then
        error("device cluster not available")
      end

      set_node_to_air(state.pos)

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local cluster = cluster_devices:get_node_cluster(state.pos)

      if cluster then
        error("cluster should have been removed")
      end
    end,
  },

  teardown = function (suite, state)
    suite:clear_test_area()

    wait_for_next_tick_on_clusters(suite, state, 1.0)
  end,
})

yatm_machines.autotest_suite:define_property("is_network_controller", {
  description = "Is Network Controller",
  detail = [[
  The device explictly is a network_controller node
  ]],

  setup = function (suite, state)
    suite:clear_test_area()

    state.pos = vector.new(0, 0, 0)
    state.node_id = hash_node_position(state.pos)
    minetest.set_node(state.pos, assert(state.node))

    return state
  end,

  tests = {
    ["Will create a device network on construction"] = function (suite, state)
      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local cluster = cluster_devices:get_node_cluster(state.pos)

      if not cluster then
        error("device cluster not available")
      end

      if cluster.assigns.controller_id ~= state.node_id then
        error("device node was expected to be controller of cluster")
      end
    end,

    ["Will teardown network upon node removal"] = function (suite, state)
      wait_for_next_tick_on_clusters(suite, state, 2.0)
      local cluster = cluster_devices:get_node_cluster(state.pos)

      if not cluster then
        error("device cluster not available")
      end

      minetest.set_node(state.pos, { name = "air" })

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local cluster = cluster_devices:get_node_cluster(state.pos)

      if cluster then
        error("cluster should have been removed")
      end
    end,
  },

  teardown = function (suite, state)
    suite:clear_test_area()

    wait_for_next_tick_on_clusters(suite, state, 1.0)
  end,
})

yatm_machines.autotest_suite:define_property("is_machine_like", {
  description = "Is Machine Like",
  detail = [[
  The device exhibits normal machine behaviour, that is it is not a controller nor energy producer
  ]],

  tests = {
    ["Will create a device network on construction"] = function (suite, state)
      suite:clear_test_area()

      local subject_pos = vector.new(0, 0, 0)

      minetest.set_node(subject_pos, assert(state.node))

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local cluster = cluster_devices:get_node_cluster(subject_pos)

      if not cluster then
        error("device cluster not available")
      end

      if cluster.assigns.controller_id ~= nil then
        error("node was expected to not be controller of cluster")
      end

      cluster = cluster_energy:get_node_cluster(subject_pos)

      if not cluster then
        error("energy cluster not available")
      end
    end,

    ["Will teardown network upon node removal"] = function (suite, state)
      suite:clear_test_area()

      local subject_pos = vector.new(0, 0, 0)

      minetest.set_node(subject_pos, assert(state.node))

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local cluster = cluster_devices:get_node_cluster(subject_pos)

      if not cluster then
        error("device cluster not available")
      end

      minetest.set_node(subject_pos, { name = "air" })

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local cluster = cluster_devices:get_node_cluster(subject_pos)

      if cluster then
        error("cluster should have been removed")
      end
    end,

    ["Will be in default state without energy"] = function (suite, state)
      suite:clear_test_area()

      local subject_pos = vector.new(0, 0, 0)

      minetest.set_node(subject_pos, assert(state.node))

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local node = assert(minetest.get_node_or_nil(subject_pos), "expected node at subject position")
      local nodedef = assert(minetest.registered_nodes[node.name], "expected a node def")

      assert(nodedef.yatm_network, "expected nodedef to define yatm_network field")

      assert(nodedef.yatm_network.default_state, "expected nodedef to have a default_state")

      if nodedef.yatm_network.state ~= nodedef.yatm_network.default_state then
        error("expected node's current state to be its default_state got state=" .. nodedef.yatm_network.state)
      end
    end,

    ["Will be in idle or on state with energy"] = function (suite, state)
      suite:clear_test_area()

      local subject_pos = vector.new(0, 0, 0)

      minetest.set_node(subject_pos, assert(state.node))
      local provider = random_energy_provider()

      provider.setup(subject_pos)

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      local node = assert(minetest.get_node_or_nil(subject_pos), "expected node at subject position")
      local nodedef = assert(minetest.registered_nodes[node.name], "expected a node def")

      assert(nodedef.yatm_network, "expected nodedef to define yatm_network field")

      assert(nodedef.yatm_network.default_state, "expected nodedef to have a default_state")

      local is_on = nodedef.yatm_network.state == "on" or nodedef.yatm_network.state == "idle"

      if not is_on then
        error("expected node's current state to be its default_state got state=" .. nodedef.yatm_network.state)
      end
    end,
  },

  teardown = function (suite, state)
    suite:clear_test_area()

    wait_for_next_tick_on_clusters(suite, state, 1.0)
  end,
})

yatm_machines.autotest_suite:define_property("has_rightclick_formspec", {
  description = "Has Right-Click Formspec",
  detail = [[
  The device will show a formspec when right clicked by a player
  ]],

  setup = function (suite, state)
    local player = assert(minetest.get_player_by_name("singleplayer"))

    state.player = player

    return state
  end,

  tests = {
    ["Will show a formspec when right-clicked"] = function (suite, state)
      suite:clear_test_area()

      local subject_pos = vector.new(0, 0, 0)

      minetest.set_node(subject_pos, assert(state.node))

      wait_for_next_tick_on_clusters(suite, state, 2.0)

      assert(trigger_rightclick_on_node(subject_pos, state.player), "expected rightclick to trigger")

      -- wait three seconds, this will usually refresh the formspec at least three times
      -- for most cases
      suite:wait(3)
    end,
  },

  teardown = function (suite, state)
    minetest.close_formspec(state.player:get_player_name(), "")
    suite:clear_test_area()
    wait_for_next_tick_on_clusters(suite, state, 1.0)
  end,
})
