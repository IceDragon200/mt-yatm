-- @namespace yatm_bees
local WeightedList = assert(foundation.com.WeightedList)

-- @class BaitCatchesRegistry
local BaitCatchesRegistry = foundation.com.Class:extends('yatm.bees.BaitCatchesRegistry')
local ic = BaitCatchesRegistry.instance_class

--
-- @spec #initialize(): void
function ic:initialize()
  -- @member m_index: { [bait_item_name: String]: WeightedList<{ name: String, count: Integer }> }
  self.m_index = {}
end

--
-- @spec #clear(): void
function ic:clear()
  self.m_index = {}
end

--
-- @spec #register_catch(bait_name: String, result: Table | String, weight: Integer): void
function ic:register_catch(bait_name, result, weight)
  assert(type(bait_name) == "string", "expected `bait_name` to be string")

  if type(result) == "string" then
    -- always set a table
    result = { name = result }
  end

  if type(result) == "table" then
    assert(result.name, "expected `result` to have a `name` field")
  else
    error("expected `result` to be table of string")
  end

  if not self.m_index[bait_name] then
    self.m_index[bait_name] = WeightedList:new()
  end
  self.m_index[bait_name]:push(result, weight)
end

--
-- @spec #random_catch(bait_name: String): Table | nil
function ic:random_catch(bait_name)
  assert(type(bait_name) == "string", "expected `bait_name` to be string")

  local list = self.m_index[bait_name]

  if list then
    return list:random()
  end
  return nil
end

yatm_bees.BaitCatchesRegistry = BaitCatchesRegistry
