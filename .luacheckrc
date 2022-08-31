-- TODO: gradually allow certain functions and sub fields in the globals

max_line_length = 100
max_code_line_length = 100

-- unused args do not matter
unused_args = false

globals = {
  --
  -- Minetest
  --
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
      add_item = {},
      register_entity = {},
      get_objects_inside_radius = {},

      -- Player
      get_player_by_name = {},
      get_player_information = {},

      -- Formspec
      show_formspec = {},
      register_on_player_receive_fields = {},

      -- node and items
      get_current_modname = {},
      get_item_group = {},
      get_meta = {},
      get_modpath = {},
      get_worldpath = {},
      get_node = {},
      get_node_or_nil = {},
      hash_node_position = {},
      get_position_from_hash = {},
      log = {},
      pos_to_string = {},
      register_abm = {},
      register_chatcommand = {},
      register_craftitem = {},
      register_globalstep = {},
      register_lbm = {},
      register_node = {},
      register_on_mods_loaded = {},
      register_on_shutdown = {},
      register_tool = {},
      swap_node = {},
      bulk_set_node = {},
      add_node = {},
      --
      after = {},
      raycast = {},
      global_exists = {},
      facedir_to_dir = {},

      -- serialization functions
      deserialize = {},
      serialize = {},

      -- io
      safe_file_write = {},
      mkdir = {},
      write_json = {},

      -- sound
      sound_play = {},

      -- json
      write_json = {},
      parse_json = {},
    },
  },
  --
  -- Foundation
  --
  foundation = {
    fields = {
      new_module = {},
      com = {
        fields = {
          --
          -- Modules
          --
          Color = {
            fields = {},
          },
          Cuboid = {
            fields = {},
          },
          Directions = {
            fields = {},
          },
          Groups = {
            fields = {},
          },
          Vector2 = {},
          Vector3 = {},
          Vector4 = {},
          formspec = {
            fields = {
              api = {
              },
            },
          },

          --
          -- Classes
          --
          Class = {
            fields = {
              extends = {},
            },
          },
          FakeMetaRef = {
            fields = {
              new = {},
            },
          },
          Luna = {
            fields = {
              new = {},
            },
          },
          MetaSchema = {
            fields = {
              new = {},
            },
          },
          --
          -- Functions
          --
          ascii_pack = {},
          ascii_unpack = {},
          is_blank = {},
          is_table_empty = {},
          list_concat = {},
          list_sample = {},
          string_hex_decode = {},
          string_hex_encode = {},
          string_hex_unescape = {},
          table_copy = {},
          table_deep_merge = {},
          table_keys = {},
          table_length = {},
          table_merge = {},
        },
      },
    },
  },
  --
  -- Mobkit
  --
  mobkit = {
    fields = {},
  },
  --
  -- Nokore
  --
  nokore = {
    fields = {
      --
      -- Instances
      --
      node_sounds = {
        fields = {
          build = {},
        },
      },

      --
      -- Functions
      --
      dig_class = {},
    },
  },
  --
  -- YATM
  --
  yatm = {
    fields = {
      colors = {},
      sounds = {},
      register_stateful_node = {},
      queue_refresh_infotext = {},
      formspec_bg_for_player = {},

      --
      -- Instances
      --
      node_sounds = {
        fields = {
          build = {},
        },
      },

      -- Formspec backgrounds
      bg = {
        other_fields = true,
      },
      bg9 = {
        other_fields = true,
      },

      -- blasting module
      blasting = {
        fields = {
          blasting_registry = {},
        },
      },

      -- computers service
      computers = {
        fields = {
          method = {},
        },
      },

      compacting = {
        fields = {
          compacting_registry = {},
        },
      },

      -- individual clusters
      cluster = {
        fields = {
          devices = {
            fields = {
              --
              -- Functions
              --
              register_stateful_network_device = {},
              device_after_place_node = {},
              device_on_construct = {},
              device_on_destruct = {},
              device_after_destruct = {},
            },
          },

          reactor = {
            fields = {
              -- instance method
              method = {},

              register_system = {},

              schedule_load_node = {},
            },
          },
          energy = {
            fields = {
              schedule_add_node = {},

              schedule_remove_node = {},

              schedule_update_node = {},
            }
          },
          thermal = {
            fields = {
              schedule_add_node = {},

              schedule_remove_node = {},

              schedule_update_node = {},
            }
          },
        },
      },

      -- clusters service
      clusters = {
        fields = {
          observe = {},
          mark_node_block = {},
          schedule_node_event = {},
          reduce_node_clusters = {},

          register_node_event_handler = {},
        },
      },

      -- codex
      codex = {
        fields = {
          registered_entries = {
            other_fields = true,
          },

          register_entry = {},
          get_entry = {},

          register_demo = {},
          get_demo = {},
          registered_demos = {},

          place_node_image = {},

          fill_cuboid = {},
        }
      },

      -- condensation module
      condensing = {
        fields = {
          condensing_registry = {},
        },
      },

      -- devices module
      devices = {

      },

      dscs = {

      },

      -- energy module
      energy = {
        fields = {
          receive_energy = {},
          get_energy = {},
          consume_energy = {},
        }
      },

      -- fluids module
      fluids = {
        fields = {
          FluidStack = {},
          FluidTanks = {},
          fluid_transport_cluster = {},
        },
      },

      formspec = {
        fields = {},
      },

      freezing = {
        fields = {
          freezing_registry = {},
        }
      },

      icbm = {
      },

      items = {
        fields = {
          ItemInterface = {},
          ItemDevice = {},
        },
      },

      -- mail module
      mail = {},

      -- molding module
      molding = {
        fields = {
          molding_registry = {},
        }
      },

      -- reinfery module
      refinery = {
        fields = {
          vapour_registry = {},
          distillation_registry = {},
        }
      },

      rolling = {
        rolling_registry = {},
      },

      -- sawing module
      sawing = {
        fields = {
          sawing_registry = {},
        },
      },

      -- security module
      security = {
        fields = {
          -- constants
          NOTHING = {},
          OK = {},
          REJECT = {},
          NEEDS_ACTION = {},
          CONTINUE = {},

          -- classes
          SecurityContext = {
            fields = {
              instance_class = {
                fields = {
                  initialize = {},
                  create_transaction = {},
                }
              },

              new = {},
            },
          },

          -- registration table
          registered_security_features = {
            other_fields = true,
          },

          -- object instances
          context = {
            fields = {
              create_transaction = {},
            }
          },

          -- functions
          register_security_feature = {},
          unregister_security_feature = {},
          get_security_feature = {},
          has_node_lock = {},
          has_node_locks = {},
          get_node_lock = {},
          get_node_locks = {},
          get_node_slot_ids = {},
          check_node_locks = {},
          get_object_lock = {},
          get_object_locks = {},
          has_object_lock = {},
          has_object_locks = {},
          get_object_slot_ids = {},
          check_object_locks = {},
        }
      },

      shelves = {
        fields = {
          -- constants
          PRESET_SCALES = {},

          clear_entities = {},

          shelf_on_construct = {},
          shelf_on_destruct = {},
          shelf_after_destruct = {},
          shelf_on_dig = {},
          --
          shelf_refresh = {},
          --
          shelf_on_metadata_inventory_move = {},
          shelf_on_metadata_inventory_put = {},
          shelf_on_metadata_inventory_take = {},
          --
          shelf_on_rightclick = {},
          --
          shelf_on_blast = {},
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
      --
      -- Functions
      --
      register_stateful_node = {},
      register_stateful_tool = {},
      player_inventory_lists_fragment = {},
      get_player_hotbar_size = {},
      formspec_render_split_inv_panel = {},
    },
  },
  yatm_machines = {
  },
  yatm_security = {
    fields = {},
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
      distance = {},
      direction = {},
    }
  },
  -- minetest's ItemStack module
  ItemStack = {},
  --
  mesecon = {}
}

