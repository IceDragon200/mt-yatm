-- TODO: gradually allow certain functions and sub fields in the globals

globals = {
  -- Allow certain minetest functions
  minetest = {
    fields = {
      registered_craftitems = {
        other_fields = true
      },
      registered_nodes = {
        other_fields = true
      },
      registered_tools = {
        other_fields = true
      },

      -- Chat
      chat_send_player = {},
      chat_send_all = {},

      -- Entities
      add_entity = {},
      register_entity = {},

      get_current_modname = {},
      get_item_group = {},
      get_meta = {},
      get_modpath = {},
      get_worldpath = {},
      get_node = {},
      get_node_or_nil = {},
      hash_node_position = {},
      log = {},
      pos_to_string = {},
      register_abm = {},
      register_craftitem = {},
      register_globalstep = {},
      register_lbm = {},
      register_node = {},
      register_on_mods_loaded = {},
      register_on_shutdown = {},
      register_tool = {},
      swap_node = {},

      --
      raycast = {},

      -- serialization functions
      deserialize = {},
      serialize = {},

      -- io
      safe_file_write = {},
      mkdir = {},
      write_json = {},

      -- sound
      sound_play = {},
    },
  },
  -- Allow foundation functions
  foundation = {
    fields = {
      new_module = {},
      com = {
        other_fields = true,
      }
    }
  },
  -- Allow yatm global modules
  yatm = {
    fields = {
      register_stateful_node = {},
      queue_refresh_infotext = {},
      formspec_bg_for_player = {},

      -- Formspec backgrounds
      bg = {
        other_fields = true,
      },
      bg9 = {
        other_fields = true,
      },

      -- blasting module
      blasting = {

      },

      -- computers service
      computers = {
        fields = {
          method = {},
        },
      },

      -- individual clusters
      cluster = {
        fields = {
          reactor = {},
          energy = {},
          thermal = {},
        },
      },

      -- clusters service
      clusters = {
        fields = {
          observe = {},
          mark_node_block = {},
          schedule_node_event = {},
          reduce_node_clusters = {},
        },
      },

      -- devices module
      devices = {

      },

      dscs = {

      },

      -- energy module
      energy = {

      },

      -- fluids module
      fluids = {
        fields = {
          FluidStack = {},
        },
      },

      icbm = {
      },

      -- mail module
      mail = {},

      -- molding module
      molding = {},

      -- security module
      security = {},

      -- sawing module
      sawing = {
        fields = {
          sawing_registry = {},
        },
      },

      -- spacetime module
      spacetime = {
        fields = {},
      },

      transport = {
        fields = {
          GenericTransportNetwork = {},
        },
      },
    },
  },
  -- minetest's dump function
  dump = {},
  -- minetest's vector module
  vector = {
    fields = {
      new = {},
      add = {},
      subtract = {},
      multiply = {},
    }
  },
  -- minetest's ItemStack module
  ItemStack = {}
}

max_line_length = 100
max_code_line_length = 100

include_files = {"yatm_*/*.lua"}

