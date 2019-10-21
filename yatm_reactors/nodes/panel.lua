for variant, variant_texture_name in pairs({
  ["plain"] = "plain",
  ["red_black_stripes"] = "rb.stripes",
  ["white_black_stripes"] = "wb.stripes",
  ["yellow_black_stripes"] = "yb.stripes",
  ["orange_black_stripes"] = "ob.stripes",
  ["blue_black_stripes"] = "bb.stripes",
  ["green_black_stripes"] = "gb.stripes",
  ["purple_black_stripes"] = "pb.stripes",
}) do
  local panel_reactor_device = {
    kind = "panel",

    groups = {
      panel = 1,
    },

    default_state = "_default",

    states = {
      _default = "yatm_reactors:panel_" .. variant
    }
  }

  yatm_reactors.register_reactor_node(panel_reactor_device.states._default, {
    description = "Reactor Panel (" .. variant .. ")",
    groups = {cracky = 1, reactor_panel = 1, reactor_structure = 1},
    drop = panel_reactor_device.states._default,
    tiles = {
      "yatm_reactor_panel." .. variant_texture_name .. ".png",
      --"yatm_reactor_layers_border-1-1_16." .. variant_texture_name .. ".png",
      --"yatm_reactor_layers_panel.plain.png",
    },
    --drawtype = "glasslike_framed",
    paramtype = "light",
    paramtype2 = "facedir",
    reactor_device = panel_reactor_device,
  })

  local casing_reactor_device = {
    kind = "machine",
    groups = {
      reactor = 1,
      reactor_panel = 1,
    },
    states = {
      _default = "yatm_reactors:casing_" .. variant
    }
  }

  yatm_reactors.register_reactor_node(casing_reactor_device.states._default, {
    description = "Reactor Casing (" .. variant .. ")",
    groups = {cracky = 1, reactor_panel = 1, reactor_structure = 1},
    drop = casing_reactor_device.states._default,
    tiles = {
      --"yatm_reactor_layers_border-1-1_16." .. variant_texture_name .. ".png",
      --"yatm_reactor_layers_panel.casing.png",
      "yatm_reactor_casing." .. variant_texture_name .. ".png",
    },
    --drawtype = "glasslike_framed",
    paramtype = "light",
    paramtype2 = "facedir",
    reactor_device = casing_reactor_device,
  })
end
