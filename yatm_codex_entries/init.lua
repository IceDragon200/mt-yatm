--
-- YATM Codex Entries
--
-- Provides CODEX entries for YATM mods
--
yatm_codex_entries = rawget(_G, "yatm_codex_entries") or {}
yatm_codex_entries.modpath = minetest.get_modpath(minetest.get_current_modname())

if yatm_armoury then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_armoury.lua")
end

if yatm_armoury_icbm then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_armoury_icbm.lua")
end

if yatm_data_noteblock then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_data_noteblock.lua")
end

if yatm_drones then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_drones.lua")
end

if yatm_dscs then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_dscs.lua")
end

if yatm_energy_storage_array then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_energy_storage_array.lua")
end

if yatm_fluid_pipe_valves then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_fluid_pipe_valves.lua")
end

if yatm_fluid_pipes then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_fluid_pipes.lua")
end

if yatm_fluid_teleporters then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_fluid_teleporters.lua")
end

if yatm_foundry then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_foundry.lua")
end

if yatm_frames then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_frames.lua")
end

if yatm_item_ducts then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_item_ducts.lua")
end

if yatm_item_teleporters then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_item_teleporters.lua")
end

if yatm_mail then
  dofile(yatm_codex_entries.modpath .. "/entries/yatm_mail.lua")
end
