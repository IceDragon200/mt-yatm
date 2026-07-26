local assertions = assert(foundation.com.assertions)
local table_copy = assert(foundation.com.table_copy)
local Vector2 = assert(foundation.com.Vector2)
local bulk_set_node = assert(tetra.bulk_set_node)
local set_node = assert(tetra.set_node)

--- @namespace yatm.codex
yatm.codex = yatm.codex or {}

--- @const yatm.codex.ERR_OK: String
yatm.codex.ERR_OK = "ERR_OK"
--- @const yatm.codex.ERR_DOMAIN_NOT_FOUND: String
yatm.codex.ERR_DOMAIN_NOT_FOUND = "ERR_DOMAIN_NOT_FOUND"
--- @const yatm.codex.ERR_ENTRY_NOT_FOUND: String
yatm.codex.ERR_ENTRY_NOT_FOUND = "ERR_ENTRY_NOT_FOUND"

--- A table containing some additional header information, if context is set the item_name will
--- be whatever item was pointed at to trigger the codex.
--- `default` can be provided to default to that specific item if the codex is viewed outside of
--- normal operation.
---
--- @type HeadingItem: {
---   context: Boolean,
---   default: String,
--- }

--- A single page in a codex entry.
--- `heading_item` is the name of an item or a table with further details about the items:
---   Example: "yatm_core:wrench"
---   Example.2: { context = true, default = "yatm_foundry:concrete_white" }
---
--- @type CodeEntryPage: {
---   heading_item: String | HeadingItem,
---   heading: String,
---   lines: String[]
--- }

--- A registered CodexEntry
---
--- @type CodexEntry: {
---   pages: CodeEntryPage[],
--- }

--- A domain is a collection of entries for a special grouping.
---
--- @type CodexDomain: {
---
--- }

--- @namespace CodexRegistry
local CodexRegistry = foundation.com.Class:extends("yatm.codex.CodexRegistry")
do
  local ic = CodexRegistry.instance_class

  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)

    --- @const registered_domains: { [name: String]: CodexDomain }
    self.m_registered_domains = {}
  end

  --- @spec #register_domain(name: String, def: Table): void
  function ic:register_domain(name, def)
    assertions.is_string(name, "expected a domain name")
    assertions.is_table(def, "expected a domain definition table")
    if self.m_registered_domains[name] then
      error("domain already exists name=" .. name)
    end
    local domain = table_copy(def)
    domain.entries = {}
    domain.demoes = {} -- deprecated
    self.m_registered_domains[name] = domain
  end

  --- @spec #register_entry(domain_name: String, name: String, def: CodexEntry): void
  function ic:register_entry(domain_name, name, def)
    local domain = self.m_registered_domains[domain_name]
    if domain then
      if domain.entries[name] then
        error("entry already exists name=" .. name .. " in domain=" .. domain_name)
      end
      domain.entries[name] = def
    else
      error("domain not registered name=" .. domain_name)
    end
  end

  --- @spec #get_entry(domain_name: String, name: String): (CodexEntry | nil, error: String)
  function ic:get_entry(domain_name, name)
    local domain = self.m_registered_domains[domain_name]
    if domain then
      local entry = domain.entries[name]
      if entry then
        return entry, yatm.codex.ERR_OK
      end
      return nil, yatm.codex.ERR_ENTRY_NOT_FOUND
    end
    return nil, yatm.codex.ERR_DOMAIN_NOT_FOUND
  end
end

yatm.codex.CodexRegistry = CodexRegistry
--- @const registry: CodexRegistry
yatm.codex.registry = CodexRegistry:new()

--- @deprecated since: "2.0.0"
--- @spec register_entry(name: String, def: CodexEntry): void
function yatm.codex.register_entry(name, def)
  core.log("deprecated", "register_entry/2 is deprecated please use yatm.codex.registry:register_entry/3 instead")
  assertions.is_string(name, "expected entry name to be a string")
  assertions.is_table(def, "expected codex entry to be a table")
  assertions.is_table(def.pages, "expected to have pages")
  assert(#def.pages > 0, "expected at least 1 page")
  return yatm.codex.registry:register_entry("items", name, def)
end

--- @deprecated since: "2.0.0"
--- @spec get_entry(name: String): CodexEntry | nil
function yatm.codex.get_entry(name)
  core.log("deprecated", "yatm.codex.get_entry/1 is deprecated in favour of yatm.codex.regstry:get_entry/2")
  return yatm.codex.registry:get_entry("items", name)
end

--- Deprecated, demoes will be removed in 2.1
--- @const registered_demos: Table
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

--- @deprecated since: "2.0.0"
--- @spec register_demo(name: String, CodexDemo): void
function yatm.codex.register_demo(name, def)
  def.check_space = def.check_space or default_demo_check_space
  def.init = def.init or default_demo_init
  def.build = def.build or default_demo_build
  def.configure = def.configure or default_demo_configure
  def.finalize = def.finalize or default_demo_finalize

  yatm.codex.registered_demos[name] = def
end

--- @deprecated since: "2.0.0"
--- @spec get_demo(name: String): CodexDemo | nil
function yatm.codex.get_demo(name)
  return yatm.codex.registered_demos[name]
end

--- @deprecated since: "2.0.0"
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

  bulk_set_node(positions, node)
end

local function place_layer(origin, palette, dim, layer)
  for y = 0,(dim.y - 1) do
    for x = 0,(dim.x - 1) do
      local i = y * dim.x + x
      local cell = layer[i + 1]

      local node = palette[cell]
      if node then
        local pos = vector.add(origin, vector.new(x, 0, y))
        set_node(pos, node)
      end
    end
  end
end

--- @deprecated since: "2.0.0"
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

  local dim = Vector2.new(image.width, image.height)

  -- order affects the layers rendering order
  if image.order == "top_down" then
    -- top down means that the top-most level of the image is the first layer in the list
    for i = 1,layer_count do
      local y = layer_count - i
      place_layer(
        vector.add(vector.add(origin, offset), vector.new(0, y, 0)), palette, dim, layers[i]
      )
    end
  elseif image.order == "bottom_up" then
    -- bottom up means the bottom-most level of the image ist the first layer in the list
    for i = 1,layer_count do
      place_layer(
        vector.add(vector.add(origin, offset), vector.new(0, i - 1, 0)), palette, dim, layers[i]
      )
    end
  else
    error("unexpected order " .. image.order)
  end
end
