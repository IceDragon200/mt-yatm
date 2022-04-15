--
-- Thermal Boilers are an alternative to the electric boiler, using the thermal system instead.
--
local mod = yatm_refinery
local Directions = assert(foundation.com.Directions)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local cluster_thermal = yatm.cluster.thermal
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local table_merge = assert(foundation.com.table_merge)

if not cluster_thermal then
  minetest.log("warning", "thermal cluster is not available, skipping thermal boiler")
  return
end

local STEAM_TANK = "steam_tank"
local WATER_TANK = "water_tank"
local FLUID_CAPACITY = 16000

local function get_fluid_tank_name(self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_UP then
    return STEAM_TANK, FLUID_CAPACITY
  end
  return WATER_TANK, FLUID_CAPACITY
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface._private.capacity = FLUID_CAPACITY
fluid_interface._private.bandwidth = fluid_interface._private.capacity

function fluid_interface:allow_drain(pos, dir, fluid_stack)
  return true
end

function fluid_interface:allow_fill(pos, dir, fluid_stack)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_UP then
    return false, "no filling from top"
  end
  if FluidStack.is_member_of_group(fluid_stack, "water") then
    return true
  end
  return false, "expected fluid to be in water group"
end

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

local function boiler_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local steam_fluid_stack = FluidMeta.get_fluid_stack(meta, STEAM_TANK)
  local water_fluid_stack = FluidMeta.get_fluid_stack(meta, WATER_TANK)

  local heat = math.floor(meta:get_float("heat"))

  local infotext =
    cluster_thermal:get_node_infotext(pos) .. "\n" ..
    "Heat: " .. heat .. "\n" ..
    "Steam Tank: " .. FluidStack.pretty_format(steam_fluid_stack, FLUID_CAPACITY) .. "\n" ..
    "Water Tank: " .. FluidStack.pretty_format(water_fluid_stack, FLUID_CAPACITY)

  meta:set_string("infotext", infotext)
end

local function on_construct(pos)
  local node = minetest.get_node(pos)
  cluster_thermal:schedule_add_node(pos, node)
end

local function after_destruct(pos, node)
  cluster_thermal:schedule_remove_node(pos, node)
end

local function on_timer(pos, elapsed)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)

  -- TODO: use heat
  local usable_heat = meta:get_float("heat")

  -- TODO: determine what the heat's scale is
  if usable_heat >= 100 then
    -- Convert water into steam
    do
      local stack = FluidMeta.drain_fluid(meta,
        WATER_TANK,
        FluidStack.new("group:water", math.floor(500 * elapsed)),
        fluid_interface._private.bandwidth, fluid_interface._private.capacity, false)

      if stack then
        -- TODO: yatm_core:steam should not be hardcoded
        local filled_stack = FluidMeta.fill_fluid(meta,
          STEAM_TANK,
          FluidStack.set_name(stack, "yatm_core:steam"),
          fluid_interface._private.bandwidth, fluid_interface._private.capacity, true)

        if filled_stack and filled_stack.amount > 0 then
          FluidMeta.drain_fluid(meta,
            WATER_TANK,
            FluidStack.set_amount(stack, filled_stack.amount),
            fluid_interface._private.bandwidth, fluid_interface._private.capacity, true)
        end
      end
    end
  end

  -- Fill tank on the UP face of the boiler with steam, if available
  do
    local stack, _new_stack = FluidMeta.drain_fluid(meta,
      STEAM_TANK,
      FluidStack.new("group:steam", 1000),
      fluid_interface._private.capacity, fluid_interface._private.capacity, false)

    if stack then
      local steam_tank_dir = Directions.facedir_to_face(node.param2, Directions.D_UP)
      local steam_tank_pos = vector.add(pos, Directions.DIR6_TO_VEC3[steam_tank_dir])
      local steam_tank_node = minetest.get_node(steam_tank_pos)
      local steam_tank_nodedef = minetest.registered_nodes[steam_tank_node.name]

      if steam_tank_nodedef then
        local filled_stack = FluidTanks.fill_fluid(steam_tank_pos,
          Directions.invert_dir(steam_tank_dir), stack, true)
        if filled_stack and filled_stack.amount > 0 then
          FluidTanks.drain_fluid(pos, steam_tank_dir, filled_stack, true)
        end
      end
    end
  end

  return true
end

local groups = {
  cracky = 1,
  yatm_cluster_thermal = 1,
  heatable_device = 1,
  fluid_interface_in = 1,
  fluid_interface_out = 1,
}

yatm.register_stateful_node("yatm_refinery:thermal_boiler", {
  codex_entry_id = "yatm_refinery:thermal_boiler",

  base_description = mod.S("Thermal Boiler"),
  description = mod.S("Thermal Boiler"),

  drop = "yatm_refinery:thermal_boiler_off",

  groups = groups,

  paramtype = "none",
  paramtype2 = "facedir",

  on_construct = on_construct,
  after_destruct = after_destruct,

  on_timer = on_timer,

  fluid_interface = fluid_interface,

  refresh_infotext = boiler_refresh_infotext,

  thermal_interface = {
    groups = {
      heater = 1,
      thermal_user = 1,
    },

    update_heat = function (self, pos, node, heat, dtime)
      local meta = minetest.get_meta(pos)

      if yatm.thermal.update_heat(meta, "heat", heat, 10, dtime) then
        local new_name
        if math.floor(heat) > 0 then
          new_name = "yatm_refinery:thermal_boiler_on"
        else
          new_name = "yatm_refinery:thermal_boiler_off"
        end
        if new_name ~= node.name then
          node.name = new_name
          minetest.swap_node(pos, node)
        end

        maybe_start_node_timer(pos, 1.0)
        yatm.queue_refresh_infotext(pos, node)
      end
    end,
  },
}, {
  off = {
    tiles = {
      "yatm_thermal_boiler_top.off.png",
      "yatm_thermal_boiler_bottom.off.png",
      "yatm_thermal_boiler_side.off.png",
      "yatm_thermal_boiler_side.off.png",
      "yatm_thermal_boiler_side.off.png",
      "yatm_thermal_boiler_side.off.png",
    }
  },

  on = {
    groups = table_merge(groups, {
      not_in_creative_inventory = 1,
    }),

    tiles = {
      "yatm_thermal_boiler_top.on.png",
      "yatm_thermal_boiler_bottom.on.png",
      "yatm_thermal_boiler_side.on.png",
      "yatm_thermal_boiler_side.on.png",
      "yatm_thermal_boiler_side.on.png",
      "yatm_thermal_boiler_side.on.png",
    }
  }
})
