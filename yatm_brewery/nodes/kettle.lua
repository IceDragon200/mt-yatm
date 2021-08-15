local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local Directions = assert(foundation.com.Directions)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local table_merge = assert(foundation.com.table_merge)
local cluster_thermal = assert(yatm.cluster.thermal)
local brewing_registry = assert(yatm.brewing.brewing_registry)
local ItemInterface = assert(yatm.items.ItemInterface)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidExchange = assert(yatm.fluids.FluidExchange)

local tank_capacity = 4000
local fluid_interface = FluidInterface.new_directional(function (self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_DOWN or new_dir == Directions.D_UP then
    return "input_fluid_tank", tank_capacity
  else
    return "output_fluid_tank", tank_capacity
  end
end)

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = Directions.facedir_to_face(node.param2, dir)
  if new_dir == Directions.D_DOWN or new_dir == Directions.D_UP then
    return "input_item"
  else
    return "output_item"
  end
end)

local function kettle_on_construct(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  inv:set_size("input_item", 1)
  inv:set_size("output_item", 1)
  inv:set_size("processing_item", 1)
end

local function kettle_on_timer(pos, dt)
  local meta = minetest.get_meta(pos)
  local available_heat = meta:get_float("heat")
  if available_heat > 0 then
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    --local node = minetest.get_node(pos)

    local remaining_time = meta:get_float("remaining_time")
    if remaining_time > 0 then
      remaining_time = math.max(remaining_time - dt, 0)

      if remaining_time < 0 then
        local stack = inv:get_stack("processing_item", 1)
        local fluid_stack = FluidMeta.get_fluid_stack(meta, "processing_fluid_tank")

        local input = {
          item = stack,
          fluid = fluid_stack
        }

        local recipe = brewing_registry:get_brewing_recipe(input)
        if recipe then
        else
          -- refund
          inv:add_item("input_item", stack)
          inv:remove_item("processing_item", stack)
          local transferred_fluid_stack =
            FluidExchange.transfer_from_meta_to_meta(
              meta,
              {
                tank_name = "processing_fluid_tank",
                capacity = tank_capacity,
                bandwidth = tank_capacity
              },
              fluid_stack,
              meta,
              {
                tank_name = "input_fluid_tank",
                capacity = tank_capacity,
                bandwidth = tank_capacity
              },
              true
            )

          if transferred_fluid_stack.amount == fluid_stack.amount then
            -- TODO: exit refund state
          else
            -- TODO: keep refund state
          end
        end
      end
    end

    if remaining_time <= 0 then
      local stack = inv:get_stack("input_item", 1)

      if not stack:is_empty() then
        local fluid_stack = FluidMeta.get_fluid_stack(meta, "input_fluid_tank")
        local input = {
          item = stack,
          fluid = fluid_stack
        }

        local recipe = brewing_registry:get_brewing_recipe(input)
        if recipe then
          meta:set_float("remaining_time", recipe.duration)
        end
      end
    end
    return true
  else
    return false
  end
end

local thermal_interface = {
  groups = {
    heater = 1,
    thermal_user = 1,
  },

  update_heat = function (self, pos, node, heat, dtime)
    local meta = minetest.get_meta(pos)

    if yatm.thermal.update_heat(meta, "heat", heat, 10, dtime) then
      local new_name
      if math.floor(heat) > 0 then
        new_name = "yatm_brewery:kettle_on"
      else
        new_name = "yatm_brewery:kettle_off"
      end
      if new_name ~= node.name then
        node.name = new_name
        minetest.swap_node(pos, node)
      end

      maybe_start_node_timer(pos, 1.0)

      yatm.queue_refresh_infotext(pos, node)
    end
  end,
}

local groups = {
  -- Tool groups
  cracky = 1,
  -- Node type
  kettle = 1,
  -- Item Interface groups
  item_interface_in = 1,
  item_interface_out = 1,
  -- Fluid Interface groups
  fluid_interface_in = 1,
  fluid_interface_out = 1,
  -- Heat Interface groups
  heat_interface_in = 1,
  heatable_device = 1,
}

local kettle_node_box = {
  type = "fixed",
  fixed = {
    -- legs
    ng(2, 0, 2, 3, 2, 3),
    ng(11,0, 2, 3, 2, 3),
    ng(2, 0,11, 3, 2, 3),
    ng(11,0,11, 3, 2, 3),
    --
    ng(1, 2, 1,14, 3,14), -- base plate
    --
    ng(0, 4, 0,16,12, 2), -- north side
    ng(0, 4,14,16,12, 2), -- south side
    ng(0, 4, 0, 2,12,16), -- west side
    ng(14,4, 0, 2,12,16), -- east side
  },
}

yatm.register_stateful_node("yatm_brewery:kettle", {
  description = "Kettle",

  drop = "yatm_brewery:kettle_off",

  groups = groups,

  drawtype = "nodebox",
  node_box = kettle_node_box,

  paramtype = "none",
  paramtype2 = "facedir",

  on_construct = kettle_on_construct,
  on_timer = kettle_on_timer,

  fluid_interface = fluid_interface,
  item_interface = item_interface,
  thermal_interface = thermal_interface,
}, {
  off = {
    tiles = {
      "yatm_kettle_top.png",
      "yatm_kettle_bottom.png",
      "yatm_kettle_side.png",
      "yatm_kettle_side.png",
      "yatm_kettle_side.png",
      "yatm_kettle_side.png",
    },
  },

  on = {
    groups = table_merge(groups, {not_in_creative_inventory = 1}),

    tiles = {
      "yatm_kettle_top.png",
      "yatm_kettle_bottom.png",
      "yatm_kettle_side.png",
      "yatm_kettle_side.png",
      "yatm_kettle_side.png",
      "yatm_kettle_side.png",
    },
  },
})
