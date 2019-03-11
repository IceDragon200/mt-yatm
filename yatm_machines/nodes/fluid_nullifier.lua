--[[
Fluid Nullifiers are used to discard any unwanted fluids.

Where does it go?

/dev/null maybe?
]]

local fluids_interface = {}

function fluids_interface:get(_pos, _dir)
  return nil
end

function fluids_interface:replace(pos, dir, fluid_stack, commit)
  return fluid_stack
end

function fluids_interface:fill(pos, dir, fluid_stack, commit)
  return fluid_stack
end

function fluids_interface:drain(pos, dir, fluid_stack, commit)
  return nil
end

minetest.register_node("yatm_machines:fluid_nullifier", {
  description = "Fluid Nullifier",
  groups = {
    cracky = 1,
  },
  tiles = {
    "yatm_fluid_nullifier_side.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  fluids_interface = fluids_interface,
})