--include_files = {
--  "yatm_*/**/*.lua"
--}

-- ignore each module's global
files["yatm_armoury/**/*.lua"] = { globals = {"yatm_armoury"} }
files["yatm_armoury_icbm/**/*.lua"] = { globals = {"yatm_armoury_icbm"} }
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
files["yatm_core/**/*.lua"] = { globals = {"yatm_core"} }
files["yatm_codex/**/*.lua"] = { globals = {"yatm_codex"} }
files["yatm_codex_entries/**/*.lua"] = { globals = {"yatm_codex_entries"} }
files["yatm_culinary/**/*.lua"] = { globals = {"yatm_culinary"} }
files["yatm_cluster_energy/**/*.lua"] = { globals = {"yatm_cluster_energy"} }
files["yatm_cluster_thermal/**/*.lua"] = { globals = {"yatm_cluster_thermal"} }
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
files["yatm_rails/**/*.lua"] = { globals = {"yatm_rails"} }
files["yatm_reactions/**/*.lua"] = { globals = {"yatm_reactions"} }
files["yatm_reactors/**/*.lua"] = { globals = {"yatm_reactors"} }
files["yatm_refinery/**/*.lua"] = { globals = {"yatm_refinery"} }
files["yatm_security/**/*.lua"] = { globals = {"yatm_security"} }
files["yatm_security_api/**/*.lua"] = { globals = {"yatm_security_api"} }
files["yatm_solar_energy/**/*.lua"] = { globals = {"yatm_solar_energy"} }
files["yatm_spacetime/**/*.lua"] = { globals = {"yatm_spacetime"} }
files["yatm_thermal_ducts/**/*.lua"] = { globals = {"yatm_thermal_ducts"} }
files["yatm_woodcraft/**/*.lua"] = { globals = {"yatm_woodcraft"} }
files["yatm_woodcraft_default/**/*.lua"] = { globals = {"yatm_woodcraft"} }
files["yatm_woodcraft_nokore/**/*.lua"] = { globals = {"yatm_woodcraft"} }
