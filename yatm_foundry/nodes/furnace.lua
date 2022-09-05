local table_merge = assert(foundation.com.table_merge)
local maybe_start_node_timer = assert(foundation.com.maybe_start_node_timer)
local cluster_thermal = assert(yatm.cluster.thermal)

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local heat = meta:get_float("heat")

  meta:set_string("infotext",
    cluster_thermal:get_node_infotext(pos) .. "\n" ..
    "Heat: " .. math.floor(heat)
  )
end

local function maybe_initialize_inventory(meta)
  local inv = meta:get_inventory()

  inv:set_size("input_slot", 1)
  inv:set_size("processing_slot", 1)
  inv:set_size("output_slot", 1)
end

local function on_construct(pos)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)

  cluster_thermal:schedule_add_node(pos, node)
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local meta = minetest.get_meta(pos)
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_heated" }, function (loc, rect)
    if loc == "main_body" then
      return fspec.list(
          node_inv_name,
          "input_slot",
          rect.x,
          rect.y,
          1,
          1
        ) ..
        fspec.list(
          node_inv_name,
          "processing_slot",
          rect.x + cio(2),
          rect.y,
          1,
          1
        )
    elseif loc == "footer" then
      return fspec.list_ring(node_inv_name, "input_slot") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_foundry:furnace:"..Vector3.to_string(pos)
end

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, user)
  local state = {
    pos = pos,
    node = node,
  }
  local meta = minetest.get_meta(pos)
  maybe_initialize_inventory(meta)

  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
      timers = {
        -- routinely update the formspec
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
end

local groups = {
  cracky = nokore.dig_class("copper"),
  --
  item_interface_in = 1,
  item_interface_out = 1,
  heatable_device = 1,
  yatm_cluster_thermal = 1,
}

yatm.register_stateful_node("yatm_foundry:furnace", {
  basename = "yatm_foundry:furnace",

  description = "Furnace",

  codex_entry_id = "yatm_foundry:furnace",

  groups = groups,

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("stone"),

  on_construct = on_construct,

  after_destruct = function (pos, node)
    cluster_thermal:schedule_remove_node(pos, node)
  end,

  on_timer = function (pos, elapsed)
    return true
  end,

  refresh_infotext = refresh_infotext,

  on_rightclick = on_rightclick,

  thermal_interface = {
    groups = {
      heater = 1,
      thermal_user = 1,
    },

    update_heat = function (self, pos, node, heat, dtime)
      local meta = minetest.get_meta(pos)

      if yatm.thermal.update_heat(meta, "heat", heat, 10, dtime) then
        local new_name
        if math.floor(heat) > 0 then
          new_name = "yatm_foundry:furnace_on"
        else
          new_name = "yatm_foundry:furnace_off"
        end
        if new_name ~= node.name then
          node.name = new_name
          minetest.swap_node(pos, node)
        end

        maybe_start_node_timer(pos, 1.0)
        yatm.queue_refresh_infotext(pos, node)
      end
    end,
  },
}, {
  off = {
    tiles = {
      "yatm_furnace_top.off.png",
      "yatm_furnace_bottom.off.png",
      "yatm_furnace_side.off.png",
      "yatm_furnace_side.off.png^[transformFX",
      "yatm_furnace_back.off.png",
      "yatm_furnace_front.off.png"
    },

  },
  on = {
    groups = table_merge(groups, {not_in_creative_inventory = 1}),

    tiles = {
      "yatm_furnace_top.on.png",
      "yatm_furnace_bottom.on.png",
      "yatm_furnace_side.on.png",
      "yatm_furnace_side.on.png^[transformFX",
      "yatm_furnace_back.on.png",
      "yatm_furnace_front.on.png"
    },
  }
})
