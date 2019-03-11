local FluidStack = assert(yatm_fluids.FluidStack)
local FluidTanks = assert(yatm_fluids.FluidTanks)

local fluid_tank_tiles = {
  "yatm_fluid_tank_edge.png",
  "yatm_fluid_tank_detail.png",
}

minetest.register_node("yatm_fluids:fluid_tank", {
  description = "Fluid Tank",
  groups = {
    cracky = 1,
    fluid_tank = 1,
  },
  tiles = fluid_tank_tiles,
  special_tiles = {
  },
  drawtype = "glasslike_framed",
  paramtype = "light",
  paramtype2 = "glasslikeliquidlevel",
  is_ground_content = false,
  sunlight_propogates = true,
  sounds = default.node_sound_glass_defaults(),
  after_place_node = function (pos)
    FluidTanks.replace(pos, yatm_core.D_NONE, FluidStack.new_empty(), true)
  end,
  fluid_interface = assert(yatm_fluids.fluid_tank_fluid_interface),
  connects_to = {"group:fluid_tank"},
})

minetest.register_abm({
  label = "yatm_fluids:fluid_tank_sync",
  nodenames = {
    "group:filled_fluid_tank",
  },
  interval = 0,
  chance = 1,
  action = function (pos, node)
    local fluid_stack = FluidTanks.drain(pos, yatm_core.V3_DOWN,
      FluidStack.new_wildcard(yatm_fluids.fluid_tank_fluid_interface.bandwidth), false)
    if fluid_stack and fluid_stack.amount > 0 then
      local below_pos = vector.add(pos, yatm_core.V3_DOWN)
      local filled_stack = FluidTanks.fill(below_pos, yatm_core.D_UP, fluid_stack, true)
      if filled_stack and filled_stack.amount > 0 then
        FluidTanks.drain(pos, yatm_core.V3_DOWN, filled_stack, true)
      end
    end
  end
})
