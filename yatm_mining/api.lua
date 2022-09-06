local add_items = assert(foundation.com.InventoryList.add_items)
local item_list_copy = assert(foundation.com.InventoryList.copy)

-- @namespace yatm.mining

yatm.mining = yatm.mining or {}

--
-- Specialized dig/remove node function for quarries and surface drills
--
-- @spec drill_node_to_meta_inventory(
--   pos: Vector3,
--   meta: MetaRef,
--   list_name: String
-- ): NodeRef
function yatm.mining.drill_node_to_meta_inventory(pos, meta, list_name)
  local node = minetest.get_node_or_nil(pos)
  if node.name == "air" then
    return node
  elseif node then
    local drops = minetest.get_node_drops(node, nil)

    local inv = meta:get_inventory()
    local list = inv:get_list(list_name)
    if list then
      list = item_list_copy(list)

      local leftovers = add_items(list, drops)

      if not next(leftovers) then
        inv:set_list(list_name, list)
        minetest.remove_node(pos)
        return node
      end
    end
  end

  return nil
end
