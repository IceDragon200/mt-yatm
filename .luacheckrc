-- TODO: gradually allow certain functions and sub fields in the globals

max_line_length = 100
max_code_line_length = 100

-- unused args do not matter
unused_args = false

globals = {
  -- mock interface
  get_player_current_formspec = {},
  trigger_rightclick_on_pos = {},
  Point = {},
  trigger_on_player_receive_fields = {},
  assert_and_remove_item_stack_in_inventory = {},
  assert_inventory_is_empty = {},
  stash_inventory_list = {},

  --
  -- Core, YATM should NOT be using the `minetest` namespace moving forward
  --
  core = loadfile(".luacheckrc.d/core.lua")(),
  --
  -- Foundation
  --
  foundation = loadfile(".luacheckrc.d/foundation.lua")(),
  --
  -- Mobkit
  --
  mobkit = {
    fields = {
      recall = {},
      forget = {},
      remember = {},
      stepfunc = {},
      actfunc = {},
      statfunc = {},
      is_alive = {},
      hq_die = {},
      hq_roam = {},
      clear_queue_high = {},
      queue_high = {},
      is_queue_empty_low = {},
      get_stand_pos = {},
    },
  },
  --
  -- Nokore
  --
  nokore = loadfile(".luacheckrc.d/nokore.lua")(),
  nokore_proxy = {
    fields = {
      register_globalstep = {},
    },
  },
  nokore_stairs = {
    fields = {
      build_and_register_nodes = {},
    },
  },
  --
  -- Foundation Tetra
  --
  tetra = loadfile(".luacheckrc.d/tetra.lua")(),
  --
  -- YATM
  --
  yatm = loadfile(".luacheckrc.d/yatm.lua")(),
  yatm_clusters = {
    fields = {
      SimpleCluster = {
        fields = {
          extends = {},
        },
      },
    },
  },
  yatm_data_logic = {
    fields = {
      FORMSPEC_SIZE = {
        fields = {
          w = {},
          h = {},
        },
      },
      layout_formspec = {},
      emit_value = {},
      emit_output_data = {},
      emit_matrix_port_value = {},
      mark_all_inputs_for_active_receive = {},
      bind_input_port = {},
      bind_matrix_ports = {},
      get_matrix_port = {},
      get_port_matrix_formspec = {},
      handle_port_matrix_fields = {},
      unmark_all_receive = {},
    },
  },
  yatm_foundry = {
    fields = {},
  },
  yatm_item_storage = {
    fields = {
      ItemDevice = {},
    },
  },
  yatm_machines = {
    fields = {},
  },
  yatm_machines_api = {
    fields = {
      GrindingRegistry = {},
      FreezingRegistry = {},
      CondensingRegistry = {},
      CompactingRegistry = {},
      RollingRegistry = {},
      CrushingRegistry = {},
    },
  },
  yatm_security = {
    fields = {
      copy_chipped_object = {},
      copy_chipped_object = {},
      copy_lockable_object_pubkey = {},
      get_access_card_stack_prvkey = {},
      is_chipped_node = {},
      is_lockable_node = {},
      is_stack_a_key_for_locked_node = {},
      is_stack_access_card = {},
      is_stack_an_access_card_for_chipped_node = {},
      is_stack_lockable_toothed_key = {},
    },
  },
  -- minetest's dump function
  dump = {},
  -- minetest's vector module
  vector = {
    fields = {
      equals = {},
      new = {},
      add = {},
      subtract = {},
      multiply = {},
      distance = {},
      direction = {},
      copy = {},
      -- round = {},
      ceil = {},
      floor = {},
      to_string = {},
    }
  },
  -- minetest's ItemStack module
  ItemStack = {},
  VoxelManip = {},
  VoxelArea = {
    fields = {
      new = {},
    },
  },
  --
  mesecon = {
    fields = {
      on_placenode = {},
      receptor_on = {},
      receptor_off = {},
      buttonlike_onrotate = {},
      on_blastnode = {},
      state = {
        fields = {
          off = {},
          on = {},
        },
      },
      rules = {
        fields = {
          default = {},
          buttonlike_get = {},
        },
      },
    },
  },
  --
  SecureRandom = {},
}

