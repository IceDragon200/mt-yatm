--[[
Fluid Nullifiers are used to discard any unwanted fluids.

Where does it go?

/dev/null maybe?
]]

local fluids_interface = {}

function fluids_interface.get(_pos, _dir, _node)
  return nil
end

function fluids_interface.replace(pos, dir, node, fluid_name, amount, commit)
  return {name = fluid_name, amount = amount}
end

function fluids_interface.fill(pos, dir, node, fluid_name, amount, commit)
  return {name = fluid_name, amount = amount}
end

function fluids_interface.drain(pos, dir, node, fluid_name, amount, commit)
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
