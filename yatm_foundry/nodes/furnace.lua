local HeatInterface = assert(yatm.heating.HeatInterface)

local heat_interface = HeatInterface.new_simple("heat", 400)
function heat_interface:on_heat_changed(pos, dir, old_heat, new_heat)
  local node = minetest.get_node(pos)
  if math.floor(new_heat) > 0 then
    node.name = "yatm_foundry:furnace_on"
  else
    node.name = "yatm_foundry:furnace_off"
  end
  minetest.swap_node(pos, node)
  yatm.queue_refresh_infotext(pos, node)
  minetest.get_node_timer(pos):start(1.0)
end

local function furnace_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local heat = meta:get_float("heat")

  meta:set_string("infotext",
    "Heat: " .. heat .. " / " .. heat_interface.heat_capacity
  )
end

local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
  heatable_device = 1,
}

yatm.register_stateful_node("yatm_foundry:furnace", {
  basename = "yatm_foundry:furnace",

  description = "Furnace",

  groups = groups,

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    cluster_thermal:schedule_add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    cluster_thermal:schedule_remove_node(pos, node)
  end,

  refresh_infotext = furnace_refresh_infotext,
  thermal_interface = {
    groups = {
      heater = 1,
      thermal_user = 1,
    },

    update_heat = function (self, pos, node, heat, dtime)
      local meta = minetest.get_meta(pos)
      local available_heat = meta:get_float("heat")
      meta:set_float("heat", yatm_core.number_lerp(available_heat, heat, dtime))
      yatm.queue_refresh_infotext(pos, node)
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
    groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),

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
