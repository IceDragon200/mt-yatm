return {
  fields = {
    cables = {},
    --
    config = {
      fields = {
        fail_loud = {},

        data_color = {},
        error_color = {},
        insert_color = {},
        extract_color = {},

        dump_nodes = {},
        dump_tools = {},
        dump_craftitems = {},
      },
    },
    --
    info = {},
    warn = {},
    error = {},
    fatal = {},

    colors = {},
    sounds = {
      fields = {
        register = {},
      },
    },
    queue_refresh_infotext = {},
    formspec_bg_for_player = {},
    --
    colors_with_default = {},

    --
    explore_nodes = {},

    --
    -- Classes
    --
    Clusters = {
      fields = {
        new = {},
      },
    },
    DataNetwork = {
      fields = {
        new = {},
      },
    },
    --
    ByteDecoder = {
      fields = {
        d_u8 = {},
        d_u16 = {},
        d_u32 = {},
        d_i8 = {},
        d_i16 = {},
        d_i32 = {},
      },
    },
    ByteEncoder = {
      fields = {},
    },
    --
    -- Instances
    --
    node_sounds = {
      fields = {
        build = {},
      },
    },
    --
    -- Modules
    --
    cluster_tool = {
      fields = {
        register_cluster_tool_lookup = {},
        register_cluster_tool_render = {},
      },
    },
    -- Formspec backgrounds
    bg = {
      other_fields = true,
    },
    bg9 = {
      other_fields = true,
    },

    --
    autotest = {
      fields = {
        new_suite = {},
      },
    },

    -- bees module
    bees = {
      fields = {
        itemstack_is_bee = {},
        itemstack_is_bee_worker = {},
        itemstack_is_bee_princess = {},
        itemstack_is_bee_queen = {},
        itemstack_is_frame = {},
      },
    },

    blasts = {
      fields = {
        system = {
          fields = {
            method = {},
            register_explosion_type = {},
            create_explosion = {},
          },
        },
      },
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
        create_computer_at_pos = {},
        destroy_computer_at_pos = {},
        upsert_computer_at_pos = {},
        get_computer_at_pos = {},
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
        DeviceCluster = {},

        devices = {
          fields = {
            method = {},

            schedule_load_node = {},

            schedule_add_node = {},

            schedule_remove_node = {},

            schedule_update_node = {},
          },
        },
        energy = {
          fields = {
            method = {},

            schedule_load_node = {},

            schedule_add_node = {},

            schedule_remove_node = {},

            schedule_update_node = {},

            register_system = {},
          },
        },
        gate = {
          fields = {
            method = {},

            schedule_load_node = {},

            schedule_add_node = {},

            schedule_remove_node = {},

            schedule_update_node = {},
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
        thermal = {
          fields = {
            get_node_infotext = {},

            method = {},

            register_system = {},

            schedule_load_node = {},

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
        method = {},

        observe = {},
        mark_node_block = {},
        schedule_node_event = {},
        reduce_node_clusters = {},
        reduce_clusters_of_group = {},
        on_next_tick = {},
        register_node_event_handler = {},
      },
    },

    -- codex
    codex = {
      fields = {
        registered_demos = {
          other_fields = true,
        },

        registered_entries = {
          other_fields = true,
        },

        register_entry = {},
        get_entry = {},

        register_demo = {},
        get_demo = {},

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

    crushing = {
      fields = {
        crushing_registry = {},
      },
    },

    -- data network
    data_network = {
      fields = {
        update_member = {},
        upsert_member = {},
        add_node = {},
        remove_node = {},
        get_infotext = {},
      },
    },

    -- devices module
    devices = {
      fields = {
        --
        -- Constants
        --
        ENERGY_BUFFER_KEY = {},

        --
        -- Functions
        --
        device_after_place_node = {},
        device_on_construct = {},
        device_on_destruct = {},
        device_after_destruct = {},

        get_energy_capacity = {},

        register_stateful_network_device = {},
        register_network_device = {},

        reset_idle = {},
        inc_idle = {},

        set_sleep = {},

        upgrades = {
          fields = {
            UPGRADE_SLOT = {},

            UpgradeHeaderSchema = {
              fields = {
                get_count = {},
                set_count = {},
              },
            },
            UpgradeSchema = {
              fields = {
                set = {},
                get = {},
                get_field = {},
              },
            },

            on_receive_fields_upgrades = {},
            install_upgrade_from_item_stack = {},
            find_upgrade_data_by_id = {},

            register_upgrade = {},
            get_upgrade_data_field = {},
            set_upgrade_data = {},
            upgrades_by_group = {
              other_fields = true,
            },
            registered_upgrades = {
              other_fields = true,
            },
          },
        },
      },
    },

    dscs = {
      fields = {
        --
        -- Functions
        --
        get_drive_capacity = {},
        get_drive_label = {},
        get_drive_stack_size = {},
        is_item_stack_ele_drive = {},
        is_item_stack_fluid_drive = {},
        is_item_stack_inventory_drive = {},
        is_item_stack_item_drive = {},
        load_fluid_inventory_from_drive = {},
        load_inventory_list_from_drive = {},
        make_flat_monitor_node_box = {},
        overload_fluid_inventory_from_drive = {},
        persist_inventory_list_to_drive = {},
        set_drive_label = {},

        --
        -- Modules
        --
        formspec = {
          fields = {
            render_inventory_controller_children_at = {},
            render_inventory_controller_at = {},
          },
        },
      },
    },

    -- energy module
    energy = {
      fields = {
        EnergyDevices = {},
        --
        receive_energy = {},
        get_energy = {},
        consume_energy = {},
        get_meta_energy = {},
        set_meta_energy = {},
        consume_meta_energy = {},
        receive_meta_energy = {},
      }
    },

    -- fluids module
    fluids = {
      fields = {
        FluidExchange = {},
        FluidInterface = {
          fields = {
            new_simple = {},
          },
        },
        FluidMeta = {},
        FluidStack = {},
        FluidTanks = {},
        fluid_transport_network = {},
        fluid_registry = {
          fields = {
            register = {},
          },
        },
        fluid_inventories = {
          fields = {
            destroy_fluid_inventory = {},
            get_fluid_inventory = {},
          },
        },
      },
    },

    bg_name = {
      other_fields = true,
    },
    bg9_name = {
      other_fields = true,
    },
    formspec = {
      fields = {
        set_default_energy_color = {},
        bg_for_player = {},
        render_gauge = {},
        render_energy_gauge = {},
        render_meta_energy_gauge = {},
        render_split_inv_panel = {},
        render_item_border = {},
        render_small_switch = {},
      },
    },

    freezing = {
      fields = {
        freezing_registry = {},
      }
    },

    grinding = {
      fields = {
        grinding_registry = {},
      },
    },

    icbm = {
      fields = {
        is_item_icbm_warhead = {},
        is_item_icbm_shell = {},
        is_item_stack_icbm_warhead = {},
        is_item_stack_icbm_shell = {},
      },
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

    noteblock = {
      fields = {
        play_note = {},
      },
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
        COMPLETED = {},
        CONTINUE = {},
        ERR_NODE_NOT_FOUND = {},
        ERR_NOT_A_SECURABLE_NODE = {},
        ERR_INSTALL_FEATURE_NOT_FOUND = {},
        ERR_AUTH_FAILED = {},

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

        SecuritySlotSchema = {
          fields = {},
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
        put_node_lock = {},
        check_object_locks = {},
        install_node_slot_feature = {},
        on_rightclick_access_card = {},
        security_feature_check_node_lock = {},
        security_feature_check_object_lock = {},
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
      fields = {
        SpacetimeMeta = {},
        Network = {},
        network = {},
      },
    },

    thermal = {
      fields = {
        set_heat = {},
        update_heat = {},
        get_heat = {},
      },
    },

    transport = {
      fields = {
        GenericTransportNetwork = {},
      },
    },

    units = {
      fields = {
        ALL_PREFIXES = {
          other_fields = true,
        },
        METRIC_PREFIXES = {
          other_fields = true,
        },
        BINARY_PREFIXES = {
          other_fields = true,
        },

        --
        metric = {},
        binary = {},
      },
    },
    -- recipe component
    recipe_component = {
      fields = {
        ItemOutput = {},
        ItemOutputRandom = {},
        FluidOutput = {},
        ItemIngredient = {},
        FluidIngredient = {},
      },
    },

    wrench = {
      fields = {
        ROTATE_FACE = {},
        ROTATE_AXIS = {},
        type_handler = {
          fields = {
            flowingliquid = {},
            leveled = {},
            degrotate = {},
            meshoptions = {},
            color = {},
            glasslikeliquidlevel = {},
            colordegrotate = {},
            none = {},
            wallmounted = {},
            facedir = {},
            colorfacedir = {},
            colorwallmounted = {},
          },
        },
        --
        calc_rotate_node = {},
        rotate_node = {},
        do_rotate_node = {},
        after_rotate_node = {},
        rotate_node_at_pos = {},
        user_rotate_node_at_pos = {},
      },
    },
    --
    -- Functions
    --
    register_stateful_node = {},
    register_stateful_tool = {},
    player_inventory_size2 = {},
    player_inventory_lists_fragment = {},
    get_player_hotbar_size = {},
    formspec_render_split_inv_panel = {},
    --
    build_decor_nodes = {},
    register_decor_nodes = {},
  },
}
