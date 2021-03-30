--
-- Thermal Boilers are an alternative to the electric boiler, using the thermal system instead.
--
local Directions = assert(foundation.com.Directions)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local cluster_thermal = yatm.cluster.thermal
local FluidStack = assert(yatm.fluids.FluidStack)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidUtils = assert(yatm.fluids.Utils)
local FluidMeta = assert(yatm.fluids.FluidMeta)

if not cluster_thermal then
  minetest.log("warning", "thermal cluster is not available, skipping thermal boiler")
  return
end

local STEAM_TANK = "steam_tank"
local WATER_TANK = "water_tank"

local function get_fluid_tank_name(self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_UP then
    return STEAM_TANK, self.capacity
  else
    return WATER_TANK, self.capacity
  end
  return nil, nil
end

local fluid_interface = FluidInterface.new_directional(get_fluid_tank_name)
fluid_interface._private.capacity = 16000
fluid_interface._private.bandwidth = fluid_interface._private.capacity

function fluid_interface:on_fluid_changed(pos, dir, _new_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

local function boiler_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local steam_fluid_stack = FluidMeta.get_fluid_stack(meta, STEAM_TANK)
  local water_fluid_stack = FluidMeta.get_fluid_stack(meta, WATER_TANK)

  local heat = math.floor(meta:get_float("heat"))

  local capacity = fluid_interface._private.capacity

  local infotext =
    cluster_thermal:get_node_infotext(pos) .. "\n" ..
    "Heat: " .. heat .. "\n" ..
    "Steam Tank: <" .. FluidStack.pretty_format(steam_fluid_stack, capacity) .. ">\n" ..
    "Water Tank: <" .. FluidStack.pretty_format(water_fluid_stack, capacity) .. ">"

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

  return true
end

yatm.register_stateful_node("yatm_refinery:thermal_boiler", {
  base_description = "Thermal Boiler",
  description = "Thermal Boiler",

  drop = "yatm_refinery:thermal_boiler_off",

  groups = {
    cracky = 1,
    yatm_cluster_thermal = 1,
    heatable_device = 1,
  },

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
    groups = {
      cracky = 1,
      not_in_creative_inventory = 1,
      heatable_device = 1,
      yatm_cluster_thermal = 1,
    },

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
