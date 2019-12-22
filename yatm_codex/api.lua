yatm.codex = yatm.codex or {}

yatm.codex.registered_entries = {}
yatm.codex.registered_demos = {}

local function default_demo_init(pos)
  return nil
end

local function default_demo_build(pos, assigns)
end

local function default_demo_configure(pos, assigns)
end

local function default_demo_done(pos, assigns)
end

function yatm.codex.register_entry(name, def)
  assert(def.pages, "expected to have pages")
  yatm.codex.registered_entries[name] = def
end

function yatm.codex.register_demo(name, def)
  def.init = def.init or default_demo_init
  def.build = def.build or default_demo_build
  def.configure = def.configure or default_demo_configure
  def.done = def.done or default_demo_done

  yatm.codex.registered_demos[name] = def
end
