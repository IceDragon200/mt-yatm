return {
  fields = {
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
    sounds = {},
    register_stateful_node = {},
    queue_refresh_infotext = {},
    formspec_bg_for_player = {},
    --
    colors_with_default = {},

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
            schedule_add_node = {},

            schedule_remove_node = {},

            schedule_update_node = {},
          },
        },
        gate = {
          fields = {
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
        energy = {
          fields = {
            schedule_add_node = {},

            schedule_remove_node = {},

            schedule_update_node = {},
          }
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
        observe = {},
        mark_node_block = {},
        schedule_node_event = {},
        reduce_node_clusters = {},
        on_next_tick = {},
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

    -- data network
    data_network = {
      fields = {
        upsert_member = {},
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
      },
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
        calc_rotate_node = {},
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
    player_inventory_lists_fragment = {},
    get_player_hotbar_size = {},
    formspec_render_split_inv_panel = {},
  },
}
