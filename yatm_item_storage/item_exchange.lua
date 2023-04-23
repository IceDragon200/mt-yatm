--- @namespace yatm_item_storage.ItemExchange
local Directions = assert(foundation.com.Directions)
local Vector3 = assert(foundation.com.Vector3)

local ItemDevice = assert(yatm_item_storage.ItemDevice)
local ItemExchange = {}

--- @spec transfer_from_device_to_device(
---   from_pos: Vector3,
---   from_dir: Direction,
---   to_pos: Vector3
---   to_dir: Direction,
---   item_stack_or_count: Integer | ItemStack,
---   commit: Boolean
--- ): void
function ItemExchange.transfer_from_device_to_device(
  from_pos,
  from_dir,
  to_pos,
  to_dir,
  item_stack_or_count,
  commit
)
  local source_stack
  local leftover
  local err
  local okay = false

  source_stack, err = ItemDevice.extract_item(from_pos, from_dir, item_stack_or_count, false)

  if err then
    return false, source_stack, err
  end

  if source_stack and not source_stack:is_empty() then
    leftover, err = ItemDevice.insert_item(to_pos, to_dir, source_stack, commit)

    if err then
      return false, leftover, err
    end

    if leftover then
      source_stack, err = ItemDevice.extract_item(
        from_pos,
        from_dir,
        source_stack:get_count() - leftover:get_count(),
        commit
      )
      okay = true
    end
  end

  return okay, source_stack, err
end

--- @spec transfer_from_device_to_adjacent_device(
---   from_pos: Vector3,
---   local_dir: Direction,
---   item_stack_or_count: Integer | ItemStack,
---   commit: Boolean
--- ): (okay: Boolean, extracted: ItemStack | nil, err: String)
function ItemExchange.transfer_from_device_to_adjacent_device(
  from_pos,
  local_dir,
  item_stack_or_count,
  commit
)
  local node = minetest.get_node_or_nil(from_pos)
  if node then
    local nodedef = minetest.registered_nodes[node.name]
    local dir = local_dir
    if nodedef.paramtype2 == "facedir" then
      dir = Directions.facedir_to_face(node.param2, local_dir)
    end
    local neighbour_pos = Vector3.zero()
    Vector3.add(neighbour_pos, from_pos, Directions.DIR6_TO_VEC3[dir])
    return ItemExchange.transfer_from_device_to_device(
      from_pos,
      dir,
      neighbour_pos,
      Directions.invert_dir(dir),
      item_stack_or_count,
      commit
    )
  end

  return false, nil, "node not found"
end

yatm_item_storage.ItemExchange = ItemExchange
