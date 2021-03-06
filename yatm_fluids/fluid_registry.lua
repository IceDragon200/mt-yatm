--
-- The fluid registry
--
local Measurable = assert(yatm.Measurable)
local Groups = assert(foundation.com.Groups)
local table_merge = assert(foundation.com.table_merge)
local Directions = assert(foundation.com.Directions)

local FluidRegistry = {
  m_item_name_to_fluid_name = {},
  m_fluid_name_to_tank_name = {},
  m_tank_name_to_fluid_name = {},
}

function FluidRegistry.register_fluid(fluid_name, def)
  assert(fluid_name, "requires a name")
  assert(def, "requires a definition")
  if def.nodes and def.nodes.source then
    FluidRegistry.m_item_name_to_fluid_name[def.nodes.source] = fluid_name
  end
  def.name = fluid_name
  -- force the definition into the fluid group
  Groups.put_item(def, "fluid", 1)
  Measurable.register(FluidRegistry, fluid_name, def)
end

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

local function get_fluid_tile(fluid)
  if fluid.tiles then
    return assert(fluid.tiles.source)
  elseif fluid.nodes then
    local name = assert(fluid.nodes.source, "expected a source " .. fluid.name)
    local node = assert(minetest.registered_nodes[name], "expected node to exist " .. name)
    return node.tiles[1]
  else
    error("fluid .. " .. dump(fluid.name) .. " does not have tiles or nodes, cannot obtain texture information")
  end
end

function FluidRegistry.register_fluid_tank(modname, fluid_name, nodedef)
  local fluid_tank_tiles = {
    "yatm_fluid_tank_edge.png",
    "yatm_fluid_tank_detail.png",
  }

  nodedef = nodedef or {}
  local fluiddef = assert(FluidRegistry.get_fluid(fluid_name), "expected fluid " .. fluid_name .. "to exist")

  local groups = table_merge({
    cracky = 1,
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
      yatm.fluids.FluidTanks.replace_fluid(pos, Directions.D_NONE,
        yatm.fluids.FluidStack.new(fluiddef.name, tank_fluid_interface.capacity), true)
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
    alpha = def.alpha or 255,
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
    alpha = def.alpha or 255,
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

function FluidRegistry.register(modname, fluid_basename, definition)
  local fluid_name = modname .. ":" .. fluid_basename
  local node_basename = fluid_name
  local bucket_name = modname .. ":bucket_" .. fluid_basename
  local nodes = {}
  local description = definition.description or fluid_name

  local fluid_node_def = nil
  if definition.nodes then
    fluid_node_def = {
      description_base = description,
      texture_basename = definition.nodes.texture_basename,
      groups = definition.nodes.groups or {},
      alpha = definition.nodes.alpha or 255,
      post_effect_color = definition.nodes.post_effect_color,
    }
  end

  local fluid_def = {
    aliases = definition.aliases,
    description = description,
    groups = definition.groups or {},
    tiles = definition.tiles,
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

    assert(type(bucket_def.groups) == "table", "groups are expected to be tables (" .. bucket_name .. ")")

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
    print("FluidRegistry", "register", "registering fluid bucket", fluid_name, bucket_name)
    FluidRegistry.register_fluid_bucket(bucket_name, bucket_def)
  end

  if fluid_tank_def then
    local tank_modname = definition.fluid_tank.modname or modname
    --print("FluidRegistry", "register", "registering fluid tank", fluid_name, modname)
    FluidRegistry.register_fluid_tank(tank_modname, fluid_name, fluid_tank_def)
  end
end

function FluidRegistry.get_fluid(fluid_name)
  return FluidRegistry.members[fluid_name]
end

function FluidRegistry.normalize_fluid_name(fluid_name)
  return FluidRegistry.aliases[fluid_name] or fluid_name
end

--
-- @spec FluidRegistry.item_name_to_fluid_name(String.t) :: String.t | nil
--
function FluidRegistry.item_name_to_fluid_name(item_name)
  return FluidRegistry.m_item_name_to_fluid_name[item_name]
end

function FluidRegistry.fluid_name_to_tank_name(fluid_name)
  fluid_name = FluidRegistry.normalize_fluid_name(fluid_name)
  return FluidRegistry.m_fluid_name_to_tank_name[fluid_name]
end

yatm_fluids.FluidRegistry = FluidRegistry
