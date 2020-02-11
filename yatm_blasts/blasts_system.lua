local BlastsSystem = yatm_core.Class:extends("BlastsSystem")

local mod_storage = yatm_blasts.mod_storage

function ic:initialize()
  --
  self.initialized = false
  self.terminated = false
  self.elapsed = 0
  self.elapsed_since_last_persist = 0

  self.explosion_types = {}

  self.g_explosion_id = 0
  self.explosions = {}
end

function ic:init()
  --
  minetest.log("info", "attempting to reload explosions")
  local blob = mod_storage:get_string("blast_system_explosions_blob")
  if blob and blob ~= "" then
    local dump = minetest.parse_json(blob)
    self:_load_dump(dump)
  end
  self.initialized = true
end

function ic:_load_dump(dump)
  -- is the only version at the moment, so meh
  if dump.version == "2020-02-01" then
    -- dump type, not too important, but still needs to be checked
    if dump.type == "yatm.blasts.explosions" then
      self.g_explosion_id = assert(dump.data.g_explosion_id)

      self.explosions = {}

      for explosion_id_str, explosion in pairs(dump.data.explosions) do
        local explosion_id = tonumber(explosion_id_str)

        if self.explosion_types[explosion.kind] then
          self.explosions[explosion_id] = {
            pos = explosion.pos,
            kind = explosion.kind,
            assigns = explosion.assigns,
            elapsed = explosion.elapsed,
            expired = explosion.expired,
          }
        else
          minetest.log("warn", "refusing to load explosion of kind=" .. explosion.kind)
        end
      end
    end
  end
end

function ic:terminate()
  --
  self:persist_explosions()
  self.terminated = true
end

function ic:persist_explosions()
  minetest.log("info", "persisting explosions")

  local explosions = {}
  for explosion_id, explosion in pairs(self.explosions) do
    -- explicitly dump specific attributes
    -- anything outside of these will be lost
    explosions[tostring(explosion_id)] = {
      pos = explosion.pos,
      kind = explosion.kind,
      assigns = explosion.assigns,
      elapsed = explosion.elapsed,
      expired = explosion.expired,
    }
  end

  local result = {
    version = "2020-02-10",
    type = "yatm.blasts.explosions",
    data = {
      g_explosion_id = self.g_explosion_id,
      explosions = explosions,
    },
  }

  local blob = minetest.write_json(result)
  mod_storage:set_string("blast_system_explosions_blob", blob)
  minetest.log("info", "persisted explosions")
end

function ic:register_explosion_type(name, params)
  self.explosion_types[name] = params
  return params, self
end

function ic:unregister_explosion_type(name)
  self.explosion_types[name]
  return self
end

function ic:update(delta)
  if self.terminated then
    return
  end
  if not self.initialized then
    return
  end
  self.elapsed = self.elapsed + delta
  self.elapsed_since_last_persist = self.elapsed_since_last_persist + delta

  local has_expired = false

  for _, explosion in pairs(self.explosions) do
    if explosion.expired then
      has_expired = true
    else
      explosion.elapsed = explosion.elapsed + delta
      local explosion_def = assert(self.explosion_types[explosion.kind])

      explosion_def.update(self, explosion, explosion.assigns, delta)
    end
  end

  if has_expired then
    local new_explosions = {}
    for id, explosion in pairs(self.explosions) do
      if explosion.expired then
        local exposion_def = assert(self.explosion_types[explosion.kind])

        if exposion_def.on_expired then
          exposion_def.on_expired(self, explosion, explosion.assigns)
        end
      else
        new_explosions[id] = explosion
      end
    end
    self.explosions = new_explosions
  end

  if self.elapsed_since_last_persist > 60 then
    self:persist_explosions()
    self.elapsed_since_last_persist = 0
  end
end

function ic:create_explosion(pos, kind, params)
  if self.explosion_types[kind] then
    local explosion_def = self.explosion_types[kind]
    self.g_explosion_id = self.g_explosion_id + 1
    local id = self.g_explosion_id

    local explosion = {
      pos = pos,
      kind = kind,
      assigns = {},
      elapsed = 0,
      expired = false,
    }

    if explosion_def.init then
      explosion_def.init(self, explosion, explosion.assigns, params)
    end

    self.explosions[id] = explosion
    return true, nil
  end
  minetest.log("error", "explosion type " .. kind .. " does not exist")
  return false, 'explosion type doesn't exist
end

yatm_blasts.BlastsSystem = BlastsSystem
yatm_blasts.blasts_system = BlastsSystem:new()

minetest.register_on_mods_loaded(yatm_blasts.blasts_system:method("init"))
minetest.register_globalstep(yatm_blasts.blasts_system:method("update"))
minetest.register_on_shutdown(yatm_blasts.blasts_system:method("terminate"))
