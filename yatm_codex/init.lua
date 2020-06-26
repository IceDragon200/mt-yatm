--
-- YATM Codex
--
-- Provides in game documentation and analysis of various nodes in YATM.
--
yatm_codex = rawget(_G, "yatm_codex") or {}
yatm_codex.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_codex.modpath .. "/api.lua")

dofile(yatm_codex.modpath .. "/items.lua")

dofile(yatm_codex.modpath .. "/sounds.lua")
