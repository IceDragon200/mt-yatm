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

minetest.register_node("yatm_foundry:furnace_off", {
  description = "Furnace",
  groups = groups,
  tiles = {
    "yatm_furnace_top.off.png",
    "yatm_furnace_bottom.off.png",
    "yatm_furnace_side.off.png",
    "yatm_furnace_side.off.png^[transformFX",
    "yatm_furnace_back.off.png",
    "yatm_furnace_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),

  refresh_infotext = furnace_refresh_infotext,
  heat_interface = heat_interface,
})

minetest.register_node("yatm_foundry:furnace_on", {
  description = "Furnace",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  tiles = {
    "yatm_furnace_top.on.png",
    "yatm_furnace_bottom.on.png",
    "yatm_furnace_side.on.png",
    "yatm_furnace_side.on.png^[transformFX",
    "yatm_furnace_back.on.png",
    "yatm_furnace_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),

  refresh_infotext = furnace_refresh_infotext,
  heat_interface = heat_interface,
})
