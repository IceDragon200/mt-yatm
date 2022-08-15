local Groups = assert(foundation.com.Groups)

function yatm.security.on_rightclick_access_card(pos, node, clicker, itemstack, pointed_thing)
  local meta = minetest.get_meta(pos)
  local nodedef = minetest.registered_nodes[node.name]
  local inv = meta:get_inventory()

  local access_card = inv:get_stack("access_card_slot", 1)

  if access_card:is_empty() then
    if not itemstack:is_empty() then
      local item = itemstack:get_definition()
      if Groups.has_group(item, "access_card") then
        local leftover = inv:add_item("access_card_slot", itemstack)
        if leftover:is_empty() then
          -- take the access card away from player
          itemstack:take_item(1)

          if nodedef.on_access_card_inserted then
            nodedef.on_access_card_inserted(pos, node, inv:get_stack("access_card_slot", 1))
          end
        end
      end
    end
  else
    if itemstack:is_empty() then
      local leftover = itemstack:add_item(access_card)
      if leftover:is_empty() then
        inv:remove_item("access_card_slot", access_card)

        if nodedef.on_access_card_removed then
          nodedef.on_access_card_removed(pos, node, access_card)
        end
      end
    end
  end
end
