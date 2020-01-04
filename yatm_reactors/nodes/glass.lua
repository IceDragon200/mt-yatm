local cluster_reactor = assert(yatm.cluster.reactor)

local glass_sounds = default.node_sound_glass_defaults()

local function glass_refresh_infotext(pos, node)
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
  ["green_black_stripes"] = "gb.stripes",
  ["blue_black_stripes"] = "bb.stripes",
  ["magenta_black_stripes"] = "pb.stripes",
  ["orange_black_stripes"] = "ob.stripes",
}) do
  minetest.register_node("yatm_reactors:glass_" .. variant, {
    basename = "yatm_reactors:glass",
    base_description = "Decorative Reactor Glass",

    description = "Decorative Reactor Glass (" .. variant .. ")",
    note = "Safe to use for decor",
    groups = {
      cracky = 3,
    },
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

  local glass_reactor_device = {
    kind = "glass",

    groups = {
      glass = 1,
      structure = 1,
    },

    default_state = "_default",

    states = {
      _default = "yatm_reactors:reactor_glass_" .. variant
    }
  }

  yatm_reactors.register_reactor_node(glass_reactor_device.states._default, {
    basename = "yatm_reactors:reactor_glass",
    base_description = "Reactor Glass",

    description = "Reactor Glass (" .. variant .. ")",
    groups = {
      cracky = 3,
      reactor_glass = 1,
      reactor_structure = 1
    },
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

    reactor_device = glass_reactor_device,

    refresh_infotext = glass_refresh_infotext,
  })
end