-- ignore each module's global
files["yatm_armoury/**.lua"] = { globals = {"yatm_armoury"} }
files["yatm_armoury_icbm/**.lua"] = { globals = {"yatm_armoury_icbm"} }
files["yatm_autotest/**.lua"] = { globals = {"yatm_autotest"} }
files["yatm_bees/**.lua"] = { globals = {"yatm_bees"} }
files["yatm_blasts/**.lua"] = { globals = {"yatm_blasts"} }
files["yatm_blasts_emp/**.lua"] = { globals = {"yatm_blasts_emp"} }
files["yatm_blasts_frost/**.lua"] = { globals = {"yatm_blasts_frost"} }
files["yatm_brewery/**.lua"] = { globals = {"yatm_brewery"} }
files["yatm_brewery_apple_cider/**.lua"] = { globals = {"yatm_brewery_apple_cider"} }
files["yatm_cables/**.lua"] = { globals = {"yatm_cables"} }
files["yatm_cluster_energy/**.lua"] = { globals = {"yatm_cluster_energy"} }
files["yatm_cluster_thermal/**.lua"] = { globals = {"yatm_cluster_thermal"} }
files["yatm_clusters/**.lua"] = { globals = {"yatm_clusters"} }
files["yatm_core/**.lua"] = { globals = {"yatm_core"} }
files["yatm_codex/**.lua"] = { globals = {"yatm_codex"} }
files["yatm_codex_entries/**.lua"] = { globals = {"yatm_codex_entries"} }
files["yatm_culinary/**.lua"] = { globals = {"yatm_culinary"} }
files["yatm_cluster_energy/**.lua"] = { globals = {"yatm_cluster_energy"} }
files["yatm_cluster_thermal/**.lua"] = { globals = {"yatm_cluster_thermal"} }
files["yatm_data_card_readers/**.lua"] = { globals = {"yatm_data_card_readers"} }
files["yatm_data_control/**.lua"] = { globals = {"yatm_data_control"} }
files["yatm_data_console_monitor/**.lua"] = { globals = {"yatm_data_console_monitor"} }
files["yatm_data_display/**.lua"] = { globals = {"yatm_data_display"} }
files["yatm_data_fluid_sensor/**.lua"] = { globals = {"yatm_data_fluid_sensor"} }
files["yatm_data_logic/**.lua"] = { globals = {"yatm_data_logic"} }
files["yatm_data_network/**.lua"] = { globals = {"yatm_data_network"} }
files["yatm_data_noteblock/**.lua"] = { globals = {"yatm_data_noteblock"} }
files["yatm_data_to_mesecon/**.lua"] = { globals = {"yatm_data_to_mesecon"} }
files["yatm_decor/**.lua"] = { globals = {"yatm_decor"} }
files["yatm_drones/**.lua"] = { globals = {"yatm_drones"} }
files["yatm_dscs/**.lua"] = { globals = {"yatm_dscs"} }
files["yatm_energy_storage/**.lua"] = { globals = {"yatm_energy_storage"} }
files["yatm_energy_storage_array/**.lua"] = { globals = {"yatm_energy_storage_array"} }
files["yatm_fluid_pipe_valves/**.lua"] = { globals = {"yatm_fluid_pipe_valves"} }
files["yatm_fluid_pipes/**.lua"] = { globals = {"yatm_fluid_pipes"} }
files["yatm_fluid_teleporters/**.lua"] = { globals = {"yatm_fluid_teleporters"} }
files["yatm_fluids/**.lua"] = { globals = {"yatm_fluids"} }
files["yatm_foundry/**.lua"] = { globals = {"yatm_foundry"} }
files["yatm_frames/**.lua"] = { globals = {"yatm_frames"} }
files["yatm_item_ducts/**.lua"] = { globals = {"yatm_item_ducts"} }
files["yatm_item_shelves/**.lua"] = { globals = {"yatm_item_shelves"} }
files["yatm_item_storage/**.lua"] = { globals = {"yatm_item_storage"} }
files["yatm_item_teleporters/**.lua"] = { globals = {"yatm_item_teleporters"} }
files["yatm_machines/**.lua"] = { globals = {"yatm_machines"} }
files["yatm_mail/**.lua"] = { globals = {"yatm_mail"} }
files["yatm_mesecon_buttons/**.lua"] = { globals = {"yatm_mesecon_buttons"} }
files["yatm_mesecon_card_readers/**.lua"] = { globals = {"yatm_mesecon_card_readers"} }
files["yatm_mesecon_hubs/**.lua"] = { globals = {"yatm_mesecon_hubs"} }
files["yatm_mesecon_locks/**.lua"] = { globals = {"yatm_mesecon_locks"} }
files["yatm_mesecon_sequencer/**.lua"] = { globals = {"yatm_mesecon_sequencer"} }
files["yatm_mining/**.lua"] = { globals = {"yatm_mining"} }
files["yatm_oku/**.lua"] = { globals = {"yatm_oku"} }
files["yatm_overhead_rails/**.lua"] = { globals = {"yatm_overhead_rails"} }
files["yatm_papercraft/**.lua"] = { globals = {"yatm_papercraft"} }
files["yatm_plastics/**.lua"] = { globals = {"yatm_plastics"} }
files["yatm_rails/**.lua"] = { globals = {"yatm_rails"} }
files["yatm_reactions/**.lua"] = { globals = {"yatm_reactions"} }
files["yatm_reactors/**.lua"] = { globals = {"yatm_reactors"} }
files["yatm_refinery/**.lua"] = { globals = {"yatm_refinery"} }
files["yatm_security/**.lua"] = { globals = {"yatm_security"} }
files["yatm_security_api/**.lua"] = { globals = {"yatm_security_api"} }
files["yatm_solar_energy/**.lua"] = { globals = {"yatm_solar_energy"} }
files["yatm_spacetime/**.lua"] = { globals = {"yatm_spacetime"} }
files["yatm_woodcraft/**.lua"] = { globals = {"yatm_woodcraft"} }
