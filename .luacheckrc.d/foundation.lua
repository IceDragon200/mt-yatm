return {
  fields = {
    new_module = {},
    is_module_present = {},
    com = {
      fields = {
        --
        -- Constants
        --
        ALL_PREFIXES = {},
        BINARY_PREFIXES = {},

        --
        -- Namespaces
        --
        assertions = {
          fields = {
            is_number = {},
            is_table = {},
            is_string = {},
          },
        },
        headless = {
          fields = {
            World = {
              fields = {
                new = {},
              },
            },
            MetaDataRef = {
              fields = {
                new = {},
              },
            },
          },
        },
        binary_types = {
          fields = {
            Enum = {},
            BitFlags = {},
            Bytes = {
              fields = {
                new = {},
              },
            },
          },
        },
        --
        -- Modules
        --
        bit = {},
        ByteDecoder = {
          fields = {
            d_u8 = {},
            d_u16 = {},
          },
        },
        Color = {
          fields = {},
        },
        Cuboid = {
          fields = {
            new = {},
          },
        },
        Directions = {
          fields = {
            invert_dir = {},
            facedir_wallmount_after_place_node = {},
            DIR6_TO_VEC3 = {},
            DIR_TO_STRING = {},
          },
        },
        Groups = {
          fields = {
            has_group = {},
          },
        },
        InventorySerializer = {
          fields = {
            load_list = {},
            dump_list = {},
            description = {},
          },
        },
        Rect = {},
        Vector2 = {},
        Vector3 = {
          fields = {
            to_string = {},
          },
        },
        Vector4 = {},
        ByteBuf = {
          fields = {
            little = {},
            big = {},
          },
        },
        Symbols = {
          fields = {
            symbol_to_id = {},
          },
        },
        Waves = {
          fields = {},
        },
        formspec = {
          fields = {
            api = {
            },
            parser = {},
          },
        },

        --
        -- Classes
        --
        BinaryBuffer = {
          fields = {
            new = {},
          },
        },
        BinSchema = {
          fields = {
            new = {},
          },
        },
        Class = {
          fields = {
            extends = {},
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
        List = {
          fields = {
            new = {},
          },
        },
        RingBuffer = {
          fields = {
            new = {},
          },
        },
        StringBuffer = {
          fields = {
            new = {},
          },
        },
        TokenBuffer = {
          fields = {
            new = {},
            match_tokens = {},
          },
        },
        MinHeap = {
          fields = {
            new = {},
          },
        },
        WeightedList = {
          fields = {
            new = {},
          },
        },
        Trace = {
          fields = {
            new = {},
          },
        },
        SoundsRegistry = {
          fields = {
            new = {},
          },
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
        -- Functions
        --
        ascii_pack = {},
        ascii_unpack = {},
        --
        format_pretty_time = {},
        metaref_merge_fields_from_table = {},
        metaref_string_list_to_table = {},
        metaref_string_list_push = {},
        metaref_string_list_index_of = {},
        metaref_string_list_lazy_clear = {},
        --
        is_blank = {},
        is_table_empty = {},
        --
        itemstack_copy = {},
        itemstack_inspect = {},
        itemstack_is_blank = {},
        itemstack_split = {},
        set_itemstack_meta_description = {},
        get_itemstack_description = {},
        get_itemstack_item_description = {},
        append_itemstack_meta_description = {},
        -- world
        get_inventory_drops = {},
        copy_node = {},
        node_to_string = {},
        --
        list_concat = {},
        list_sample = {},
        list_reduce = {},
        list_sort = {},
        list_map = {},
        list_get_next = {},
        list_first = {},
        list_last = {},
        --
        maybe_start_node_timer = {},
        --
        number_lerp = {},
        number_round = {},
        number_truncate = {},
        number_truncate_by_sign = {},
        --
        random_string = {},
        random_string16 = {},
        random_string32 = {},
        random_string36 = {},
        random_string62 = {},
        random_addr16 = {},
        --
        binary_splice = {},
        make_string_ref = {},
        string_each_char = {},
        string_empty = {},
        string_starts_with = {},
        string_ends_with = {},
        string_bin_encode = {},
        string_dec_encode = {},
        string_hex_clean = {},
        string_hex_decode = {},
        string_hex_encode = {},
        string_hex_escape = {},
        string_hex_unescape = {},
        string_hex_pair_to_byte = {},
        string_trim_leading = {},
        string_pad_leading = {},
        string_pad_trailing = {},
        string_sub_join = {},
        string_rsub = {},
        string_split = {},
        --
        table_bury = {},
        table_copy = {},
        table_deep_copy = {},
        table_deep_merge = {},
        table_equals = {},
        table_freeze = {},
        table_key_of = {},
        table_keys = {},
        table_length = {},
        table_merge = {},
        table_put_new = {},
        table_sample = {},
        --
        path_basename = {},
        path_dirname = {},
        path_join = {},
      },
    },
  },
}
