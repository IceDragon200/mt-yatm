local mod = assert(yatm_armoury_c4)

local init_meta_radio_network_addr = assert(yatm_armoury_c4.init_meta_radio_network_addr)
local copy_meta_radio_network_addr = assert(yatm_armoury_c4.copy_meta_radio_network_addr)
local get_item_stack_radio_network_addr = assert(yatm_armoury_c4.get_item_stack_radio_network_addr)
local get_meta_radio_network_addr = assert(yatm_armoury_c4.get_meta_radio_network_addr)
local radio_network = assert(yatm_radio_network.radio_network)

local function on_place(item_stack, user, pointed_thing)
  if user and user:is_player() then
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
        do
          local meta = item_stack:get_meta()
          init_meta_radio_network_addr(meta)
          local detonator = item_stack:get_definition()
          local addr = get_meta_radio_network_addr(meta)
          meta:set_string("description",
            string.format("%s\nRadio Address: %s", detonator.description, addr)
          )
          copy_meta_radio_network_addr(meta, removed:get_meta())
        end
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

        if place_to then
          core.log(
            "action",
            string.format("%s placed a remotely detonated c4 at %s",
              user:get_player_name(),
              vector.to_string(place_to)
            )
          )
        end
      end
    end
  end
  print(string.format("%s", item_stack:to_string()))
  return item_stack
end

mod:register_tool("c4_detonator", {
  short_description = mod.S("C4 Detonator"),
  description = mod.S("C4 Detonator"),

  groups = {
    c4_detonator = 1,
  },

  inventory_image = "yatm_c4_detonator.png",

  on_place = on_place,

  on_use = function (item_stack, user, _pointed_thing)
    local addr = get_item_stack_radio_network_addr(item_stack)
    if addr then
      local message = "DETONATE"
      local player_name = user:get_player_name()
      radio_network:publish_message(addr, message, { player_name = player_name })
      core.log("action", string.format("%s triggered detonator for %s", player_name, addr))
    else
      core.log("info", "attempted to detonate c4s ... but nothing happened")
    end
    return nil
  end,
})
