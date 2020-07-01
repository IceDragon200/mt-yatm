--
-- The node sounds registry allows registering, well node sounds,
-- these sounds are a table that can extend another node sound set.
--
local NodeSoundsRegistry = yatm_core.Class:extends("NodeSoundsRegistry")
local ic = NodeSoundsRegistry.instance_class

function ic:initialize()
  self.registered = {}
end

--
-- Clear the registry
--
-- @spec :clear() :: self
function ic:clear()
  self.registered = {}
  return self
end

-- @type SoundSet :: {
--   extends = [name: String, ...],
--   sounds = NodeSounds -- see minetest's node sound thingy
-- }

--
-- Register a base node sound set
--
-- @spec :register(name: String, SoundSet) :: self
function ic:register(name, sound_set)
  self.registered[name] = {
    extends = sound_set.extends or {},
    sounds = sound_set.sounds or {},
  }

  return self
end

--
-- Retrieve a soundset by name
--
-- @spec :get(name: String) :: SoundSet |nil
function ic:get(name)
  return self.registered[name]
end

--
-- Retrieve a soundset by name
-- Will error if the soundset does not exist
--
-- @spec :fetch(name: String!) :: SoundSet
function ic:fetch(name)
  local sound_set = self:get(name)
  if sound_set then
    return sound_set
  else
    error("expected sound_set name='" .. name .. "' to exist")
  end
end

--
-- Build a node sounds table by name and optionally a custom soundset over it.
--
-- @spec :build(name: String!, sound_set: SoundSet | nil) :: NodeSounds
function ic:build(name, sound_set)
  sound_set = sound_set or {}
  sound_set.extends = sound_set.extends or {}
  sound_set.sounds = sound_set.sounds or {}

  local super_sound_set = self:fetch(name)
  local base = self:_build_sound_set(super_sound_set)
  local top = self:_build_sound_set(sound_set)

  return yatm_core.table_merge(base, top)
end

function ic:_build_sound_set(sound_set)
  local base = {}

  for _, mixin_name in ipairs(sound_set.extends) do
    base = yatm_core.table_merge(base, self:build(mixin_name))
  end

  return base
end

yatm_core.node_sounds = NodeSoundsRegistry:new()

-- TODO: registration shouldn't be here...
--       But for the sake of getting default out of the codebase...

-- It's okay to register an empty set.
yatm_core.node_sounds:register("base", {})
yatm_core.node_sounds:register("glass", { extends = { "base" } })
yatm_core.node_sounds:register("wood", { extends = { "base" } })
yatm_core.node_sounds:register("leaves", { extends = { "base" } })
yatm_core.node_sounds:register("metal", { extends = { "base" } })
yatm_core.node_sounds:register("stone", { extends = { "base" } })
yatm_core.node_sounds:register("water", { extends = { "base" } })
yatm_core.node_sounds:register("cardboard", { extends = { "base" } })
