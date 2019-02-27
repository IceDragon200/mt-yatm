local glass_sounds = default.node_sound_glass_defaults()

for variant, variant_texture_name in pairs({
  ["plain"] = "plain",
  ["red_black_stripes"] = "rb.stripes",
  ["white_black_stripes"] = "wb.stripes",
  ["yellow_black_stripes"] = "yb.stripes",
}) do
  local glass_yatm_network = {
    kind = "machine",
    groups = {
      reactor = 1,
      reactor_glass = 1,
    },
    states = {
      _default = "yatm_reactors:glass_" .. variant
    }
  }

  yatm_machines.register_network_device(glass_yatm_network.states._default, {
    description = "Reactor Glass (" .. variant .. ")",
    groups = {cracky = 3},
    sounds = glass_sounds,
    drop = glass_yatm_network.states._default,
    tiles = {
      "yatm_reactor_glass." .. variant_texture_name .. ".png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = glass_yatm_network,
    drawtype = "allfaces",
  })
end
