--
-- The fluid registry
--
local Measurable = assert(yatm.Measurable)
local Groups = assert(foundation.com.Groups)
local table_merge = assert(foundation.com.table_merge)
local Directions = assert(foundation.com.Directions)
local Color = assert(foundation.com.Color)

-- @namespace yatm_fluids.fluid_registry
local FluidRegistry = {
  m_item_name_to_fluid_name = {},
  m_fluid_name_to_tank_name = {},
  m_tank_name_to_fluid_name = {},
}

-- @type FluidDef: {
--   nodes: {
--     source: String,
--     flowing: String,
--   },
--   groups: { [group: String]: Integer },
--   description: String,
--   aliases: Any,
--   tiles: Any,
--   color: ColorString,
-- }

-- @spec register_fluid(fluid_name: String, def: FluidDef): void
function FluidRegistry.register_fluid(fluid_name, def)
  assert(type(fluid_name) == "string", "requires a name")
  assert(type(def) == "table", "requires a definition table")

  if def.nodes and def.nodes.source then
    FluidRegistry.m_item_name_to_fluid_name[def.nodes.source] = fluid_name
  end
  def.name = fluid_name
  if def.color then
    local color = Color.from_colorstring(def.color)
    if not color then
      error("invalid colorstring=" .. def.color)
    end
  else
    local msg = "suggestion: add a color to registered fluid name=" .. fluid_name
    minetest.log("warning", msg)
    --error(msg)
  end

  -- force the definition into the fluid group
  Groups.put_item(def, "fluid", 1)

  Measurable.register(FluidRegistry, fluid_name, def)
end

-- @spec register_fluid_bucket(bucket_name: String, bucket_def: Table): void
function FluidRegistry.register_fluid_bucket(bucket_name, bucket_def)
  assert(bucket_def.nodes)
  if bucket then
    bucket.register_liquid(
      assert(bucket_def.nodes.source),
      assert(bucket_def.nodes.flowing),
      bucket_name,
      assert(bucket_def.texture),
      (bucket_def.description or bucket_name),
      (bucket_def.groups or {}),
      (bucket_def.force_renew or false)
    )
  end
end

-- @private.spec get_fluid_tile(fluid: Fluid): String
local function get_fluid_tile(fluid)
  if fluid.tiles then
    return assert(fluid.tiles.source)
  elseif fluid.nodes then
    local name = assert(fluid.nodes.source, "expected a source " .. fluid.name)
    local node = assert(minetest.registered_nodes[name], "expected node to exist " .. name)
    return node.tiles[1]
  else
    error("fluid .. " .. dump(fluid.name) ..
      " does not have tiles or nodes, cannot obtain texture information")
  end
end

function FluidRegistry.register_fluid_tank(modname, fluid_name, nodedef)
  local fluid_tank_tiles = {
    "yatm_fluid_tank_edge.png",
    "yatm_fluid_tank_detail.png",
  }

  nodedef = nodedef or {}
  local fluiddef = assert(
    FluidRegistry.get_fluid(fluid_name),
    "expected fluid " .. fluid_name .. "to exist"
  )

  local groups = table_merge({
    cracky = nokore.dig_class("wood"),
    --
    fluid_tank = 1,
    filled_fluid_tank = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
    not_in_creative_inventory = 1,
  }, nodedef.groups or {})

  local tank_fluid_interface = assert(yatm_fluids.fluid_tank_fluid_interface)

  local fluid_tank_def = {
    description = "Fluid Tank (" .. (fluiddef.description or fluid_name) .. ")",

    groups = groups,

    drop = "yatm_fluids:fluid_tank",

    tiles = fluid_tank_tiles,
    special_tiles = {
      get_fluid_tile(fluiddef),
    },
    --use_texture_alpha = "blend",

    drawtype = "glasslike_framed",

    paramtype = "light",
    paramtype2 = "glasslikeliquidlevel",

    is_ground_content = false,
    sunlight_propagates = true,

    light_source = nodedef.light_source,

    sounds = yatm.node_sounds:build("glass"),

    refresh_infotext = yatm_fluids.fluid_tank_refresh_infotext,

    on_construct = yatm_fluids.fluid_tank_on_construct,
    after_destruct = yatm_fluids.fluid_tank_after_destruct,

    after_place_node = function (pos, _placer, _itemstack, _pointed_thing)
      local capacity = fluid_interface:get_capacity(pos, 0)
      yatm.fluids.FluidTanks.replace_fluid(
        pos,
        Directions.D_NONE,
        yatm.fluids.FluidStack.new(fluiddef.name, capacity), true
      )
    end,

    fluid_interface = tank_fluid_interface,
    connects_to = {"group:fluid_tank"},
  }

  local fluid_tank_name = modname .. ":fluid_tank_" .. assert(fluiddef.safe_name)
  print("FluidRegistry", "register_fluid_tank", fluid_tank_name)
  minetest.register_node(fluid_tank_name, fluid_tank_def)
  FluidRegistry.m_fluid_name_to_tank_name[fluid_name] = fluid_tank_name
  FluidRegistry.m_tank_name_to_fluid_name[fluid_tank_name] = fluid_name
end

