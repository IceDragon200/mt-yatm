--
-- YATM Codex Entries
--
-- Provides CODEX entries for YATM mods
--
yatm_codex_entries = rawget(_G, "yatm_codex_entries") or {}
yatm_codex_entries.modpath = minetest.get_modpath(minetest.get_current_modname())

if yatm_data_noteblock then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_data_noteblock.lua")
end

--[[
if yatm_drones then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_drones.lua")
end

if yatm_dscs then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_dscs.lua")
end

if yatm_energy_storage_array then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_energy_storage_array.lua")
end

if yatm_foundry then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_foundry.lua")
end

if yatm_mail then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_mail.lua")
end
]]
