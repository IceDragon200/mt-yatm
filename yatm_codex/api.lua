yatm.codex = yatm.codex or {}

yatm.codex.registered_entries = {}
yatm.codex.registered_demos = {}

local function default_demo_check_space(self, pos)
  return true
end

local function default_demo_init(self, pos)
  return nil
end

local function default_demo_build(self, pos, assigns)
end

local function default_demo_configure(self, pos, assigns)
end

local function default_demo_finalize(self, pos, assigns)
end

function yatm.codex.register_entry(name, def)
  assert(def.pages, "expected to have pages")
  yatm.codex.registered_entries[name] = def
end

function yatm.codex.get_entry(name)
  return yatm.codex.registered_entries[name]
end

function yatm.codex.register_demo(name, def)
  def.check_space = def.check_space or default_demo_check_space
  def.init = def.init or default_demo_init
  def.build = def.build or default_demo_build
  def.configure = def.configure or default_demo_configure
  def.finalize = def.finalize or default_demo_finalize

  yatm.codex.registered_demos[name] = def
end

function yatm.codex.get_demo(name)
  return yatm.codex.registered_demos[name]
end

function yatm.codex.fill_cuboid(cuboid, node)
  local positions = {}
  local y2 = (cuboid.y + cuboid.h) - 1
  local z2 = (cuboid.z + cuboid.d) - 1
  local x2 = (cuboid.x + cuboid.w) - 1
  for y = cuboid.y,y2 do
    for z = cuboid.z,z2 do
      for x = cuboid.x,x2 do
        table.insert(positions, vector.new(x, y, z))
      end
    end
  end

  minetest.bulk_set_node(positions, node)
end

local vector2 = yatm_core.vector2

local function place_layer(origin, palette, dim, layer)
  for y = 0,(dim.y - 1) do
    for x = 0,(dim.x - 1) do
      local i = y * dim.x + x
      local cell = layer[i + 1]

      local node = palette[cell]
      if node then
        local pos = vector.add(origin, vector.new(x, 0, y))
        minetest.add_node(pos, node)
      else
        -- skip
      end
    end
  end
end

function yatm.codex.place_node_image(origin, palette, image)
  --
  -- palette contains a map of nodes, where the key is used to identify it in the image
  --
  -- the image is a table of containing the layers that make up the entire thing
  -- it also specifies additional offsets
  --
  -- intentionally using set_npde instead of voxelmanip,
  -- it needs to trigger all the callbacks correctly
  --
  local offset = image.offset or vector.new(0, 0, 0)
  local layers = assert(image.layers, "requires layers")
  local layer_count = #layers

  image.order = image.order or "bottom_up"

  local dim = vector2.new(image.width, image.height)

  -- order affects the layers rendering order
  if image.order == "top_down" then
    -- top down means that the top-most level of the image is the first layer in the list
    for i = 1,layer_count do
      local y = layer_count - i
      place_layer(vector.add(vector.add(origin, offset), vector.new(0, y, 0)), palette, dim, layers[i])
    end
  elseif image.order == "bottom_up" then
    -- bottom up means the bottom-most level of the image ist the first layer in the list
    for i = 1,layer_count do
      place_layer(vector.add(vector.add(origin, offset), vector.new(0, i - 1, 0)), palette, dim, layers[i])
    end
  else
    error("unexpected order " .. image.order)
  end
end
