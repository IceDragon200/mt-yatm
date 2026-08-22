return {
  fields = {
    --
    -- Constants
    --
    CONTENT_AIR = {},
    CONTENT_IGNORE = {},
    CONTENT_UNKNOWN = {},
    --
    LIGHT_MAX = {},
    --
    -- Other
    --
    registered_items = {
      other_fields = true,
    },
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
    formspec_escape = {},
    show_formspec = {},
    close_formspec = {},
    register_on_player_receive_fields = {},

    -- inventory
    get_inventory = {},
    -- detached inventory
    create_detached_inventory = {},
    remove_detached_inventory = {},

    -- env
    request_insecure_environment = {},

    --
    get_mapgen_setting = {},

    -- ToD
    get_timeofday = {},

    -- time
    get_us_time = {},

    -- node and items
    check_single_for_falling = {},
    find_nodes_in_area_under_air = {},
    get_craft_result = {},
    get_current_modname = {},
    get_item_group = {},
    get_modpath = {},
    get_worldpath = {},
    get_name_from_content_id = {},
    hash_node_position = {},
    get_position_from_hash = {},
    log = {},
    record_protection_violation = {},
    is_protected = {},
    pos_to_string = {},
    string_to_pos = {},
    register_abm = {},
    register_chatcommand = {},
    register_craft = {},
    register_craftitem = {},
    register_globalstep = {},
    register_lbm = {},
    register_node = {},
    register_on_mods_loaded = {},
    register_on_shutdown = {},
    register_tool = {},
    --
    after = {},
    dir_to_yaw = {},
    raycast = {},
    global_exists = {},
    facedir_to_dir = {},

    -- serialization functions
    deserialize = {},
    serialize = {},

    -- io
    safe_file_write = {},
    mkdir = {},

    -- sound
    sound_play = {},

    -- json
    write_json = {},
    parse_json = {},
  },
}
