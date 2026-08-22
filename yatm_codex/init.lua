--
-- YATM Codex
--
-- Provides in game documentation and analysis of various nodes in YATM.
--
local mod = foundation.new_module("yatm_codex", "2.0.0")

mod:require("api.lua")
mod:require("formspec.lua")

yatm.codex.registry:register_domain("items", {
  description = mod.S("Items"),
})
yatm.codex.registry:register_domain("entities", {
  description = mod.S("Entities"),
})

mod:require("items.lua")

mod:require("sounds.lua")

mod:require("codex.lua")
