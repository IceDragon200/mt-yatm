yatm.codex.register_demo("yatm_data_noteblock:data_noteblock_demo_1", {
  check_space = function (self, pos)
    return true
  end,

  init = function (self, pos)
    return {}
  end,

  build = function (self, pos, assigns)
    local cuboid = yatm.Cuboid:new(-2, -1, -2, 5, 3, 5):translate(pos)
    yatm.codex.fill_cuboid(cuboid, { name = "air" })

    local base_name
    if yatm_foundry then
      base_name = "yatm_foundry:concrete_bare_white"
    elseif default then
      base_name = "default:stone"
    else
      base_name = "air"
    end

    local palette = {
      ["N"] = { name = "yatm_data_noteblock:data_noteblock" },
      ["M"] = { name = "yatm_data_network:data_cable_bus_magenta" },
      ["m"] = { name = "yatm_data_network:data_cable_magenta" },
      ["B"] = { name = "yatm_data_network:data_cable_bus_blue" },
      ["b"] = { name = "yatm_data_network:data_cable_blue" },
      ["@"] = { name = "yatm_data_logic:data_momentary_button_off" },
      ["_"] = { name = base_name },
      [" "] = { name = "air" },
    }

    -- this places a layer of concrete or whatever base material we have
    -- Then alternates some magenta and blue cables
    local image = {
      width = 5,
      height = 5,
      order = "bottom_up",
      layers = {
        {
          "_", "_", "_", "_", "_",
          "_", "_", "_", "_", "_",
          "_", "_", "_", "_", "_",
          "_", "_", "_", "_", "_",
          "_", "_", "_", "_", "_",
        },
        {
          "N", "N", "N", "N", "N",
          "M", "B", "M", "B", "M",
          "m", "b", "m", "b", "m",
          "M", "B", "M", "B", "M",
          "@", "@", "@", "@", "@",
        }
      },
    }

    yatm.codex.place_node_image(cuboid:position(), palette, image)
  end,

  configure = function (self, pos, assigns)
    -- the schema is a 5x2x5 (but really only 2 layers are used so it's really 5x2x5)
  end,

  finalize = function (self, pos, assigns)
    --
  end,
})

yatm.codex.register_entry("yatm_data_noteblock:data_noteblock", {
  pages = {
    {
      heading_item = "yatm_data_network:data_noteblock",
      heading = "DATA Noteblock",
      lines = {
        "Noteblocks emit a sound when triggered.",
        "The tone can be changed by placing different nodes below it.",
        "The noteblock can only be triggered by a data event.",
      }
    },
  }
})
