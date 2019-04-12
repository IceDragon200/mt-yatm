local HeatInterface = assert(yatm.heating.HeatInterface)

local heat_interface = HeatInterface.new_simple("heat", 400)
function heat_interface:on_heat_changed(pos, node, old_heat, new_heat)
  if math.floor(new_heat) > 0 then
    minetest.swap_node(pos, {name = "yatm_foundry:kiln_on"})
  else
    minetest.swap_node(pos, {name = "yatm_foundry:kiln_off"})
  end
  yatm_core.queue_refresh_infotext(pos)
end

local function kiln_refresh_infotext(pos)
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

minetest.register_node("yatm_foundry:kiln_off", {
  description = "Kiln",
  groups = groups,
  tiles = {
    "yatm_kiln_top.off.png",
    "yatm_kiln_bottom.off.png",
    "yatm_kiln_side.off.png",
    "yatm_kiln_side.off.png^[transformFX",
    "yatm_kiln_back.off.png",
    "yatm_kiln_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),

  refresh_infotext = kiln_refresh_infotext,
  heat_interface = heat_interface,
})

minetest.register_node("yatm_foundry:kiln_on", {
  description = "Kiln",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  tiles = {
    "yatm_kiln_top.on.png",
    "yatm_kiln_bottom.on.png",
    "yatm_kiln_side.on.png",
    "yatm_kiln_side.on.png^[transformFX",
    "yatm_kiln_back.on.png",
    "yatm_kiln_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),

  refresh_infotext = kiln_refresh_infotext,
  heat_interface = heat_interface,
})
