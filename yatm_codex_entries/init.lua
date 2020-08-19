--
-- YATM Codex Entries
--
-- Provides CODEX entries for YATM mods
--
yatm_codex_entries = foundation.new_module("yatm_codex_entries", "1.0.0")

local modules = {
  -- YATM
  "yatm_armoury",
  "yatm_armoury_icbm",
  "yatm_autotest",
  "yatm_bees",
  "yatm_blasts",
  "yatm_blasts_emp",
  "yatm_blasts_frost",
  "yatm_brewery",
  "yatm_brewery_apple_cider",
  "yatm_cables",
  "yatm_cluster_devices",
  "yatm_cluster_energy",
  "yatm_clusters",
  "yatm_cluster_thermal",
  "yatm_codex",
  "yatm_core",
  "yatm_culinary",
  "yatm_data_card_readers",
  "yatm_data_console_monitor",
  "yatm_data_control",
  "yatm_data_display",
  "yatm_data_fluid_sensor",
  "yatm_data_logic",
  "yatm_data_network",
  "yatm_data_noteblock",
  "yatm_data_to_mesecon",
  "yatm_decor",
  "yatm_drones",
  "yatm_dscs",
  "yatm_energy_storage",
  "yatm_energy_storage_array",
  "yatm_fluid_pipes",
  "yatm_fluid_pipe_valves",
  "yatm_fluids",
  "yatm_fluid_teleporters",
  "yatm_foundry",
  "yatm_frames",
  "yatm_item_ducts",
  "yatm_item_shelves",
  "yatm_item_storage",
  "yatm_item_teleporters",
  "yatm_machines",
  "yatm_mail",
  "yatm_mesecon_buttons",
  "yatm_mesecon_card_readers",
  "yatm_mesecon_hubs",
  "yatm_mesecon_locks",
  "yatm_mesecon_sequencer",
  "yatm_mining",
  "yatm_oku",
  "yatm_overhead_rails",
  "yatm_papercraft",
  "yatm_plastics",
  "yatm_rails",
  "yatm_reactions",
  "yatm_reactors",
  "yatm_refinery",
  "yatm_security",
  "yatm_security_api",
  "yatm_solar_energy",
  "yatm_spacetime",
  "yatm_woodcraft",
}

for _, module_name in ipairs(modules) do
  if minetest.global_exists(module_name) then
    yatm_codex_entries:require("entries/" .. module_name .. ".lua")
  end
end