--include_files = {
--  "yatm_*/**/*.lua"
--}

-- ignore each module's global
files["yatm_armoury/**/*.lua"] = { globals = {"yatm_armoury"} }
files["yatm_armoury_c4/**/*.lua"] = { globals = {"yatm_armoury_c4", "yatm_radio_network"} }
files["yatm_armoury_icbm/**/*.lua"] = { globals = {"yatm_armoury_icbm", "yatm_blasts_frost", "yatm_blasts_emp", "yatm_blasts_explosive"} }
files["yatm_autotest/**/*.lua"] = { globals = {"yatm_autotest"} }
files["yatm_bees/**/*.lua"] = { globals = {"yatm_bees"} }
files["yatm_blasts/**/*.lua"] = { globals = {"yatm_blasts"} }
files["yatm_blasts_emp/**/*.lua"] = { globals = {"yatm_blasts_emp"} }
files["yatm_blasts_frost/**/*.lua"] = { globals = {"yatm_blasts_frost"} }
files["yatm_brewery/**/*.lua"] = { globals = {"yatm_brewery"} }
files["yatm_brewery_apple_cider/**/*.lua"] = { globals = {"yatm_brewery_apple_cider"} }
files["yatm_cables/**/*.lua"] = { globals = {"yatm_cables"} }
files["yatm_cluster_energy/**/*.lua"] = { globals = {"yatm_cluster_energy"} }
files["yatm_cluster_thermal/**/*.lua"] = { globals = {"yatm_cluster_thermal"} }
files["yatm_clusters/**/*.lua"] = { globals = {"yatm_clusters"} }
files["yatm_core/**/*.lua"] = {
  globals = {
    yatm_core = {
      fields = {
        require = {},
      },
    },
    yatm = {
      fields = {
        native_bit = {},
        ffi = {},
      },
    },
  },
}
files["yatm_codex/**/*.lua"] = { globals = {"yatm_codex"} }
files["yatm_codex_entries/**/*.lua"] = { globals = {"yatm_codex_entries"} }
files["yatm_culinary/**/*.lua"] = { globals = {"yatm_culinary"} }
files["yatm_cluster_energy/**/*.lua"] = { globals = {"yatm_cluster_energy"} }
files["yatm_cluster_thermal/**/*.lua"] = { globals = {"yatm_cluster_thermal"} }
files["yatm_data_cables/**/*.lua"] = { globals = {"yatm_data_cables"} }
files["yatm_data_card_readers/**/*.lua"] = { globals = {"yatm_data_card_readers"} }
files["yatm_data_control/**/*.lua"] = { globals = {"yatm_data_control"} }
files["yatm_data_console_monitor/**/*.lua"] = { globals = {"yatm_data_console_monitor"} }
files["yatm_data_display/**/*.lua"] = { globals = {"yatm_data_display"} }
files["yatm_data_fluid_sensor/**/*.lua"] = { globals = {"yatm_data_fluid_sensor"} }
files["yatm_data_logic/**/*.lua"] = { globals = {"yatm_data_logic"} }
files["yatm_data_network/**/*.lua"] = { globals = {"yatm_data_network"} }
files["yatm_data_noteblock/**/*.lua"] = { globals = {"yatm_data_noteblock"} }
files["yatm_data_to_mesecon/**/*.lua"] = { globals = {"yatm_data_to_mesecon"} }
files["yatm_decor/**/*.lua"] = { globals = {"yatm_decor"} }
files["yatm_device_hubs/**/*.lua"] = { globals = {"yatm_device_hubs"} }
files["yatm_drones/**/*.lua"] = { globals = {"yatm_drones"} }
files["yatm_dscs/**/*.lua"] = { globals = {"yatm_dscs"} }
files["yatm_energy_storage/**/*.lua"] = { globals = {"yatm_energy_storage"} }
files["yatm_energy_storage_array/**/*.lua"] = { globals = {"yatm_energy_storage_array"} }
files["yatm_fluid_pipe_valves/**/*.lua"] = { globals = {"yatm_fluid_pipe_valves"} }
files["yatm_fluid_pipes/**/*.lua"] = { globals = {"yatm_fluid_pipes"} }
files["yatm_fluid_teleporters/**/*.lua"] = { globals = {"yatm_fluid_teleporters"} }
files["yatm_fluids/**/*.lua"] = { globals = {"yatm_fluids"} }
files["yatm_foundry/**/*.lua"] = { globals = {"yatm_foundry"} }
files["yatm_frames/**/*.lua"] = { globals = {"yatm_frames"} }
files["yatm_item_ducts/**/*.lua"] = { globals = {"yatm_item_ducts"} }
files["yatm_item_shelves/**/*.lua"] = { globals = {"yatm_item_shelves"} }
files["yatm_item_storage/**/*.lua"] = { globals = {"yatm_item_storage"} }
files["yatm_item_teleporters/**/*.lua"] = { globals = {"yatm_item_teleporters"} }
files["yatm_machines/**/*.lua"] = { globals = {"yatm_machines"} }
files["yatm_mail/**/*.lua"] = { globals = {"yatm_mail"} }
files["yatm_mesecon_buttons/**/*.lua"] = { globals = {"yatm_mesecon_buttons"} }
files["yatm_mesecon_card_readers/**/*.lua"] = { globals = {"yatm_mesecon_card_readers"} }
files["yatm_mesecon_hubs/**/*.lua"] = { globals = {"yatm_mesecon_hubs"} }
files["yatm_mesecon_locks/**/*.lua"] = { globals = {"yatm_mesecon_locks"} }
files["yatm_mesecon_sequencer/**/*.lua"] = { globals = {"yatm_mesecon_sequencer"} }
files["yatm_mining/**/*.lua"] = { globals = {"yatm_mining"} }
files["yatm_oku/**/*.lua"] = { globals = {"yatm_oku"} }
files["yatm_overhead_rails/**/*.lua"] = { globals = {"yatm_overhead_rails"} }
files["yatm_packs/**/*.lua"] = { globals = {"yatm_packs"} }
files["yatm_papercraft/**/*.lua"] = { globals = {"yatm_papercraft"} }
files["yatm_plastics/**/*.lua"] = { globals = {"yatm_plastics"} }
files["yatm_recipe_components/**/*.lua"] = { globals = {"yatm_recipe_components"} }
files["yatm_rails/**/*.lua"] = { globals = {"yatm_rails"} }
files["yatm_reactions/**/*.lua"] = { globals = {"yatm_reactions"} }
files["yatm_reactors/**/*.lua"] = { globals = {"yatm_reactors"} }
files["yatm_refinery/**/*.lua"] = { globals = {"yatm_refinery"} }
files["yatm_security/**/*.lua"] = { globals = {"yatm_security"} }
files["yatm_security_api/**/*.lua"] = { globals = {"yatm_security_api"} }
files["yatm_solar_energy/**/*.lua"] = { globals = {"yatm_solar_energy"} }
files["yatm_spacetime/**/*.lua"] = { globals = {"yatm_spacetime"} }
files["yatm_thermal_ducts/**/*.lua"] = { globals = {"yatm_thermal_ducts"} }
files["yatm_vault_door/**/*.lua"] = { globals = {"yatm_vault_door"} }
files["yatm_woodcraft/**/*.lua"] = { globals = {"yatm_woodcraft"} }
files["yatm_woodcraft_default/**/*.lua"] = { globals = {"yatm_woodcraft"} }
files["yatm_woodcraft_nokore/**/*.lua"] = { globals = {"yatm_woodcraft", "yatm_woodcraft_nokore"} }
