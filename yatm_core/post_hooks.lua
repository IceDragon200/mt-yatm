--
-- Callbacks when everything has loaded
--
local string_starts_with = assert(foundation.com.string_starts_with)

local function dump_nodes()
  -- Export yatm specific nodes for documentation purposes
  print("Exporting Nodes")
  local i = 0
  local result = {}
  for name, def in pairs(minetest.registered_nodes) do
    if string_starts_with(name, "yatm_") or
       string_starts_with(name, "harmonia_") then
      i = i + 1

      result[i] = minetest.write_json({
        name = name,
        basename = def.basename or name,
        base_description = def.base_description,
        description = def.description,
        groups = def.groups,
        tiles = def.tiles,
        special_tiles = def.special_tiles,
        drawtype = def.drawtype,
        node_box = def.node_box,
        paramtype = def.paramtype,
        paramtype2 = def.paramtype2,
      })
    end
  end

  minetest.safe_file_write(minetest.get_worldpath() .. "/yatm_exported_nodes.mljson", table.concat(result, "\n"))
  print("Exported Nodes count=" .. i)
end

local function dump_craftitems()
  -- Export yatm specific nodes for documentation purposes
  print("Exporting Craftitems")
  local i = 0
  local result = {}

  for name, def in pairs(minetest.registered_craftitems) do
    if string_starts_with(name, "yatm_") or
       string_starts_with(name, "harmonia_") then
      i = i + 1
      result[i] = minetest.write_json({
        name = name,
        basename = def.basename or name,
        base_description = def.base_description,
        description = def.description,
        groups = def.groups,
        inventory_image = def.inventory_image,
      })
    end
  end

  minetest.safe_file_write(minetest.get_worldpath() .. "/yatm_exported_craftitems.mljson", table.concat(result, "\n"))
  print("Exported Craftitems count=" .. i)
end

local function dump_tools()
  -- Export yatm specific nodes for documentation purposes
  print("Exporting Tools")
  local i = 0
  local result = {}

  for name, def in pairs(minetest.registered_tools) do
    if string_starts_with(name, "yatm_") or
       string_starts_with(name, "harmonia_") then
      i = i + 1
      result[i] = minetest.write_json({
        name = name,
        basename = def.basename or name,
        base_description = def.base_description,
        description = def.description,
        groups = def.groups,
        inventory_image = def.inventory_image,
      })
    end
  end

  minetest.safe_file_write(minetest.get_worldpath() .. "/yatm_exported_tools.mljson", table.concat(result, "\n"))
  print("Exported Tools count=" .. i)
end

minetest.register_on_mods_loaded(function ()
  if yatm.config.dump_nodes then
    dump_nodes()
  end
  if yatm.config.dump_craftitems then
    dump_craftitems()
  end
  if yatm.config.dump_tools then
    dump_tools()
  end
end)
