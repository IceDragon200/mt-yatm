local mod = yatm_energy_storage
local EnergyUtil = assert(yatm.energy)

local materials = {
  {"copper", "Copper"},
  {"bronze", "Bronze"},
  {"gold", "Gold"},
  {"iron", "Iron"},
  {"carbon_steel", "Carbon Steel"},
}

local material_capacity = {
  -- some placeholder values for now, until I balance it
  copper = 1000,
  bronze = 2000,
  gold = 4000,
  iron = 8000,
  carbon_steel = 16000,
}

-- @private.spec battery_refresh_wear(ItemStack): void
local function battery_refresh_wear(item_stack)
  local meta = item_stack:get_meta()
  local energy = meta:get_float("energy")
  local capacity = item_stack:get_definition().energy.capacity
  -- Always force the wear gauge to be visible
  item_stack:set_wear(1 + 0xFFFD - math.floor(energy * 0xFFFD / capacity))
end

-- @private.spec battery_get_capacity(ItemStack): Integer
local function battery_get_capacity(item_stack)
  return item_stack:get_definition().energy.capacity
end

-- @private.spec battery_get_stored_energy(ItemStack): Integer
local function battery_get_stored_energy(item_stack)
  local meta = item_stack:get_meta()
  return meta:get_float("energy")
end

-- @private.spec battery_consume_energy(ItemStack, amount: Integer): Integer
local function battery_consume_energy(item_stack, amount)
  local meta = item_stack:get_meta()
  local energy = meta:get_float("energy")
  local capacity = battery_get_capacity(item_stack)

  local new_energy, used = EnergyUtil.calc_consumed_energy(energy, amount, capacity, capacity)
  meta:set_float("energy", new_energy)
  item_stack:get_definition().refresh_wear(item_stack)

  return used
end

-- @private.spec battery_receive_energy(ItemStack, amount: Integer): Integer
local function battery_receive_energy(item_stack, amount)
  local meta = item_stack:get_meta()
  local energy = meta:get_float("energy")
  local capacity = battery_get_capacity(item_stack)

  local new_energy, used = EnergyUtil.calc_received_energy(energy, amount, capacity, capacity)
  meta:set_float("energy", new_energy)
  item_stack:get_definition().refresh_wear(item_stack)

  return used
end

-- @private.spec creative_battery_get_stored_energy(ItemStack): Integer
local function creative_battery_get_stored_energy(item_stack)
  return item_stack:get_definition().energy.capacity
end

-- @private.spec creative_battery_consume_energy(ItemStack, amount: Integer): Integer
local function creative_battery_consume_energy(_item_stack, amount)
  return amount
end

-- @private.spec creative_battery_receive_energy(ItemStack, amount: Integer): Integer
local function creative_battery_receive_energy(_item_stack, amount)
  return amount
end

for _,material_pair in ipairs(materials) do
  local material_basename = material_pair[1]
  local material_name = material_pair[2]

  local capacity = material_capacity[material_basename]

  minetest.register_tool("yatm_energy_storage:battery_" .. material_basename, {
    basename = "yatm_energy_storage:battery",
    base_description = mod.S("Battery"),

    description = mod.S(material_name .. " Battery\nCapacity: " .. capacity),
    inventory_image = "yatm_materials_battery." .. material_basename .. ".png",

    groups = {
      battery = 1,
      ["battery_" .. material_basename] = 1,
      energy_storage = 1,
    },

    material_name = material_basename,

    energy = {
      capacity = capacity,
      get_capacity = battery_get_capacity,
      get_stored_energy = battery_get_stored_energy,
      consume_energy = battery_consume_energy,
      receive_energy = battery_receive_energy,
    },

    refresh_wear = battery_refresh_wear,
  })
end

minetest.register_tool("yatm_energy_storage:battery_creative", {
  basename = "yatm_energy_storage:battery",
  base_description = mod.S("Battery"),

  description = mod.S("Creative Battery\nCapacity: ∞"),
  inventory_image = "yatm_materials_battery.creative.png",

  groups = {
    battery = 1,
    ["battery_creative"] = 1,
    energy_storage = 1,
  },

  material_name = "creative",

  energy = {
    capacity = 0xFFFFFFFF,
    get_capacity = battery_get_capacity,
    get_stored_energy = creative_battery_get_stored_energy,
    consume_energy = creative_battery_consume_energy,
    receive_energy = creative_battery_receive_energy,
  },

  refresh_wear = battery_refresh_wear,
})
