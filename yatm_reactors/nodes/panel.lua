for variant, variant_texture_name in pairs({
  ["plain"] = "plain",
  ["red_black_stripes"] = "rb.stripes",
  ["white_black_stripes"] = "wb.stripes",
  ["yellow_black_stripes"] = "yb.stripes",
}) do
  local panel_yatm_network = {
    kind = "machine",
    groups = {
      reactor = 1,
      reactor_panel = 1,
    },
    states = {
      _default = "yatm_reactors:panel_" .. variant
    }
  }

  yatm_machines.register_network_device(panel_yatm_network.states._default, {
    description = "Reactor Panel (" .. variant .. ")",
    groups = {cracky = 1, reactor_panel = 1, reactor_structure = 1},
    drop = panel_yatm_network.states._default,
    tiles = {
      "yatm_reactor_panel." .. variant_texture_name .. ".png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = panel_yatm_network,
  })
end
