yatm.blasting = {
  BlastingRegistry = assert(yatm_foundry.BlastingRegistry),
}
yatm.smelting = {
  SmeltingRegistry = assert(yatm_foundry.SmeltingRegistry),
}
yatm.kiln = {
  KilnRegistry = assert(yatm_foundry.KilnRegistry),
}
yatm.molding = {
  MoldingRegistry = assert(yatm_foundry.MoldingRegistry),
}
yatm.heating = {
  HeatInterface = assert(yatm_foundry.HeatInterface),
  HeatableDevice = assert(yatm_foundry.HeatableDevice),
}

function yatm.heating.default_transfer_heat(pos, node)
  local meta = minetest.get_meta(pos)
  local available_heat = meta:get_float("heat")
  if available_heat > 0 then
    local heat_per_dir = available_heat / 6.0

    for d6_code, d6_vec3 in pairs(yatm_core.DIR6_TO_VEC3) do
      if available_heat <= 0 then
        break
      end
      local neighbour_pos = vector.add(pos, d6_vec3)
      local used_heat, err = yatm.heating.HeatableDevice.transfer_heat(
        neighbour_pos, yatm_core.invert_dir(d6_code),
        heat_per_dir,
        true
      )

      available_heat = available_heat - math.min(math.max(used_heat, 0), available_heat)

      if used_heat > heat_per_dir then
        local node = minetest.get_node(neighbour_pos)
        print("ERROR", minetest.pos_to_string(pos), node.name, "node at position has violated expected behaviour and used more heat than provided!")
      end
    end

    meta:set_float("heat", available_heat)
  end
end
