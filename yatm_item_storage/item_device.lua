local ItemDevice = {}

function ItemDevice.get_item(pos, dir)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.item_interface then
      if nodedef.item_interface.get_item then
        return nodedef.item_interface:get_item(pos, dir)
      else
        return nil, "no get_item/2"
      end
    else
      return nil, "no item_interface"
    end
  end
  return nil, "undefined node"
end

function ItemDevice.room_for_item(pos, dir, item_stack)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.item_interface then
      if nodedef.item_interface.room_for_item then
        --print("ItemDevice.room_for_item/3", minetest.pos_to_string(pos), yatm_core.inspect_axis(dir), yatm_core.itemstack_inspect(item_stack))
        return nodedef.item_interface:room_for_item(pos, dir, item_stack)
      else
        return nil, "no room_for_item/3"
      end
    else
      return nil, "no item_interface"
    end
  end
  return nil, "undefined node"
end

function ItemDevice.insert_item(pos, dir, item_stack, commit)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.item_interface then
      if nodedef.item_interface.insert_item then
        --print("ItemDevice.insert_item/4", minetest.pos_to_string(pos), yatm_core.inspect_axis(dir), yatm_core.itemstack_inspect(item_stack), commit)
        return nodedef.item_interface:insert_item(pos, dir, item_stack, commit)
      else
        return nil, "no insert_item/4"
      end
    else
      return nil, "no item_interface"
    end
  end
  return nil, "undefined node"
end

function ItemDevice.extract_item(pos, dir, item_stack_or_count, commit)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    if nodedef.item_interface then
      if nodedef.item_interface.extract_item then
        return nodedef.item_interface:extract_item(pos, dir, item_stack_or_count, commit)
      else
        return nil, "no extract_item/4"
      end
    else
      return nil, "no item_interface"
    end
  end
  return nil, "undefined node"
end

yatm_item_storage.ItemDevice = ItemDevice
