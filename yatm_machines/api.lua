local table_freeze = assert(foundation.com.table_freeze)
local table_merge = assert(foundation.com.table_merge)
local table_deep_merge = assert(foundation.com.table_deep_merge)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local cluster_thermal = assert(yatm.cluster.thermal)
local Energy = assert(yatm.energy)
local en_receive_meta_energy = assert(Energy.receive_meta_energy)

--- @namespace yatm.devices
local devices = {
  ENERGY_BUFFER_KEY = "energy_buffer",
  HEAT_MODIFIER_KEY = "heat_modifier",
  MIN_HEAT_MODIFIER = -100,
  MAX_HEAT_MODIFIER = 100,
  NUCLEAR_PROTECTION_KEY = "nuclear_protection",
  NUCLEAR_PROTECTION_MIN = -1000,
  NUCLEAR_PROTECTION_MAX = -1000,
}

local REASON_TRANSITION = table_freeze({ reason = "transition_state" })
local REASON_STORED_ENERGY = table_freeze({ reason = "stored_energy" })
local REASON_CONSUMED_ENERGY = table_freeze({ reason = "consumed_energy" })
local REASON_IDLE = table_freeze({ reason = "idle" })

--- @spec device_on_construct(pos: Vector3): void
function devices.device_on_construct(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef.groups["yatm_cluster_device"] then
    cluster_devices:schedule_add_node(pos, node)
  end

  if nodedef.groups["yatm_cluster_energy"] then
    cluster_energy:schedule_add_node(pos, node)
  end

  if nodedef.groups["yatm_cluster_thermal"] then
    cluster_thermal:schedule_add_node(pos, node)
  end
end

--- @spec device_on_destruct(pos: Vector3): void
function devices.device_on_destruct(pos)
  --
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef.groups["yatm_cluster_device"] then
    cluster_devices:schedule_remove_node(pos, node)
  end

  if nodedef.groups["yatm_cluster_energy"] then
    cluster_energy:schedule_remove_node(pos, node)
  end

  if nodedef.groups["yatm_cluster_thermal"] then
    cluster_thermal:schedule_remove_node(pos, node)
  end
end

--- @spec device_after_destruct(pos: Vector3, old_node: NodeRef): void
function devices.device_after_destruct(pos, old_node)
  --
end

--- @spec device_after_place_node(
---   pos: Vector3,
---   placer: PlayerRef,
---   item_stack: ItemStack,
---   pointed_thing: PointedThing
--- ): void
function devices.device_after_place_node(pos, placer, item_stack, pointed_thing)
  --
end

function devices.device_swap_node_by_state(pos, node, new_state, reason)
  reason = reason or "device_swap_node_by_state"
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef and nodedef.yatm_network.states then
    local new_node_name = nodedef.yatm_network.states[new_state]

    local changed = false

    if new_node_name then
      node = minetest.get_node(pos)

      if node.name ~= new_node_name then
        local new_node = {
          name = new_node_name,
          param1 = node.param1,
          param2 = node.param2,
        }

        minetest.swap_node(pos, new_node)

        if nodedef.groups["yatm_cluster_device"] then
          cluster_devices:schedule_update_node(pos, new_node, reason)
        end

        if nodedef.groups["yatm_cluster_energy"] then
          cluster_energy:schedule_update_node(pos, new_node, reason)
        end

        if nodedef.groups["yatm_cluster_thermal"] then
          cluster_thermal:schedule_update_node(pos, new_node, reason)
        end

        changed = true
      end
    else
      minetest.log("warning", "missing node name for state=" .. new_state .. " node=" .. node.name)
    end

    if changed then
      yatm.queue_refresh_infotext(pos, node, REASON_TRANSITION)
    end

    return changed
  end

  return false
end

--- @spec device_transition_device_state(Vector3, NodeRef, dev_state: String, reason: String): Boolean
function devices.device_transition_device_state(pos, node, dev_state, reason)
  reason = reason or "device_transition_device_state"
  local meta = minetest.get_meta(pos)
  local state
  if dev_state == "down" then
    state = "off"
  elseif dev_state == "up" then
    local up_state = meta:get_string("up_state")
    if not up_state or up_state == "" then
      state = "on"
    else
      state = up_state
    end
  elseif dev_state == "conflict" then
    state = "conflict"
  else
    error("unhandled dev_state=" .. dev_state)
  end

  return devices.device_swap_node_by_state(pos, node, state, reason)
end

--- @spec get_energy_capacity(Vector3, NodeRef): Number
function devices.get_energy_capacity(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  local en = nodedef.yatm_network.energy
  local ty = type(en.capacity)

  if ty == "number" then
    return en.capacity
  elseif ty == "function" then
    return en.capacity(pos, node)
  else
    return 0
  end
end

---
---
--- @spec device_passive_consume_energy(Vector3, Node, Integer, dtime: Float, Trace): Integer
function devices.device_passive_consume_energy(pos, node, total_available, dtime, trace)
  local span
  if trace then
    span = trace:span_start("device_passive_consume_energy:" .. node.name)
  end

  local consumed = 0
  local nodedef = minetest.registered_nodes[node.name]
  local energy = nodedef.yatm_network.energy
  local capacity = devices.get_energy_capacity(pos, node)

  -- Passive lost affects how much energy is available
  -- Passive lost will not affect the node's current buffer only the consumable amount
  local passive_lost = energy.passive_lost * dtime
  if passive_lost > 0 then
    consumed = consumed + math.min(total_available, passive_lost)
  end

  local remaining = total_available - consumed
  if remaining > 0 then
    if not energy.network_charge_bandwidth then
      error("missing network_charge_bandwidth for device name=" .. node.name)
    end

    local charge_bandwidth = energy.network_charge_bandwidth * dtime

    if charge_bandwidth and charge_bandwidth > 0 then
      local meta = minetest.get_meta(pos)
      local stored = en_receive_meta_energy(
        meta,
        devices.ENERGY_BUFFER_KEY,
        remaining,
        charge_bandwidth,
        capacity,
        true
      )

      consumed = consumed + stored

      if stored > 0 then
        yatm.queue_refresh_infotext(pos, node, REASON_STORED_ENERGY)
      end
    end
  end

  --print("CONSUMED", pos.x, pos.y, pos.z, node.name, "CONSUMED", consumed, "GIVEN", total_available)
  if span then
    span:span_end()
  end

  return consumed
end

---
---
--- @spec reset_idle(MetaRef): void
function devices.reset_idle(meta)
  meta:set_float("idle_time", 0)
end

--- Increments the idle_time of metaref, this acts as an accumulated value.
--- Once the total time exceeds the threshold, `true` is returned.
--- The implementor must decide what to do when "idling".
---
--- @spec inc_idle(MetaRef, amount: Number, threshold: Number): Boolean
function devices.inc_idle(meta, amount, threshold)
  local time = meta:get_float("idle_time") + amount
  meta:set_float("idle_time", time)
  return time >= threshold
end

function devices.set_sleep(meta, duration_sec)
  meta:set_float("sleep_time", duration_sec)
end

--- A WorkContext contains the current node information on the worker node as well as some preloaded
--- structures, its purpose is to provide all the necessary information for a #work/1 function which,
--- replaces the &work/5+ function.
---
--- @class WorkContext
local WorkContext = foundation.com.Class:extends("yatm.devices.WorkContext")
do
  local ic = WorkContext.instance_class

  --- Initialize a new WorkContext.
  ---
  --- @spec #initialize(): void
  function ic:initialize()
    --
  end

  --- Initialize a new WorkContext given the position, node reference, elapsed time and an optional
  --- trace context.
  ---
  --- @spec #setup(pos: Vector3, node: NodeRef, dtime: Float, trace?: Trace): self
  function ic:setup(pos, node, dtime, trace)
    --- @member pos: Vector3
    self.pos = pos

    --- @member node: NodeRef
    self.node = node

    --- @member dtime: Float
    self.dtime = dtime

    --- @member trace?: Trace
    self.trace = trace

    --- retrieve and cache the node definition
    --- @member nodedef: NodeDefinition
    self.nodedef = minetest.registered_nodes[self.node.name]

    --- retrieve and cache the metaref
    --- @member meta: MetaRef
    self.meta = minetest.get_meta(self.pos, self.node)

    return self
  end

  ---
  --- @spec #refresh_node(): void
  function ic:refresh_node()
    -- refresh the node
    self.node = minetest.get_node_or_nil(self.pos)
    -- refresh the nodedef
    self.nodedef = minetest.registered_nodes[self.node.name]
    -- retrieve and cache the metaref
    self.meta = minetest.get_meta(self.pos, self.node)
  end

  --- @spec #precalculate(): void
  function ic:precalculate()
    --- affects how much work is done by a machine per tick (higher = better)
    --- higher the rate, the more work can be done using the same amount of energy
    --- work rate is also affected by the machine's preferred thermal profile, and any
    --- upgrades that may be installed
    ---
    --- @member work_rate: Float
    self.work_rate = 1.0

    --- The heat modifier is the machine's current thermal profile
    --- the higher the modifier, the hotter the machine is, this works well for
    --- machines like ovens, furnaces and compactors.
    --- While the modifier is negative, the machine will be colder which works well
    --- for machines like condensers, freezers etc...
    --- The heat modifier is affected by the machine's work itself and thermal
    --- plates that may be attached.
    ---
    --- @member heat_modifier: Float
    self.heat_modifier = self.meta:get_float(devices.HEAT_MODIFIER_KEY)

    --- Nuclear protection affects how much radioactivty a machine can safely absorb
    --- this decreases the radioactivity in the block as well.
    --- This value ranges between NUCLEAR_PROTECTION_MIN and NUCLEAR_PROTECTION_MAX:
    ---   NUCLEAR_PROTECTION_MIN means the node has a tendency to absorb more radiation than normal,
    ---     this will likely have negative consequences on the machine's contents.
    ---   0 being no protection at all, machines with no protection are subject to radiation damage,
    ---     this can affect the machine's contents and transforms them in dangerous ways.
    ---   NUCLEAR_PROTECTION_MAX being the highest.
    --- This value will decrement every tick unless increased by a nuclear thermal plate
    --- or a nuclear upgrade.
    --- This value will also decrement every time it has to absorb radiation
    --- If by absorbing radiation it hits negative a `&on_radiation_damage/5` will take place
    ---
    --- @member nuclear_protection: Integer
    self.nuclear_protection = self.meta:get_int(devices.NUCLEAR_PROTECTION_KEY)

    --- affects how much energy is used per tick (lower = better)
    --- the higher the rate, the more energy is used for the same unit of work
    ---
    --- @member energy_rate: Float
    self.energy_rate = 1.0

    --- determine the total stored energy
    ---
    --- @member total_stored_energy: Integer
    self.total_stored_energy = Energy.get_meta_energy(self.meta, devices.ENERGY_BUFFER_KEY)
  end

  --- @spec #run(): void
  function ic:run()
    -- extract the yatm network definition from the node definition, and ensure it exists
    local ym = assert(self.nodedef.yatm_network)

    self:precalculate()

    if ym.state == "conflict" then
      return
    end

    if ym.state == "off" then
      -- the state was known to be off, see if it can startup
      if self.total_stored_energy >= ym.energy.startup_threshold then
        -- yes it could be start up
        if self.nodedef.transition_device_state(self.pos, self.node, "up", "awakening device") then
          self:refresh_node()
          ym = assert(self.nodedef.yatm_network)
          self:precalculate()
        end
      end
    elseif ym.state == "on" or ym.state == "idle" then
      if self.total_stored_energy <= 0 then
        if self.nodedef.transition_device_state(self.pos, self.node, "down", "device has no energy") then
          self:refresh_node()
          ym = assert(self.nodedef.yatm_network)
          self:precalculate()
        end
      end
    end

    if ym.state == "on" or ym.state == "idle" then
      local sleep_time = self.meta:get_float("sleep_time")
      sleep_time = math.max(0, sleep_time - self.dtime)

      self.meta:set_float("sleep_time", sleep_time)

      if sleep_time <= 0 then
        local capacity = devices.get_energy_capacity(self.pos, self.node)
        local bandwidth = ym.work_energy_bandwidth or capacity

        local thresh = ym.work_rate_energy_threshold
        if thresh and thresh > 0 then
          self.work_rate = self.total_stored_energy / thresh
        end

        -- TODO: there are multiple factors that affect the work rate, including the energy
        --       available, thermal settings (i.e. thermal plates attached) and upgrades

        --- The amount of energy that is actually available
        --- @member available_energy: Integer
        self.available_energy =
          Energy.consume_meta_energy(
            self.meta,
            devices.ENERGY_BUFFER_KEY,
            bandwidth,
            bandwidth,
            capacity,
            false
          )

        local consumed = ym:work(self)

        if consumed > 0 then
          Energy.consume_meta_energy(
            self.meta,
            devices.ENERGY_BUFFER_KEY,
            consumed,
            bandwidth,
            capacity,
            true
          )

          yatm.queue_refresh_infotext(self.pos, self.node, REASON_CONSUMED_ENERGY)
        end
      else
        yatm.queue_refresh_infotext(self.pos, self.node, REASON_IDLE)
      end
    end
  end

  --- Sets the node's expected UP state (usually "on" or "idle")
  ---
  --- @spec #set_up_state(state: String): void
  function ic:set_up_state(state)
    self.meta:set_string("up_state", state)
    if self.nodedef.yatm_network.state ~= state then
      if self.nodedef.transition_device_state(self.pos, self.node, "up") then
        self:refresh_node()
      end
    end
  end
end

--- @namespace yatm.devices
devices.WorkContext = WorkContext

local ctx = WorkContext:new()

--- @spec worker_update(pos: Vector3, node: NodeRef, dtime: Float, trace: Trace): void
function devices.worker_update(pos, node, dtime, ot)
  --local ctx = WorkContext:new():setup(pos, node, dtime, ot)
  ctx:setup(pos, node, dtime, ot)
  ctx:run()
end

local function network_default_on_network_state_changed(pos, node, state)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.yatm_network.states then
    local new_name = assert(nodedef.yatm_network.states[state], "expected node=" .. node.name .. " to have a state=" .. state)
    if node.name ~= new_name then
      --debug("node", "NETWORK CHANGED", minetest.pos_to_string(pos), node.name, "STATE", state)
      node.name = new_name
      minetest.swap_node(pos, node)
      -- FIXME: I'm almost certain this is suppose to upsert with the other involved networks as well
    end
  end
end

function devices.default_on_network_state_changed(pos, node, state)
  local new_state = state
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.yatm_network.state then
    if nodedef.yatm_network.state == "on" then
      -- it's currently on
      -- nothing to do
    else
      -- the intention is to activate the node
      if state == "on" then
        local meta = minetest.get_meta(pos, node)
        if nodedef.yatm_network.groups.energy_consumer then
          local total_available = Energy.get_meta_energy(meta, devices.ENERGY_BUFFER_KEY)
          local threshold = nodedef.yatm_network.energy.startup_threshold or 0
          --print("TRY ONLINE", pos.x, pos.y, pos.z, node.name, total_available, threshold)
          if total_available < threshold then
            new_state = "off"
          end
        end
      end
    end
  end
  network_default_on_network_state_changed(pos, node, new_state)
end

function devices.patch_device_nodedef(name, nodedef)
  assert(name, "expected a node name")
  assert(nodedef, "expected a nodedef")

  nodedef.groups = nodedef.groups or {}
  nodedef.groups['yatm_cluster_device'] = 1

  if nodedef.transition_device_state == nil then
    --print("register_network_device", name, "using device_transition_device_state")
    nodedef.transition_device_state = assert(devices.device_transition_device_state)
  end

  if nodedef.after_place_node == nil then
    --print("register_network_device", name, "using device_after_place_node")
    nodedef.after_place_node = assert(devices.device_after_place_node)
  end

  if nodedef.on_construct == nil then
    --print("register_network_device", name, "using device_on_construct")
    nodedef.on_construct = assert(devices.device_on_construct)
  end

  if nodedef.on_destruct == nil then
    --print("register_network_device", name, "using device_on_destruct")
    nodedef.on_destruct = assert(devices.device_on_destruct)
  end

  if nodedef.after_destruct == nil then
    --print("register_network_device", name, "using device_after_destruct")
    nodedef.after_destruct = assert(devices.device_after_destruct)
  end

  if nodedef.yatm_network then
    assert(nodedef.yatm_network.kind, "all devices must have a kind (" .. name .. ")")
    local ym = nodedef.yatm_network
    if ym.on_network_state_changed == nil then
      ym.on_network_state_changed = assert(devices.default_on_network_state_changed)
    end
    if ym.groups then
      if ym.groups.machine_worker then
        ym.groups.has_update = 1
        ym.update = devices.worker_update

        assert(ym.state, name .. " a machine_worker must have a `state`")
        assert(ym.energy, name .. " a machine_worker requires an `energy` interface containing all energy behaviour")
        assert(ym.energy.capacity, name .. " a machine_worker requires an `energy.capacity`")
        assert(ym.energy.network_charge_bandwidth, name .. " a machine_worker require `energy.network_charge_bandwidth`")
        assert(ym.energy.startup_threshold, name .. " a machine_worker requires a `energy.startup_threshold`")
        assert(ym.work, name .. " a machine_worker requries a `work/6` function")
      end

      if ym.groups.has_update then
        assert(ym.update, "expected update/3 to be defined")
      end

      if ym.groups.energy_producer then
        assert(ym.energy, name .. " energy_producer requires an `energy` interface containing all energy behaviour")
        assert(ym.energy.produce_energy, "expected produce_energy/4 to be defined")

        nodedef.groups['yatm_cluster_energy'] = 1
      end

      if ym.groups.energy_consumer then
        assert(ym.energy, name .. " energy_consumer requires an `energy` interface containing all energy behaviour")
        if ym.energy.passive_lost == nil then
          ym.energy.passive_lost = 10
        end
        if ym.energy.consume_energy == nil then
          ym.energy.consume_energy = assert(devices.device_passive_consume_energy)
        end

        nodedef.groups['yatm_cluster_energy'] = 1
      end

      if ym.groups.energy_storage then
        assert(ym.energy, name .. " energy_storage requires an `energy` interface")
        assert(ym.energy.get_usable_stored_energy, name .. " expected a `get_usable_stored_energy` function to be defined")
        assert(ym.energy.use_stored_energy, name .. " expected a `use_stored_energy` function to be defined")
        nodedef.groups['yatm_cluster_energy'] = 1
      end

      if ym.groups.energy_receiver then
        assert(ym.energy, name .. " energy_receiver requires an `energy` interface")
        assert(ym.energy.receive_energy, name .. " expected a receive_energy function to be defined")
        nodedef.groups['yatm_cluster_energy'] = 1
      end

      if ym.groups.heat_producer then
        nodedef.groups['yatm_cluster_thermal'] = 1
      end
    end
  end

  return nodedef
end

function devices.register_network_device(name, nodedef)
  assert(name, "expected a name")

  devices.patch_device_nodedef(name, nodedef)

  return minetest.register_node(name, nodedef)
end

function devices.register_stateful_network_device(base_node_def, overrides)
  overrides = overrides or {}
  assert(base_node_def, "expected a nodedef")
  assert(base_node_def.yatm_network, "expected a yatm_network")
  assert(base_node_def.yatm_network.states, "expected a yatm_network.states")
  assert(base_node_def.yatm_network.default_state, "expected a yatm_network.default_state")

  local seen = {}

  for state,name in pairs(base_node_def.yatm_network.states) do
    if not seen[name] then
      seen[name] = true

      local ov = overrides[state]
      if state == "conflict" and not ov then
        state = "error"
        ov = overrides[state]
      end
      ov = ov or {}
      local node_def = table_deep_merge(base_node_def, ov)
      local new_yatm_network = table_merge(node_def.yatm_network, {state = state})
      node_def.yatm_network = new_yatm_network

      if node_def.yatm_network.default_state ~= state then
        local groups = table_merge(node_def.groups, {not_in_creative_inventory = 1})
        node_def.groups = groups
      end

      devices.register_network_device(name, node_def)
    end
  end
end

yatm.devices = devices

--- @namespace yatm.grinding
yatm.grinding = yatm.grinding or {}
--- @const grinding_registry: yatm_machines.GrindingRegistry
yatm.grinding.grinding_registry = yatm_machines.GrindingRegistry:new()

--- @namespace yatm.freezing
yatm.freezing = yatm.freezing or {}
--- @const freezing_registry: yatm_machines.FreezingRegistry
yatm.freezing.freezing_registry = yatm_machines.FreezingRegistry:new()

--- @namespace yatm.condensing
yatm.condensing = yatm.condensing or {}
--- @const condensing_registry: yatm_machines.CondensingRegistry
yatm.condensing.condensing_registry = yatm_machines.CondensingRegistry:new()

--- @namespace yatm.compacting
yatm.compacting = yatm.compacting or {}
--- @const compacting_registry: yatm_machines.CompactingRegistry
yatm.compacting.compacting_registry = yatm_machines.CompactingRegistry:new()

--- @namespace yatm.rolling
yatm.rolling = yatm.rolling or {}
--- @const rolling_registry: yatm_machines.RollingRegistry
yatm.rolling.rolling_registry = yatm_machines.RollingRegistry:new()

--- @namespace yatm.crushing
yatm.crushing = yatm.crushing or {}
--- @const crushing_registry: yatm_machines.CrushingRegistry
yatm.crushing.crushing_registry = yatm_machines.CrushingRegistry:new()
