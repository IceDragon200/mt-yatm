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
      "yatm_reactor_glass." .. variant_texture_name .. ".png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "allfaces",
    sunlight_propagates = true,
    is_ground_content = false,
  })
end
