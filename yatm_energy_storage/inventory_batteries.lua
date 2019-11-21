--
-- Small utility module for dealing with battery inventories.
--
local invbat = {}

function invbat.calc_capacity(inv, list_name)
  local size = inv:get_size(list_name)

  local capacity = 0

  for i = 1,size do
    local stack = inv:get_stack(list_name, i)

    if not stack:is_empty() then
      local en = stack:get_definition().energy
      if en then
        capacity = capacity + en.get_capacity(stack)
      end
    end
  end

  return capacity
end

function invbat.calc_stored_energy(inv, list_name)
  local size = inv:get_size(list_name)

  local stored = 0

  for i = 1,size do
    local stack = inv:get_stack(list_name, i)

    if not stack:is_empty() then
      local en = stack:get_definition().energy
      if en then
        stored = stored + en.get_stored_energy(stack)
      end
    end
  end

  return stored
end

function invbat.receive_energy(inv, list_name, amount)
  local left = amount
  local new_energy = 0

  local size = inv:get_size(list_name)
  for i = 1,size do
    local stack = inv:get_stack(list_name, i)
    if not stack:is_empty() then
      local en = stack:get_definition().energy
      if en then
        if left > 0 then
          local used = en.receive_energy(stack, left)
          left = left - used

          inv:set_stack(list_name, i, stack)
        end

        new_energy = new_energy + en.get_stored_energy(stack)
      end
    end
  end

  return new_energy, amount - left
end

function invbat.consume_energy(inv, list_name, amount)
  local left = amount
  local new_energy = 0

  local size = inv:get_size(list_name)
  for i = 1,size do
    local stack = inv:get_stack(list_name, i)
    local en = stack:get_definition().energy
    if en then
      if left > 0 then
        local consumed = en.consume_energy(stack, left)
        left = left - consumed

        inv:set_stack("batteries", i, stack)
      end

      new_energy = new_energy + en.get_stored_energy(stack)
    end
  end

  return new_energy, amount - left
end

yatm_energy_storage.inventory_batteries = invbat
