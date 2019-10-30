local cluster_reactor = assert(yatm.cluster.reactor)

local function panel_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_reactor:get_node_infotext(pos)

  meta:set_string("infotext", infotext)
end

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
      structure = 1,
    },

    default_state = "_default",

    states = {
      _default = "yatm_reactors:panel_" .. variant
    }
  }

  yatm_reactors.register_reactor_node(panel_reactor_device.states._default, {
    basename = "yatm_reactors:reactor_panel",

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
    refresh_infotext = panel_refresh_infotext,
  })

  local casing_reactor_device = {
    kind = "casing",

    groups = {
      casing = 1,
      structure = 1,
    },

    default_state = "_default",

    states = {
      _default = "yatm_reactors:casing_" .. variant
    }
  }

  yatm_reactors.register_reactor_node(casing_reactor_device.states._default, {
    basename = "yatm_reactors:reactor_casing",

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

    refresh_infotext = panel_refresh_infotext,
  })
end
