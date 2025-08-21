local Color = assert(foundation.com.Color)
--

-- Dump all YATM nodes in a TOML file for further refinement
yatm.config.dump_nodes = true

-- Dump all YATM craftitems in a TOML file for further refinement
yatm.config.dump_craftitems = true

-- Dump all YATM tools in a TOML file for further refinement
yatm.config.dump_tools = true

-- When a module or modules is crippled by missing core features,
-- should YATM throw an error instead of just logging?
yatm.config.fail_loud = false

--
-- Colors
--
yatm.config.extract_color = Color.maybe_to_color("#dba833")
yatm.config.insert_color = Color.maybe_to_color("#006cae")
yatm.config.data_color = Color.maybe_to_color("#b84b72")
yatm.config.error_color = Color.maybe_to_color("#fd0000")
