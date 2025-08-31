local mod = assert(yatm_armoury_c4)

local CONTENT_AIR = assert(core.CONTENT_AIR)
local get_name_from_content_id = assert(core.get_name_from_content_id)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local npo = rawget(_G, "nokore_player_owned")
local set_meta_owner = npo and npo.set_meta_owner
local get_meta_owner = npo and npo.get_meta_owner
npo = nil

--- @private.spec on_detonate(pos: Vector3, node: NodeRef): void
local function on_detonate(pos, node)
  local meta = core.get_meta(pos)
  local owner_name, owner_type = get_meta_owner(meta)
  print("action", "detonating %s, %s", vector.to_string(pos), node.name)
  yatm.blasts.system:create_explosion(pos, "yatm:raycast_explosive", {
    can_ignite = true,
    ignore_protection = false,
    ignore_on_blast = false,
    originator_type = owner_type,
    originator = owner_name,
    min_range = 0,
    max_range = 3,
    intensity = 1,
  })
  -- replace itself, with air
  core.set_node(pos, { name = get_name_from_content_id(CONTENT_AIR) })
end

do
  local function after_place_node(pos, user, item_stack, _pointed_thing)
    local meta = core.get_meta(pos)
    local item_meta = item_stack:get_meta()
    if set_meta_owner then
      set_meta_owner(meta, user)
    end
    return nil
  end

  mod:register_node("c4_tripwired", {
    description = mod.S("C4 (Tripwire Operated)"),

    groups = {
      cracky = nokore.dig_class("wme"),
      oddly_breakable_by_hand = nokore.dig_class("hand"),
      --
      c4 = 1,
      explosive = 1,
      trip_node = 1,
    },

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        {-8/16,-8/16,-6/16,8/16,-3/16,6/16}, -- block
      }
    },

    use_texture_alpha = "opaque",
    tiles = {
      "yatm_c4_plain.top.png",
      "yatm_c4_plain.bottom.png",
      "yatm_c4_plain.side.png",
      "yatm_c4_plain.side.png",
      "yatm_c4_plain.front.png",
      "yatm_c4_plain.front.png",
    },

    on_detonate = on_detonate,
    after_place_node = after_place_node,
  })
end

if foundation.is_module_present("yatm_radio_network") then
  local radio_network = {
    on_message = function (self, pos, node, addr, message)
      local meta = core.get_meta(pos)
      local my_addr = meta:get_string("radio_network_addr")
      local nodedef = core.registered_nodes[node.name]
      -- sanity check
      if addr == my_addr then
        if message == "DETONATE" then
          -- my main objective is to blow up
          if nodedef.on_detonate then
            nodedef.on_detonate(pos, node)
          end
        end
      end
    end,
  }

  local function refresh_infotext(pos, node)
    local nodedef = core.registered_nodes[node.name]
    local meta = core.get_meta(pos)
    local addr = meta:get_string("radio_network_addr")

    local infotext =
      ""
      .. nodedef.short_description .. "\n"
      .. "Radio Address: " .. addr

    meta:set_string("infotext", infotext)
  end

  local function on_timer(pos, _elapsed)
    local meta = core.get_meta(pos)
    local addr = meta:get_string("radio_network_addr")
    yatm_radio_network.radio_network:subscribe_for_messages(pos, addr, 5)
    return true
  end

  local function after_place_node(pos, user, item_stack, _pointed_thing)
    local meta = core.get_meta(pos)
    local node = core.get_node(pos)
    local item_meta = item_stack:get_meta()
    local addr = item_meta:get("radio_network_addr")
    meta:set_string("radio_network_addr", addr)
    if set_meta_owner then
      set_meta_owner(meta, user)
    end
    maybe_start_node_timer(pos, 1)
    yatm.queue_refresh_infotext(pos, node)
    return nil
  end

  local function on_punch(pos, _node, _user, _pointed_thing)
    maybe_start_node_timer(pos, 1)
  end

  mod:register_node("c4_remote", {
    short_description = mod.S("C4 (Remote Operated)"),
    description = mod.S("C4 (Remote Operated)"),

    groups = {
      cracky = nokore.dig_class("wme"),
      oddly_breakable_by_hand = nokore.dig_class("hand"),
      --
      c4 = 1,
      explosive = 1,
      remote_operated = 1,
    },

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        {-8/16,-8/16,-6/16,8/16,-3/16,6/16}, -- block
        {-6/16,-6/16,-7/16,0/16,-1/16,7/16}, -- remote receiver
        {-7/16,-3/16, 4/16,5/16,-2/16, 5/16}, -- antenna
      }
    },

    use_texture_alpha = "opaque",
    tiles = {
      "yatm_c4_remote.top.png",
      "yatm_c4_remote.bottom.png",
      "yatm_c4_remote.side.png",
      "yatm_c4_remote.side.png^[transformFX",
      "yatm_c4_remote.front.png^[transformFX",
      "yatm_c4_remote.front.png",
    },

    radio_network = radio_network,

    on_timer = on_timer,
    after_place_node = after_place_node,
    on_punch = on_punch,
    refresh_infotext = refresh_infotext,

    on_detonate = on_detonate,
  })
end
