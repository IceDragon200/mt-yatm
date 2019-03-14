local NetworkMeta = assert(yatm.mesecon_hubs.NetworkMeta)

local function address_tool_on_place(itemstack, placer, pointed_thing)
  if pointed_thing.type == "node" then
    local pos = pointed_thing.under
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if yatm_core.groups.get_item(nodedef, "addressable_hub_device") then
        local meta = minetest.get_meta(pos)
        NetworkMeta.copy_hub_address(meta, itemstack:get_meta())
        local address = NetworkMeta.get_hub_address(itemstack:get_meta())
        if placer and placer:is_player() then
          if yatm_core.is_blank(address) then
            itemstack:get_meta():set_string("description", nil)
            minetest.chat_send_player(placer:get_player_name(), "No Hub Address!")
          else
            itemstack:get_meta():set_string("description", "Hub Address Tool <" .. address .. ">")
            minetest.chat_send_player(placer:get_player_name(), "Hub Address Copied!")
          end
        end
      end
    end
  end
  return itemstack
end

function yatm_mesecon_hubs.default_change_address(pos, node, new_address)
  local meta = minetest.get_meta(pos)
  address = NetworkMeta.set_hub_address(meta, new_address)
end

local function address_tool_on_use(itemstack, user, pointed_thing)
  if pointed_thing.type == "node" then
    local node = minetest.get_node(pointed_thing.under)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if yatm_core.groups.get_item(nodedef, "addressable_hub_device") then
        local address = nil
        local new_address = NetworkMeta.get_hub_address(itemstack:get_meta())
        if yatm_core.is_blank(new_address) then
          minetest.chat_send_player(user:get_player_name(), "No Address to paste!")
        else
          if nodedef.change_hub_address then
            address = nodedef.change_hub_address(pointed_thing.under, node, new_address)
          else
            yatm_mesecon_hubs.default_change_address(pointed_thing.under, node, new_address)
          end
          if user and user:is_player() then
            if yatm_core.is_blank(address) then
              minetest.chat_send_player(user:get_player_name(), "Hub Address Cleared!")
            else
              minetest.chat_send_player(user:get_player_name(), "Hub Address Pasted!")
            end
          end
        end
      end
    end
  end
  return itemstack
end

minetest.register_tool("yatm_mesecon_hubs:hub_address_tool", {
  description = "Hub Address Tool",

  inventory_image = "yatm_hub_address_tool.png",

  stack_max = 1,

  on_place = address_tool_on_place,
  on_use = address_tool_on_use,
})
