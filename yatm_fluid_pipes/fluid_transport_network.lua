--[[
Starting to see a pattern here?

This Network handles Fluid Transport, devices can still handle their own fluid draining.

Only fluid pipes should register on this network, do not register devices that have fluid tanks here.

Unless their intention is to operate directly in the transport of fluids.

The 3 main components of a fluid transport are:
* Inserters - these will accept fluids from the network and place them into their adjacent devices
* Extractors - these will drain fluids from adjacent devices for consumption by the network
* Transporters - these only act as a pathway for the network and only matter when tracing the path
]]
local GenericTransportNetwork = assert(yatm.transport.GenericTransportNetwork)
local invert_dir = assert(yatm_core.invert_dir)
local DIR_TO_STRING = assert(yatm_core.DIR_TO_STRING)
local DIR6_TO_VEC3 = assert(yatm_core.DIR6_TO_VEC3)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidMeta = assert(yatm.fluids.FluidMeta)

local FluidTransportNetwork = GenericTransportNetwork:extends()
local m = assert(FluidTransportNetwork.instance_class)

function inspect_node(pos, dir)
  assert(pos, "expected a position")
  assert(dir, "expected a direction")
  local node = minetest.get_node(pos)
  local dir_string = assert(DIR_TO_STRING[dir], "dir " .. dump(dir) .. " is not a valid direction")
  if node then
    return "<" .. minetest.pos_to_string(pos) .. " " .. node.name .. " dir " .. dir_string .. "> "
  else
    return "<" .. minetest.pos_to_string(pos) .. " NO_NODE dir " .. dir_string .. ">"
  end
end

function m:update_extractor_duct(extractor_hash, extractor, fluids_available)
  local wildcard_stack = FluidStack.new_wildcard(extractor.interface.bandwidth or 1000)
  for vdir,v3 in pairs(DIR6_TO_VEC3) do
    if wildcard_stack.amount <= 0 then
      break
    end
    local new_pos = vector.add(extractor.pos, v3)
    local node_face_dir = invert_dir(vdir)
    --print("Attempting drain", minetest.pos_to_string(new_pos), dir)
    local stack, reason = FluidTanks.drain_fluid(new_pos, node_face_dir, wildcard_stack, false)
    if stack and stack.amount > 0 then
      --print("Extractor", inspect_node(extractor.pos, vdir), "extracted", FluidStack.to_string(stack), "from", inspect_node(new_pos, node_face_dir))
      local new_hash = minetest.hash_node_position(new_pos)
      fluids_available[extractor_hash] = fluids_available[extractor_hash] or {}
      local fa = fluids_available[extractor_hash]
      fa[new_hash] = {pos = new_pos, dir = node_face_dir, stack = stack}
      wildcard_stack = FluidStack.dec_amount(wildcard_stack, stack.amount)
    --[[else
      if reason then
        print("drain_fluid error", minetest.pos_to_string(new_pos), reason)
      end]]
    end
  end
end

function m:update_inserter_duct(inserter_hash, inserter, fluids_available)
  for vdir,v3 in pairs(DIR6_TO_VEC3) do
    if yatm_core.is_table_empty(fluids_available) then
      break
    end
    local filling_dir = invert_dir(vdir)
    local target_pos = vector.add(inserter.pos, v3)

    local old_fluids_available = fluids_available
    fluids_available = {}

    for extractor_hash,entries in pairs(old_fluids_available) do
      local new_entries = {}
      for fin_node_hash,entry in pairs(entries) do
        local stack = entry.stack
        local filling_stack = FluidStack.set_amount(stack, math.min(stack.amount, inserter.interface.bandwidth or 1000))
        local used_stack, reason = FluidTanks.fill_fluid(target_pos, filling_dir, filling_stack, true)
        if used_stack and used_stack.amount > 0 then
          --print("Inserter", inspect_node(inserter.pos, vdir), "filled", inspect_node(target_pos, filling_dir), "with", FluidStack.to_string(stack), "from", inspect_node(entry.pos, entry.dir))
          FluidTanks.drain_fluid(entry.pos, entry.dir, used_stack, true)
          local new_stack = FluidStack.dec_amount(stack, used_stack.amount)
          entry.stack = new_stack
        --[[else
          if reason then
            print("fill_fluid error", minetest.pos_to_string(target_pos), reason)
          end]]
        end

        if entry.stack.amount > 0 then
          new_entries[fin_node_hash] = entry
        end
      end

      if not yatm_core.is_table_empty(new_entries) then
        fluids_available[extractor_hash] = new_entries
      end
    end
  end
  return fluids_available
end

function m:update_network(network, counter, delta)
  --
  -- Currently this update implements a PUSH (supply-based) based system
  -- That is, extractors are drained (simulated) to determine what fluids are available
  -- Then it iterates through the inserters and attempts to consume all the
  -- fluid found.
  --
  -- If this turns out to be too slow, I may spin it around and make it PULL (demand-based)
  -- This would require adding some new functions to the fluid interface
  -- One that would ask the inserters "what do you want",
  -- once the demand is established, the supplies (extractors) can be scanned for the demand.
  --
  --print("Updating Network", network.id, counter)
  local extractors = network.members_by_type["extractor"]
  local inserters = network.members_by_type["inserter"]
  if extractors and inserters then
    local fluids_available = {}
    for extractor_hash,extractor in pairs(extractors) do
      if self:check_network_member(extractor, network) then
        self:update_extractor_duct(extractor_hash, extractor, fluids_available)
      end
    end

    for inserter_hash,inserter in pairs(inserters) do
      if self:check_network_member(inserter, network) then
        fluids_available = self:update_inserter_duct(inserter_hash, inserter, fluids_available)
      end
    end
  end
end

yatm_fluid_pipes.FluidTransportNetwork = FluidTransportNetwork:new({
  description = "Fluid Transport Network",
  abbr = "ftn",
  node_interface_name = "fluid_transport_device",
})

do
  minetest.register_globalstep(function (delta)
    yatm_fluid_pipes.FluidTransportNetwork:update(delta)
  end)

  minetest.register_lbm({
    name = "yatm_fluid_pipes:fluid_transport_network_reload_lbm",
    nodenames = {
      "group:transporter_fluid_pipe",
      "group:inserter_fluid_pipe",
      "group:extractor_fluid_pipe",
    },
    run_at_every_load = true,
    action = function (pos, node)
      yatm_fluid_pipes.FluidTransportNetwork:register_member(pos, node)
    end
  })
end
