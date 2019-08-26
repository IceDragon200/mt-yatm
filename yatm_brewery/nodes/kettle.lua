local ItemInterface = assert(yatm.items.ItemInterface)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local HeatInterface = assert(yatm.heating.HeatInterface)
local brewing_registry = assert(yatm.brew.brewing_registry)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidExchange = assert(yatm.fluids.FluidExchange)

local tank_capacity = 4000
local fluid_interface = FluidInterface.new_directional(function (self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_DOWN or new_dir == yatm_core.D_UP then
    return "input_fluid_tank", tank_capacity
  else
    return "output_fluid_tank", tank_capacity
  end
end)

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
  local node = minetest.get_node(pos)
  local new_dir = yatm_core.facedir_to_face(node.param2, dir)
  if new_dir == yatm_core.D_DOWN or new_dir == yatm_core.D_UP then
    return "input_item"
  else
    return "output_item"
  end
end)

local heat_interface = HeatInterface.new_simple("heat", 400)

function heat_interface:on_heat_changed(pos, node, old_heat, new_heat)
  if math.floor(new_heat) > 0 then
    minetest.swap_node(pos, {name = "yatm_brewery:kettle_on"})
  else
    minetest.swap_node(pos, {name = "yatm_brewery:kettle_off"})
  end
  yatm_core.queue_refresh_infotext(pos)
  minetest.get_node_timer(pos):start(1.0)
end

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
  heated_device = 1,
}

local kettle_node_box = {
  type = "fixed",
  fixed = {
    -- legs
    yatm_core.Cuboid:new(2, 0, 2, 3, 2, 3):fast_node_box(),
    yatm_core.Cuboid:new(11,0, 2, 3, 2, 3):fast_node_box(),
    yatm_core.Cuboid:new(2, 0,11, 3, 2, 3):fast_node_box(),
    yatm_core.Cuboid:new(11,0,11, 3, 2, 3):fast_node_box(),
    --
    yatm_core.Cuboid:new(1, 2, 1,14, 3,14):fast_node_box(), -- base plate
    --
    yatm_core.Cuboid:new(0, 4, 0,16,12, 2):fast_node_box(), -- north side
    yatm_core.Cuboid:new(0, 4,14,16,12, 2):fast_node_box(), -- south side
    yatm_core.Cuboid:new(0, 4, 0, 2,12,16):fast_node_box(), -- west side
    yatm_core.Cuboid:new(14,4, 0, 2,12,16):fast_node_box(), -- east side
  },
}

minetest.register_node("yatm_brewery:kettle_off", {
  description = "Kettle",

  groups = groups,

  drawtype = "nodebox",
  node_box = kettle_node_box,
  tiles = {
    "yatm_kettle_top.png",
    "yatm_kettle_bottom.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = kettle_on_construct,
  on_timer = kettle_on_timer,

  fluid_interface = fluid_interface,
  item_interface = item_interface,
  heat_interface = heat_interface,
})

minetest.register_node("yatm_brewery:kettle_on", {
  description = "Kettle",

  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = "yatm_brewery:kettle_off",

  drawtype = "nodebox",
  node_box = kettle_node_box,
  tiles = {
    "yatm_kettle_top.png",
    "yatm_kettle_bottom.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
    "yatm_kettle_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = kettle_on_construct,
  on_timer = kettle_on_timer,

  fluid_interface = fluid_interface,
  item_interface = item_interface,
  heat_interface = heat_interface,
})
