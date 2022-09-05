--
-- FluidBarrels as their name states contain fluids.
-- Unlike the brewing barrel used to age booze.
--
local mod = yatm_brewery
local Vector3 = assert(foundation.com.Vector3)
local Directions = assert(foundation.com.Directions)
local Groups = assert(foundation.com.Groups)
local table_merge = assert(foundation.com.table_merge)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local list_concat = assert(foundation.com.list_concat)
local FluidInterface = assert(yatm.fluids.FluidInterface)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidMeta = assert(yatm.fluids.FluidMeta)
local FluidStack = assert(yatm.fluids.FluidStack)
local player_service = assert(nokore.player_service)
local Cuboid = assert(foundation.com.Cuboid)
local ng = assert(Cuboid.new_fast_node_box)

local barrel_nodebox = {
  type = "fixed",
  fixed = {
    ng(1, 1, 1, 14, 14, 14), -- Core
    ng(0, 0, 0, 16, 16, 1),
    ng(0, 0, 15, 16, 16, 1),
    ng(0, 0, 0, 1, 16, 16),
    ng(15, 0, 0, 1, 16, 16),
  }
}

local open_barrel_nodebox = {
  type = "fixed",
  fixed = {
    ng(1, 1, 1, 14, 1, 14), -- Core
    ng(0, 0, 0, 16, 16, 1),
    ng(0, 0, 15, 16, 16, 1),
    ng(0, 0, 0, 1, 16, 16),
    ng(15, 0, 0, 1, 16, 16),
  }
}

local lid_nodebox = {
  type = "fixed",
  fixed = {
    ng(1, 0, 1, 14, 1, 14), -- Lid
  }
}

local BARREL_CAPACITY = 36000 -- 36 buckets
local BARREL_DRAIN_BANDWIDTH = BARREL_CAPACITY

local function on_construct(pos)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

local function on_destruct(pos)
  --
end

--
-- On-place function for lids, will attempt to place the lid on an open barrel
--
local function lid_on_place(item_stack, user, pointed_thing)
  local under_pos = pointed_thing.under
  local under_node = minetest.get_node_or_nil(under_pos)

  if under_node then
    local nodedef = minetest.registered_nodes[under_node.name]

    if nodedef then
      local barrel_def = nodedef.barrel_def
      if barrel_def and barrel_def.state == "opened" then
        -- check if lids match
        if barrel_def.states.lid == item_stack:get_name() then
          local playername = user:get_player_name()

          if minetest.is_protected(under_pos, playername) then
            minetest.log(
              "action",
              playername ..
              " tried to place " ..
              def.name .. " at protected position " ..
              minetest.pos_to_string(under_pos)
            )

            minetest.record_protection_violation(under_pos, playername)
            return item_stack, nil
          end

          local new_node = {
            name = assert(barrel_def.states.closed),
            param1 = under_node.param1,
            param2 = under_node.param2,
          }

          item_stack:take_item()

          minetest.swap_node(under_pos, new_node)

          return item_stack, under_pos
        end
      end
    end
  end

  return minetest.item_place_node(item_stack, user, pointed_thing)
end

-- @spec on_pry(
--   pos: Vector3,
--   node: NodeRef,
--   user: PlayerRef,
--   pointed_thing: PointedThing
-- ): ItemStack[]
local function on_pry(pos, node, user, pointed_thing)
  local drops = {}

  local nodedef = minetest.registered_nodes[node.name]

  if nodedef then
    local barrel_def = nodedef.barrel_def
    if barrel_def then
      local new_node = {
        name = assert(barrel_def.states.opened),
        param1 = node.param1,
        param2 = node.param2,
      }

      minetest.swap_node(pos, new_node)

      if barrel_def.states.lid then
        local lid_stack = ItemStack({ name = barrel_def.states.lid })
        table.insert(drops, lid_stack)
      end
    end
  end

  return drops
end

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)
  local fluid_stack = FluidTanks.get_fluid(pos, Directions.D_NONE)

  local infotext =
    "Barrel\n" ..
    FluidStack.pretty_format(fluid_stack, BARREL_CAPACITY)

  meta:set_string("infotext", infotext)
end

local fluid_interface = FluidInterface.new_simple("tank", BARREL_CAPACITY)

