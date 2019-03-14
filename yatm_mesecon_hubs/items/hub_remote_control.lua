local NetworkMeta = assert(yatm.mesecon_hubs.NetworkMeta)
local Network = assert(yatm.mesecon_hubs.Network)

local function hub_remote_control_on_place(itemstack, placer, pointed_thing)
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
            itemstack:get_meta():set_string("description", "Hub Remote Control for <" .. address .. ">")
            minetest.chat_send_player(placer:get_player_name(), "Hub Address Copied!")
          end
        end
      end
    end
  end
  return itemstack
end

local function hub_remote_control_on_use(itemstack, user, pointed_thing)
  local address = NetworkMeta.get_hub_address(itemstack:get_meta())
  if yatm_core.is_blank(address) then
    -- Don't do shit.
    minetest.chat_send_player(user:get_player_name(), "No Target Address")
  else
    local last_state = itemstack:get_meta():get_int("last_state")
    local new_state = 0
    if last_state == 0 then
      new_state = 1
    else
      new_state = 0
    end
    itemstack:get_meta():set_int("last_state", new_state)
    Network.emit_value(user:get_pos(), address, new_state)
    minetest.chat_send_player(user:get_player_name(), "Toggled " .. address .. " " .. new_state)
  end
  return itemstack
end

minetest.register_tool("yatm_mesecon_hubs:hub_remote_control", {
  description = "Hub Remote Control",

  inventory_image = "yatm_hub_remote_control.png",

  stack_max = 1,

  on_place = hub_remote_control_on_place,
  on_use = hub_remote_control_on_use,
})
