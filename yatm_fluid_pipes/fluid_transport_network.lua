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
local DIR6_TO_VEC3 = assert(yatm_core.DIR6_TO_VEC3)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidStack = assert(yatm.fluids.FluidStack)

local FluidTransportNetwork = GenericTransportNetwork:extends()
local m = assert(FluidTransportNetwork.instance_class)

function m:update_network(network, counter)
  --print("Updating Network", network.id, counter)
  local extractors = network.members_by_type["extractor"]
  local inserters = network.members_by_type["inserter"]
  if extractors and inserters then
    local fluids_available = {}
    for extractor_hash,extractor in pairs(extractors) do
      local wildcard_stack = FluidStack.new_wildcard(extractor.interface.bandwidth or 1000)
      for dir,v3 in pairs(DIR6_TO_VEC3) do
        if wildcard_stack.amount == 0 then
          break
        end
        local npos = vector.add(extractor.pos, v3)
        local node_face_dir = invert_dir(dir)
        --print("Attempting drain", minetest.pos_to_string(npos), dir)
        local stack = FluidTanks.drain(npos, dir, wildcard_stack, false)
        if stack and stack.amount > 0 then
          --print("Extracted", FluidStack.to_string(stack), "from", minetest.pos_to_string(npos))
          local nhash = minetest.hash_node_position(npos)
          fluids_available[extractor_hash] = fluids_available[extractor_hash] or {}
          local fa = fluids_available[extractor_hash]
          fa[nhash] = {pos = npos, dir = node_face_dir, stack = stack}
          wildcard_stack = FluidStack.dec_amount(wildcard_stack, stack.amount)
        end
      end
    end

    for _inserter_hash,inserter in pairs(inserters) do
      for dir,v3 in pairs(DIR6_TO_VEC3) do
        if not yatm_core.is_table_empty(fluids_available) then
          local filling_dir = invert_dir(dir)
          local target_pos = vector.add(inserter.pos, v3)

          local old_fluids_available = fluids_available
          fluids_available = {}

          for extractor_hash,entries in pairs(old_fluids_available) do
            local new_entries = {}
            for fin_node_hash,entry in pairs(entries) do
              local stack = entry.stack
              local filling_stack = FluidStack.set_amount(stack, math.min(stack.amount, inserter.interface.bandwidth or 1000))
              local used_stack = FluidTanks.fill(target_pos, filling_dir, filling_stack, true)
              if used_stack then
                --print("Filled", minetest.pos_to_string(target_pos), "with", FluidStack.to_string(stack))
                FluidTanks.drain(entry.pos, entry.dir, used_stack, true)
                local new_stack = FluidStack.dec_amount(stack, used_stack.amount)
                entry.stack = new_stack
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
