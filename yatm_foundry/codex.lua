local Cuboid = assert(foundation.com.Cuboid)

yatm.codex.register_demo("yatm_foundry:concrete_showcase", {
  check_space = function (self, pos)
    return true
  end,

  init = function (self, pos)
    return {}
  end,

  build = function (self, pos, assigns)
    local colors = yatm.colors
    local variants = {
      "bare",
      "dotted",
      "circles",
      "striped",
      "ornated",
      "tiled",
      "meshed",
      "rosy",
    }

    local cuboid = Cuboid:new(-math.floor(#colors / 2), 0, -math.floor(#variants / 2), #colors, 1, #variants)
    cuboid = Cuboid.translate(cuboid, pos)
    yatm.codex.fill_cuboid(cuboid, { name = "air" })

    local palette = {
      [" "] = { name = "air" },
    }

    local layer = {}

    local y = 0
    local h = #variants
    local x = 0
    local w = #colors

    for _, variant in ipairs(variants) do
      x = 0
      for _, row in ipairs(colors) do
        local palette_key = variant .. "_" .. row.name
        palette[palette_key] = { name = "yatm_foundry:concrete_" .. palette_key }
        layer[1 + x + y * w] = palette_key
        x = x + 1
      end
      y = y + 1
    end

    -- this places a layer of concrete or whatever base material we have
    -- Then alternates some magenta and blue cables
    local image = {
      width = cuboid.w,
      height = cuboid.d,
      order = "bottom_up",
      layers = {
        layer
      },
    }

    yatm.codex.place_node_image(cuboid:position(), palette, image)
  end,

  configure = function (self, pos, assigns)
    --
  end,

  finalize = function (self, pos, assigns)
    --
  end,
})

yatm.codex.register_entry("yatm_foundry:concrete", {
  pages = {
    {
      heading_item = {
        context = true,
        default = "yatm_foundry:concrete_bare_white",
      },
      heading = "Concrete",
      lines = {
        "A concrete block, decorative at best.",
      },
    },
    {
      heading_item = {
        context = true,
        default = "yatm_foundry:concrete_bare_white",
      },
      heading = "Demos",
      demos = {
        "yatm_foundry:concrete_showcase",
      },
      lines = {},
    },
  },
})
