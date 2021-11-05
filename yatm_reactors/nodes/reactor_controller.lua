local cluster_reactor = assert(yatm.cluster.reactor)
local fspec = assert(foundation.com.formspec.api)

local function reactor_controller_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_reactor:get_node_infotext(pos)

  meta:set_string("infotext", infotext)
end

local function get_reactor_controller_formspec(pos, node, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset

  return yatm.formspec_render_split_inv_panel(user, 8, 2, { bg = "machine_radioactive" }, function (loc, rect)
    if loc == "main_body" then
      if node.name == "yatm_reactors:reactor_controller_on" then
        return fspec.button(rect.x, rect.y, 4, 2, "stop", "Stop")
      else
        return fspec.button(rect.x, rect.y, 4, 2, "start", "Start")
      end
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

local function reactor_controller_on_receive_fields(player, formname, fields, assigns)
  local node = minetest.get_node(assigns.pos)
  --local nodedef = minetest.registered_nodes[node.name]

  if fields["start"] then
    --node.name = nodedef.reactor_device.states.on
    cluster_reactor:schedule_start_reactor(assigns.pos, node, player:get_player_name())
  elseif fields["stop"] then
    --node.name = nodedef.reactor_device.states.off
    cluster_reactor:schedule_stop_reactor(assigns.pos, node, player:get_player_name())
  end

  --minetest.swap_node(assigns.pos, node)

  return true
end

local function reactor_controller_on_rightclick(pos, node, user)
  local formspec_name = "yatm_reactors:reactor_controller:" .. minetest.pos_to_string(pos)
  local assigns = { pos = pos, node = node }
  local formspec = get_reactor_controller_formspec(pos, node, user, assigns)

  nokore.formspec_bindings:show_formspec(user:get_player_name(), formspec_name, formspec, {
    state = assigns,
    on_receive_fields = reactor_controller_on_receive_fields
  })
end

local reactor_controller_reactor_device = {
  kind = "controller",

  groups = {
    controller = 1,
  },

  default_state = "off",

  states = {
    conflict = "yatm_reactors:reactor_controller_error",
    error = "yatm_reactors:reactor_controller_error",
    off = "yatm_reactors:reactor_controller_off",
    on = "yatm_reactors:reactor_controller_on",
    idle = "yatm_reactors:reactor_controller_idle",
  }
}

yatm_reactors.register_stateful_reactor_node({
  basename = "yatm_reactors:reactor_controller",

  description = "Reactor Controller",

  codex_entry_id = "yatm_reactors:reactor_controller",

  groups = {cracky = 1},

  drop = reactor_controller_reactor_device.states.off,

  tiles = {
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_controller_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  reactor_device = reactor_controller_reactor_device,

  refresh_infotext = reactor_controller_refresh_infotext,

  on_rightclick = reactor_controller_on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_controller_front.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_controller_front.on.png"
    },
  },
  idle = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_controller_front.idle.png"
    },
  }
})