function FluidRegistry.register_fluid_nodes(basename, def)
  minetest.register_node(basename .. "_source", {
    description = def.description_base .. " Source",
    groups = def.groups or {},
    drawtype = "liquid",
    tiles = {
      {
        name = def.texture_basename .. "_source_animated.png",
        backface_culling = false,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0,
        },
      },
      {
        name = def.texture_basename .. "_source_animated.png",
        backface_culling = true,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0,
        },
      },
    },
    paramtype = "light",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    is_ground_content = false,
    drop = "",
    drowning = 1,
    liquidtype = "source",
    liquid_alternative_flowing = basename .. "_flowing",
    liquid_alternative_source = basename .. "_source",
    liquid_viscosity = 1,
    post_effect_color = def.post_effect_color,
    sounds = yatm.node_sounds:build("water"),
  })

  minetest.register_node(basename .. "_flowing", {
    description = "Flowing " .. def.description_base,
    groups = table_merge(def.groups or {}, {not_in_creative_inventory = 1}),
    drawtype = "flowingliquid",
    tiles = {def.texture_basename .. "_source.png"},
    special_tiles = {
      {
        name = def.texture_basename .. "_flowing_animated.png",
        backface_culling = false,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.8,
        },
      },
      {
        name = def.texture_basename .. "_flowing_animated.png",
        backface_culling = true,
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.8,
        },
      },
    },
    paramtype = "light",
    paramtype2 = "flowingliquid",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    is_ground_content = false,
    drop = "",
    drowning = 1,
    liquidtype = "flowing",
    liquid_alternative_flowing = basename .. "_flowing",
    liquid_alternative_source = basename .. "_source",
    liquid_viscosity = 1,
    post_effect_color = def.post_effect_color,
    sounds = yatm.node_sounds:build("water"),
  })
end

local FLUID_DEFINITION = foundation.com.table_freeze({
  -- description: String
  description = {},
  -- bucket: Table
  bucket = {},
  -- groups: Table
  groups = {},
  -- color: String
  color = {},
  -- attributes: Table
  attributes = {},
  -- fluid_tank: Table
  fluid_tank = {},
  -- nodes: Table
  nodes = {},
  -- aliases: Table
  aliases = {},
  -- tiles: Table
  tiles = {},
})

local function check_register_definition(definition)
  for key, _value in pairs(definition) do
    local def = FLUID_DEFINITION[key]
    if not def then
      error("unexpected field=" .. key .. " (for FluidRegistry.register/3)")
    end
  end
end

-- @spec register(modname: String, fluid_basename: String, definition: Table): void
function FluidRegistry.register(modname, fluid_basename, definition)
  local fluid_name = modname .. ":" .. fluid_basename
  local node_basename = fluid_name
  local bucket_name = modname .. ":bucket_" .. fluid_basename
  local nodes = {}
  check_register_definition(definition)
  local description = definition.description or fluid_name

  local fluid_node_def = nil
  if definition.nodes then
    fluid_node_def = {
      description_base = description,
      texture_basename = definition.nodes.texture_basename,
      groups = definition.nodes.groups or {},
      post_effect_color = definition.nodes.post_effect_color,
    }
  end

  local fluid_def = {
    aliases = definition.aliases,
    description = description,
    groups = definition.groups or {},
    tiles = definition.tiles,
    color = definition.color,
    attributes = definition.attributes or {},
  }

  if fluid_node_def then
    local names = definition.nodes.names or {}
    fluid_def.nodes = {
      source = names.source or (node_basename .. "_source"),
      flowing = names.flowing or (node_basename .. "_flowing"),
    }
  end

  local bucket_def = nil
  if definition.bucket then
    bucket_def = {
      texture = definition.bucket.texture or (modname .. "_bucket_" .. fluid_basename .. ".png"),
      description = definition.bucket.description or (description .. " Bucket"),
      groups = (definition.bucket.groups or {}),
      force_renew = definition.bucket.force_renew or false,
    }
    if fluid_def.nodes then
      bucket_def.nodes = {
        source = fluid_def.nodes.source,
        flowing = fluid_def.nodes.flowing,
      }
    end

    assert(
      type(bucket_def.groups) == "table",
      "groups are expected to be tables (" .. bucket_name .. ")"
    )

    bucket_def.groups.fluid_bucket = 1
  end

  local fluid_tank_def = nil
  if definition.fluid_tank then
    fluid_tank_def = {
      light_source = definition.fluid_tank.light_source,
      groups = definition.fluid_tank.groups or {},
    }
  end

  --print("FluidRegistry", "register", "registering fluid", fluid_name)
  FluidRegistry.register_fluid(fluid_name, fluid_def)
  if fluid_node_def then
    if not definition.nodes.dont_register then
      --print("FluidRegistry", "register", "registering fluid nodes", fluid_name, node_basename)
      FluidRegistry.register_fluid_nodes(node_basename, fluid_node_def)
    end
  end

  if bucket_def then
    -- print("FluidRegistry", "register", "registering fluid bucket", fluid_name, bucket_name)
    FluidRegistry.register_fluid_bucket(bucket_name, bucket_def)
  end

  if fluid_tank_def then
    local tank_modname = definition.fluid_tank.modname or modname
    --print("FluidRegistry", "register", "registering fluid tank", fluid_name, modname)
    FluidRegistry.register_fluid_tank(tank_modname, fluid_name, fluid_tank_def)
  end
end

-- @spec get_fluid(fluid_name: String): Fluid
function FluidRegistry.get_fluid(fluid_name)
  return FluidRegistry.members[fluid_name]
end

-- @spec normalize_fluid_name(fluid_name: String): String
function FluidRegistry.normalize_fluid_name(fluid_name)
  return FluidRegistry.aliases[fluid_name] or fluid_name
end

--
-- @spec item_name_to_fluid_name(item_name: String): String
function FluidRegistry.item_name_to_fluid_name(item_name)
  return FluidRegistry.m_item_name_to_fluid_name[item_name]
end

-- @spec fluid_name_to_tank_name(fluid_name: String): String
function FluidRegistry.fluid_name_to_tank_name(fluid_name)
  fluid_name = FluidRegistry.normalize_fluid_name(fluid_name)
  return FluidRegistry.m_fluid_name_to_tank_name[fluid_name]
end

yatm_fluids.fluid_registry = FluidRegistry
