local mod = assert(yatm_armoury_c4)

local random_addr16 = assert(foundation.com.random_addr16)
local init_radio_network_addr = assert(yatm_armoury_c4.init_radio_network_addr)

mod:register_tool("c4_detonator", {
  description = mod.S("C4 Detonator"),

  groups = {
    c4_detonator = 1,
  },

  inventory_image = "yatm_c4_detonator.png",

  on_place = function (itemstack, user, pointed_thing)
    if user and user.is_player() then
      local remote_c4_name = mod:make_name("c4_remote")
      local remote_c4_req = ItemStack(remote_c4_name)

      local inv = user:get_inventory()

      -- Let's attempt to take a remote c4 from the user's inventory
      local removed = inv:remove_item("main", remote_c4_req)

      if not removed:is_empty() then
        -- grab the actual definition
        local itemdef = removed:get_definition()

        -- attempt to trigger its on_place
        if itemdef.on_place then
          init_radio_network_addr(removed)
          local replacement, place_to = itemdef.on_place(removed, user, pointed_thing)
          if replacement then
            -- chances are the below should never trigger, since we took exactly 1 item
            if not replacement:is_empty() then
              inv:add_item("main", replacement)
            end
          else
            -- put it back, at least try to
            inv:add_item("main", removed)
          end
        end
      end
    end
    return itemstack
  end,

  on_use = function (itemstack, _user, _pointed_thing)
    -- TODO: detonate all nearby remote c4s under the same address
    return nil
  end,
})
