local SpacetimeMeta = assert(yatm.spacetime.SpacetimeMeta)

local function address_tool_on_place(itemstack, placer, pointed_thing)
  if pointed_thing.type == "node" then
    local pos = pointed_thing.under
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if yatm_core.groups.get_item(nodedef, "addressable_spacetime_device") then
        local meta = minetest.get_meta(pos)
        local address = SpacetimeMeta.copy_address(meta, itemstack:get_meta())
        if placer and placer:is_player() then
          if yatm_core.is_blank(address) then
            itemstack:get_meta():set_string("description", nil)
            minetest.chat_send_player(placer:get_player_name(), "Blank Address!")
          else
            itemstack:get_meta():set_string("description", "Address Tool <" .. address .. ">")
            minetest.chat_send_player(placer:get_player_name(), "Address Copied!")
          end
        end
      end
    end
  end
  return itemstack
end

function yatm_spacetime.default_change_spacetime_address(pos, node, new_address)
  local meta = minetest.get_meta(pos)
  address = SpacetimeMeta.set_address(meta, new_address)
end

local function address_tool_on_use(itemstack, user, pointed_thing)
  if pointed_thing.type == "node" then
    local pos = pointed_thing.under
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if yatm_core.groups.get_item(nodedef, "addressable_spacetime_device") then
        local address = nil
        if nodedef.change_spacetime_address then
          local new_address = SpacetimeMeta.get_address(itemstack:get_meta())
          address = nodedef.change_spacetime_address(pos, node, new_address)
        else
          yatm_spacetime.default_change_spacetime_address(pos, node, new_address)
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
