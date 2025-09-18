local Color = assert(foundation.com.Color)
local table_freeze = assert(foundation.com.table_freeze)
--

--- @namespace yatm

--- YATM by default supports a wide range of metals.
---
--- Common metals:
--- * `copper`
--- * `iron`
--- * `gold`
--- * `aluminum`
---
--- Speciality metals:
--- * `tin` - primarily for alloying and by itself has little utility
--- * `zinc` - primarily for alloying brass, brass itself is used
--- * `nickel` - primarily used for alloying into lea
--- * `cobalt` - primarily used for higher tiers of batteries
--- * `lead` - primarily used for radioactive resistance
--- * `silver` - primarily used for alloying with gold for electrum
--- * `titanium` - primarily used for higher tier anti-corrosive recipes
--- * `tungsten` - primarily used for higher tier cutting implements through
---                it's primary alloy, tungsten carbide.
---
--- Speciality alloys:
--- * `brass` - brass is typically used for building templates
--- * `lea` - LEA is used for high thermic activity machines (anything super heated)
--- * `electrum` - electrum is used in place of copper in high tier recipes for better conductivity
---
--- @const supported_metals: { (basename: String), (description: String) }[]
yatm.supported_metals = table_freeze({
  {"copper", "Copper"},
  {"tin", "Tin"},
  {"bronze", "Bronze"}, -- 4:1 Copper:Tin = 5 Bronze
  {"zinc", "Zinc"},
  {"brass", "Brass"}, -- 2:1 Copper:Zinc = 3 Brass
  {"iron", "Iron"},
  {"nickel", "Nickel"},
  {"lea", "LEA"}, -- Low Expansion Alloy, i.e. Invar; 3:2 Iron:Nickel
  {"gold", "Gold"},
  {"silver", "Silver"},
  {"electrum", "Electrum"}, -- 1:1 Gold:Silver
  {"carbon_steel", "Carbon Steel"}, -- 4:1 Iron,<Carbon> (where Carbon is any Carbon substitute)
  {"cobalt", "Cobalt"},
  {"lead", "Lead"},
  {"aluminum", "Aluminum"},
  {"titanium", "Titanium"},
  {"tungsten", "Tungsten"},
})

for _, row in ipairs(yatm.supported_metals) do
  -- prevent modification of the inner rows
  table_freeze(row)
end

--- @namespace yatm.config

--- @const metals: { String, String }[]
yatm.config.metals = yatm.config.metals or yatm.supported_metals

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
