local function address_tool_on_place(itemstack, placer, pointed_thing)
  if pointed_thing.type == "node" then
    local pos = pointed_thing.under
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if yatm_core.groups.get_item(nodedef, "addressable_spacetime_device") then
        local meta = minetest.get_meta(pos)
        local address = yatm_spacetime.copy_address_in_meta(meta, itemstack:get_meta())
        if placer and placer:is_player() then
          if yatm_core.is_blank(address) then
            minetest.chat_send_player(placer:get_player_name(), "Blank Address!")
          else
            minetest.chat_send_player(placer:get_player_name(), "Address Copied!")
          end
        end
      end
    end
  end
  return itemstack
end

local function address_tool_on_use(itemstack, user, pointed_thing)
  if pointed_thing.type == "node" then
    local node = minetest.get_node(pointed_thing.under)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if yatm_core.groups.get_item(nodedef, "addressable_spacetime_device") then
        local address = nil
        if nodedef.change_address then
          local new_address = yatm_spacetime.get_address_in_meta(itemstack:get_meta())
          address = nodedef.change_address(pointed_thing.under, node, new_address)
        else
          local meta = minetest.get_meta(pointed_thing.under)
          address = yatm_spacetime.copy_address_in_meta(itemstack:get_meta(), meta)
        end
        if user and user:is_player() then
          if yatm_core.is_blank(address) then
            minetest.chat_send_player(user:get_player_name(), "Address Cleared!")
          else
            minetest.chat_send_player(user:get_player_name(), "Address Pasted!")
          end
        end
      end
    end
  end
  return itemstack
end

minetest.register_tool("yatm_spacetime:address_tool", {
  description = "Address Tool",

  inventory_image = "yatm_address_tool.png",

  stack_max = 1,

  on_place = address_tool_on_place,
  on_use = address_tool_on_use,
})
