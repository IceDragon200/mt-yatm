local path_dirname = assert(foundation.com.path_dirname)

--- @namespace yatm_blasts

--- @class BlastsSystem
local BlastsSystem = foundation.com.Class:extends("BlastsSystem")
local ic = assert(BlastsSystem.instance_class)

--- @type InitOptions: {
---   filename: String
--- }

--- @spec #initialize(options: InitOptions): void
function ic:initialize(options)
  --
  self.filename = options.filename
  self.initialized = false
  self.terminated = false
  self.elapsed = 0
  self.elapsed_since_last_persist = 0

  self.explosion_types = {}
  self.expired_explosions = {}

  self.kv = nokore.KVStore:new()
end

--- @spec #init(): void
function ic:init()
  --
  minetest.log("info", "attempting to reload explosions")

  if self.kv:marshall_load_file(self.filename) then
    --
    minetest.log("info", "loaded explosions")
  end

  self:_migrate()

  self.initialized = true
end

---
function ic:_migrate()
  local version = self.kv:get("version")

  self.kv:put("version", "2025-03-22")
end

--- @spec #terminate(): void
function ic:terminate()
  --
  self:_maybe_persist_explosions()
  self.terminated = true
end

--- @spec #_maybe_persist_explosions(): void
function ic:_maybe_persist_explosions()
  if self.kv.dirty then
    local dirname = path_dirname(self.filename)
    core.mkdir(dirname)
    minetest.log("info", "persisting explosions")
    if self.kv:marshall_dump_file(self.filename) then
      self.kv.dirty = false
      minetest.log("info", "persisted explosions")
    else
      minetest.log("warning", "could not persist explosions")
    end
  end
end

--- @spec #register_explosion_type(name: String, params: Table): (Table, self)
function ic:register_explosion_type(name, params)
  if not self.initialized then
    self.explosion_types[name] = params
    return params, self
  end
  error("system is already initialized, cannot register new explosion types")
end

--- @spec #unregister_explosion_type(name: String): self
function ic:unregister_explosion_type(name)
  if not self.initialized then
    self.explosion_types[name] = nil
    return self
  end

  error("system is already initialized, cannot unregister explosion types")
end

--- @spec #update(delta: Float): void
function ic:update(delta)
  if self.terminated then
    return
  end
  if not self.initialized then
    return
  end
  self.elapsed = self.elapsed + delta
  self.elapsed_since_last_persist = self.elapsed_since_last_persist + delta

  local explosion_def

  local explosions = self.kv:get("explosions")
  if explosions then
    for id, explosion in pairs(explosions) do
      if explosion.expired then
        self.expired_explosions[id] = explosion
      else
        explosion.elapsed = explosion.elapsed + delta
        explosion_def = assert(self.explosion_types[explosion.kind])

        explosion_def.update(explosion.assigns, self, explosion, delta)
      end
    end
  end

  if next(self.expired_explosions) then
    for id, explosion in pairs(self.self.expired_explosions) do
      explosion_def = assert(self.explosion_types[explosion.kind])

      if explosion_def.on_expired then
        explosion_def.on_expired(explosion.assigns, self, explosion)
      end

      if explosions then
        explosions[id] = nil
      end
    end

    self.expired_explosions = {}
  end

  if self.elapsed_since_last_persist > 60 then
    self:_maybe_persist_explosions()
    self.elapsed_since_last_persist = 0
  end
end

--- @spec #create_explosion(pos: Vector3, kind: String, params: Table): (Boolean, String)
function ic:create_explosion(pos, kind, params)
  if self.explosion_types[kind] then
    local explosion_def = self.explosion_types[kind]
    local id = self.kv:get("g_explosion_id", 0) + 1
    self.kv:put("g_explosion_id", id)

    local explosion = {
      pos = pos,
      kind = kind,
      assigns = {},
      elapsed = 0,
      expired = false,
    }

    if explosion_def.init then
      explosion_def.init(explosion.assigns, self, explosion, params)
    end

    local explosions = self.kv:get("explosions") or {}
    explosions[id] = explosion
    self.kv:put("explosions", explosions)
    return true, nil
  end
  minetest.log("error", "explosion type " .. kind .. " does not exist")
  return false, "explosion type doesn't exist"
end

yatm_blasts.BlastsSystem = BlastsSystem
