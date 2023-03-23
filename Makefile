RELEASE_DIR=${TMP_DIR}/yatm

all:
	make -C yatm_oku

.PHONY : luacheck
luacheck:
	luacheck .

.PHONY: release
release:
	git archive --format tar --output "${BUILD_DIR}/yatm.tar" master

# Release step specifically when the modpack is under a game, this will copy
# the modpack to the TMP_DIR
.PHONY: release.game
release.game:
	mkdir -p "${RELEASE_DIR}"

	cp -r --parents yatm_armoury "${RELEASE_DIR}"
	cp -r --parents yatm_armoury_c4 "${RELEASE_DIR}"
	cp -r --parents yatm_armoury_icbm "${RELEASE_DIR}"
	cp -r --parents yatm_autotest "${RELEASE_DIR}"
	cp -r --parents yatm_bees "${RELEASE_DIR}"
	cp -r --parents yatm_blasts "${RELEASE_DIR}"
	cp -r --parents yatm_blasts_emp "${RELEASE_DIR}"
	cp -r --parents yatm_blasts_frost "${RELEASE_DIR}"
	cp -r --parents yatm_brewery "${RELEASE_DIR}"
	cp -r --parents yatm_brewery_apple_cider "${RELEASE_DIR}"
	cp -r --parents yatm_cables "${RELEASE_DIR}"
	cp -r --parents yatm_cluster_devices "${RELEASE_DIR}"
	cp -r --parents yatm_cluster_energy "${RELEASE_DIR}"
	cp -r --parents yatm_cluster_thermal "${RELEASE_DIR}"
	cp -r --parents yatm_clusters "${RELEASE_DIR}"
	cp -r --parents yatm_codex "${RELEASE_DIR}"
	cp -r --parents yatm_core "${RELEASE_DIR}"
	cp -r --parents yatm_culinary "${RELEASE_DIR}"
	cp -r --parents yatm_data_cables "${RELEASE_DIR}"
	cp -r --parents yatm_data_card_readers "${RELEASE_DIR}"
	cp -r --parents yatm_data_console_monitor "${RELEASE_DIR}"
	cp -r --parents yatm_data_control "${RELEASE_DIR}"
	cp -r --parents yatm_data_display "${RELEASE_DIR}"
	cp -r --parents yatm_data_fluid_sensor "${RELEASE_DIR}"
	cp -r --parents yatm_data_logic "${RELEASE_DIR}"
	cp -r --parents yatm_data_network "${RELEASE_DIR}"
	cp -r --parents yatm_data_noteblock "${RELEASE_DIR}"
	cp -r --parents yatm_data_to_mesecon "${RELEASE_DIR}"
	cp -r --parents yatm_debug "${RELEASE_DIR}"
	cp -r --parents yatm_decor "${RELEASE_DIR}"
	cp -r --parents yatm_device_hubs "${RELEASE_DIR}"
	cp -r --parents yatm_drones "${RELEASE_DIR}"
	cp -r --parents yatm_dscs "${RELEASE_DIR}"
	cp -r --parents yatm_energy_storage "${RELEASE_DIR}"
	cp -r --parents yatm_energy_storage_array "${RELEASE_DIR}"
	cp -r --parents yatm_fluid_pipe_valves "${RELEASE_DIR}"
	cp -r --parents yatm_fluid_pipes "${RELEASE_DIR}"
	cp -r --parents yatm_fluid_teleporters "${RELEASE_DIR}"
	cp -r --parents yatm_foundry "${RELEASE_DIR}"
	cp -r --parents yatm_frames "${RELEASE_DIR}"
	cp -r --parents yatm_item_ducts "${RELEASE_DIR}"
	cp -r --parents yatm_item_shelves "${RELEASE_DIR}"
	cp -r --parents yatm_item_storage "${RELEASE_DIR}"
	cp -r --parents yatm_item_teleporters "${RELEASE_DIR}"
	cp -r --parents yatm_machines "${RELEASE_DIR}"
	cp -r --parents yatm_mail "${RELEASE_DIR}"
	cp -r --parents yatm_mesecon_buttons "${RELEASE_DIR}"
	cp -r --parents yatm_mesecon_card_readers "${RELEASE_DIR}"
	cp -r --parents yatm_mesecon_hubs "${RELEASE_DIR}"
	cp -r --parents yatm_mesecon_locks "${RELEASE_DIR}"
	cp -r --parents yatm_mesecon_sequencer "${RELEASE_DIR}"
	cp -r --parents yatm_mining "${RELEASE_DIR}"
	cp -r --parents yatm_oku "${RELEASE_DIR}"
	cp -r --parents yatm_overhead_rails "${RELEASE_DIR}"
	cp -r --parents yatm_packs "${RELEASE_DIR}"
	cp -r --parents yatm_papercraft "${RELEASE_DIR}"
	cp -r --parents yatm_plastics "${RELEASE_DIR}"
	cp -r --parents yatm_rails "${RELEASE_DIR}"
	cp -r --parents yatm_reactions "${RELEASE_DIR}"
	cp -r --parents yatm_reactors "${RELEASE_DIR}"
	cp -r --parents yatm_refinery "${RELEASE_DIR}"
	cp -r --parents yatm_security "${RELEASE_DIR}"
	cp -r --parents yatm_security_api "${RELEASE_DIR}"
	cp -r --parents yatm_solar_energy "${RELEASE_DIR}"
	cp -r --parents yatm_spacetime "${RELEASE_DIR}"
	cp -r --parents yatm_thermal_ducts "${RELEASE_DIR}"
	cp -r --parents yatm_vault_door "${RELEASE_DIR}"
	cp -r --parents yatm_woodcraft "${RELEASE_DIR}"
	# cp -r --parents yatm_woodcraft_default "${RELEASE_DIR}"
	cp -r --parents yatm_woodcraft_nokore "${RELEASE_DIR}"

	cp CREDITS.md "${RELEASE_DIR}"
	cp LICENSE "${RELEASE_DIR}"
	cp logo.png "${RELEASE_DIR}"
	cp modpack.conf "${RELEASE_DIR}"
	cp README.md "${RELEASE_DIR}"
