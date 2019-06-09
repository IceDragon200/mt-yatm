local glass_sounds = default.node_sound_glass_defaults()

for variant, variant_texture_name in pairs({
  ["plain"] = "plain",
  ["red_black_stripes"] = "rb.stripes",
  ["white_black_stripes"] = "wb.stripes",
  ["yellow_black_stripes"] = "yb.stripes",
  ["green_black_stripes"] = "gb.stripes",
  ["blue_black_stripes"] = "bb.stripes",
  ["magenta_black_stripes"] = "pb.stripes",
  ["orange_black_stripes"] = "ob.stripes",
}) do
  minetest.register_node("yatm_reactors:glass_" .. variant, {
    description = "Reactor Glass (" .. variant .. ")",
    groups = {cracky = 3, reactor_glass = 1, reactor_structure = 1},
    sounds = glass_sounds,
    tiles = {
      --"yatm_reactor_glass." .. variant_texture_name .. ".png",
      --"yatm_reactor_layers_border." .. variant_texture_name .. ".png",
      --"yatm_reactor_layers_panel.glass.png",
      "yatm_reactor_layers_border-1-1_16." .. variant_texture_name .. ".png",
      "yatm_reactor_layers_panel.glass.png",
    },
    paramtype = "light",
    paramtype2 = "facedir",
    --drawtype = "allfaces",
    drawtype = "glasslike_framed",
    sunlight_propagates = true,
    is_ground_content = false,
  })
end
