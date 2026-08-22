# YATM Core

Common module providing functionality and utility for other YATM mods.

## Available Config

Available configuration for YATM which can be set in the prelude BEFORE core is loaded.

If you set this configuration, be sure to freeze the tables (using `foundation.com.table_freeze/1` or similar).

```lua
--- @type { (basename: String), (description: String) }[]
yatm.config.metals = {
  {"copper", "Copper"} -- Example
}
```