function fluid_interface:on_fluid_changed(pos, dir, _fluid_stack)
  local node = minetest.get_node(pos)
  yatm.queue_refresh_infotext(pos, node)
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  -- local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  local bg = "wood"
  local nodedef = minetest.registered_nodes[state.node.name]

  if Groups.has_group(nodedef, "metal_fluid_barrel") then
    bg = "default"
  end

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = bg }, function (loc, rect)
    if loc == "main_body" then
      local fluid_stack = FluidMeta.get_fluid_stack(meta, "tank")

      return yatm_fspec.render_fluid_stack(
        rect.x,
        rect.y,
        1,
        rect.h,
        fluid_stack,
        BARREL_CAPACITY
      )
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_brewery:fluid_barrel:"..Vector3.to_string(pos)
end

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, user)
  local state = {
    pos = pos,
    node = node,
  }
  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
      timers = {
        -- routinely update the formspec
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
end

for _,row in ipairs(yatm.colors_with_default) do
  local color_basename = row.name
  local color_name = row.description

  --
  -- Wood Barrel
  --
  local closed_name = "yatm_brewery:fluid_barrel_wood_" .. color_basename
  local opened_name = "yatm_brewery:fluid_barrel_wood_" .. color_basename .. "_open"
  local lid_name = "yatm_brewery:fluid_barrel_wood_" .. color_basename .. "_lid"

  local barrel_def = {
    states = {
      opened = opened_name,
      closed = closed_name,
      lid = lid_name,
    }
  }

  minetest.register_node(closed_name, {
    codex_entry_id = "yatm_brewery:fluid_barrel_wood",

    basename = "yatm_brewery:fluid_barrel_wood",
    base_description = mod.S("Fluid Barrel (Wood)"),

    description = mod.S("Fluid Barrel (Wood / " .. color_name .. ")"),

    groups = {
      choppy = nokore.dig_class("wme"),
      --
      fluid_barrel = 1,
      wood_fluid_barrel = 1,
      fluid_interface_in = 1,
      fluid_interface_out = 1,
    },
    sounds = yatm.node_sounds:build("wood"),
    tiles = {
      "yatm_barrel_wood_fluid_" .. color_basename .. "_top.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
    },
    use_texture_alpha = "opaque",

    paramtype = "none",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = barrel_nodebox,

    dye_color = color_basename,

    stack_max = 1,

    on_rightclick = on_rightclick,

    on_construct = on_construct,
    on_destruct = on_destruct,

    on_pry = on_pry,

    fluid_interface = fluid_interface,

    refresh_infotext = refresh_infotext,

    barrel_def = table_merge(barrel_def, {
      state = "closed",
    }),
  })

  minetest.register_node(opened_name, {
    codex_entry_id = "yatm_brewery:fluid_barrel_wood",

    basename = "yatm_brewery:fluid_barrel_wood",
    base_description = mod.S("Fluid Barrel (Wood)"),

    description = mod.S("Fluid Barrel (Wood / " .. color_name .. ") [Open]"),

    groups = {
      choppy = nokore.dig_class("wme"),
      --
      open_barrel = 1,
      fluid_barrel = 1,
      wood_fluid_barrel = 1,
      fluid_interface_in = 1,
      fluid_interface_out = 1,
    },
    sounds = yatm.node_sounds:build("wood"),
    tiles = {
      "yatm_barrel_wood_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
    },
    use_texture_alpha = "opaque",

    paramtype = "none",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = open_barrel_nodebox,

    dye_color = color_basename,

    stack_max = 1,

    on_rightclick = on_rightclick,

    on_construct = on_construct,
    on_destruct = on_destruct,

    fluid_interface = fluid_interface,

    refresh_infotext = refresh_infotext,

    barrel_def = table_merge(barrel_def, {
      state = "opened",
    }),
  })

  minetest.register_node(lid_name, {
    codex_entry_id = "yatm_brewery:fluid_barrel_wood_lid",

    basename = "yatm_brewery:fluid_barrel_wood_lid",
    base_description = mod.S("Fluid Barrel Lid (Wood)"),

    description = mod.S("Fluid Barrel Lid (Wood / " .. color_name .. ")"),

    groups = {
      choppy = nokore.dig_class("wme"),
      oddly_breakable_by_hand = nokore.dig_class("hand"),
      --
      barrel_lid = 1,
    },
    sounds = yatm.node_sounds:build("wood"),
    tiles = {
      "yatm_barrel_wood_fluid_" .. color_basename .. "_top.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_wood_fluid_" .. color_basename .. "_side.png",
    },
    use_texture_alpha = "opaque",

    paramtype = "none",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = lid_nodebox,

    dye_color = color_basename,

    stack_max = 1,

    barrel_def = table_merge(barrel_def, {
      state = "lid",
    }),

    on_place = lid_on_place,
  })

  --
  -- Metal Barrel
  --
  closed_name = "yatm_brewery:fluid_barrel_metal_" .. color_basename
  opened_name = "yatm_brewery:fluid_barrel_metal_" .. color_basename .. "_open"
  lid_name = "yatm_brewery:fluid_barrel_metal_" .. color_basename .. "_lid"

  barrel_def = {
    states = {
      opened = opened_name,
      closed = closed_name,
      lid = lid_name,
    }
  }

  minetest.register_node(closed_name, {
    codex_entry_id = "yatm_brewery:fluid_barrel_metal",

    basename = "yatm_brewery:fluid_barrel_metal",
    base_description = mod.S("Fluid Barrel (Metal)"),

    description = mod.S("Fluid Barrel (Metal / " .. color_name .. ")"),

    groups = {
      cracky = nokore.dig_class("copper"),
      --
      fluid_barrel = 1,
      metal_fluid_barrel = 1,
      fluid_interface_in = 1,
      fluid_interface_out = 1,
    },
    sounds = yatm.node_sounds:build("metal"),
    tiles = {
      "yatm_barrel_metal_fluid_" .. color_basename .. "_top.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
    },
    use_texture_alpha = "opaque",

    paramtype = "none",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = barrel_nodebox,

    dye_color = color_basename,

    stack_max = 1,

    on_rightclick = on_rightclick,

    on_construct = on_construct,
    on_destruct = on_destruct,

    on_pry = on_pry,

    fluid_interface = fluid_interface,

    refresh_infotext = refresh_infotext,

    barrel_def = table_merge(barrel_def, {
      state = "closed",
    }),
  })

  minetest.register_node(opened_name, {
    codex_entry_id = "yatm_brewery:fluid_barrel_metal",

    basename = "yatm_brewery:fluid_barrel_metal",
    base_description = mod.S("Fluid Barrel (Metal)"),

    description = mod.S("Fluid Barrel (Metal / " .. color_name .. ") [Open]"),

    groups = {
      cracky = nokore.dig_class("copper"),
      --
      open_barrel = 1,
      fluid_barrel = 1,
      metal_fluid_barrel = 1,
      fluid_interface_in = 1,
      fluid_interface_out = 1,
    },
    sounds = yatm.node_sounds:build("metal"),
    tiles = {
      "yatm_barrel_metal_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
    },
    use_texture_alpha = "opaque",

    paramtype = "none",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = open_barrel_nodebox,

    dye_color = color_basename,

    stack_max = 1,

    on_rightclick = on_rightclick,

    on_construct = on_construct,
    on_destruct = on_destruct,

    fluid_interface = fluid_interface,

    refresh_infotext = refresh_infotext,

    barrel_def = table_merge(barrel_def, {
      state = "opened",
    }),
  })

  minetest.register_node(lid_name, {
    codex_entry_id = "yatm_brewery:fluid_barrel_metal_lid",

    basename = "yatm_brewery:fluid_barrel_metal_lid",
    base_description = mod.S("Fluid Barrel Lid (Metal)"),

    description = mod.S("Fluid Barrel Lid (Metal / " .. color_name .. ")"),

    groups = {
      choppy = nokore.dig_class("wme"),
      oddly_breakable_by_hand = nokore.dig_class("hand"),
      --
      barrel_lid = 1,
    },
    sounds = yatm.node_sounds:build("metal"),
    tiles = {
      "yatm_barrel_metal_fluid_" .. color_basename .. "_top.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_bottom.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
      "yatm_barrel_metal_fluid_" .. color_basename .. "_side.png",
    },
    use_texture_alpha = "opaque",

    paramtype = "none",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = lid_nodebox,

    dye_color = color_basename,

    stack_max = 1,

    barrel_def = table_merge(barrel_def, {
      state = "lid",
    }),

    on_place = lid_on_place,
  })
end
