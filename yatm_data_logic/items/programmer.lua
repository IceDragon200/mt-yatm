local sounds = assert(yatm.sounds)
local Groups = assert(foundation.com.Groups)
local data_network = assert(yatm.data_network)

local function on_receive_fields(player, form_name, fields, assigns)
  local di = assigns.interface

  local keep_bubbling, formspec_or_refresh =
    di:receive_programmer_fields(player, form_name, fields, assigns)

  local formspec = formspec_or_refresh

  if type(formspec_or_refresh) == "boolean" and formspec_or_refresh then
    formspec = di:get_programmer_formspec(assigns.pos, player, assigns.pointed_thing, assigns)
  end

  if fields.quit then
    sounds:play("action_close", { to_player = player:get_player_name() })
  end

  return keep_bubbling, formspec
end

local function on_formspec_quit(player, form_name, assigns)
  local di = assigns.interface

  if di.on_programmer_formspec_quit then
    di:on_programmer_formspec_quit(assigns.pos, player, assigns)
  end
end

minetest.register_tool("yatm_data_logic:data_programmer", {
  description = "Data Programmer\nRight-click on programmable DATA device.",

  groups = {
    data_programmer = 1,
  },

  inventory_image = "yatm_data_programmer.png",

  on_place = function (itemstack, user, pointed_thing)
    local pos = pointed_thing.under
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if Groups.get_item(nodedef, "data_programmable") then
        local di = data_network:get_data_interface(pos)
        if di then
          local formname = "yatm_data_logic:programmer:" .. minetest.pos_to_string(pos)
          local assigns = {
            pos = pos,
            node = node,
            interface = di,
            formname = formname,
            pointed_thing = pointed_thing,
          }
          local formspec = di:get_programmer_formspec(pos, user, pointed_thing, assigns)

          sounds:play("action_open", { to_player = user:get_player_name() })

          yatm_core.show_bound_formspec(user:get_player_name(), formname, formspec, {
            state = assigns,
            on_receive_fields = on_receive_fields,
            on_quit = on_formspec_quit,
          })
        else
          minetest.chat_send_player(user:get_player_name(), "This node cannot be programmed")
        end
        -- TODO: determine data configuration and display programming interface
        minetest.log("action", user:get_player_name() .. " readies to program " .. node.name)
      end
    end
  end,
})
