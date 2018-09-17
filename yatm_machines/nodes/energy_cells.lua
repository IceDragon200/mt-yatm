local cell_types = {"basic", "normal", "dense"}

for _, cell_type in ipairs(cell_types) do
  minetest.register_node("yatm_machines:energy_cell_"..cell_type, {
    description = "Energy Cell ("..cell_type..")",
    groups = {cracky = 1},
    tiles = {
      {
        name = "yatm_energy_cell_"..cell_type.."_stage0.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
    },
    paramtype = "light",
    paramtype2 = "facedir",
    legacy_facedir_simple = true,
  })

  minetest.register_node("yatm_machines:energy_cell_"..cell_type.."_creative", {
    description = "Energy Cell ("..cell_type..") [Creative]",
    groups = {cracky = 1},
    tiles = {
      {
        name = "yatm_energy_cell_"..cell_type.."_creative.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
    },
    paramtype = "light",
    paramtype2 = "facedir",
    legacy_facedir_simple = true,
  })
end
