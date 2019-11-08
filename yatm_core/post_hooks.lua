--
-- Callbacks when everything has loaded
--
local iio = yatm.io

if yatm.config.dump_nodes then
  minetest.register_on_mods_loaded(function ()
    -- Export yatm specific nodes for documentation purposes
    print("Exporting Nodes")
    local file = iio.open("yatm_exported_nodes.toml", "w")
    local i = 0
    for name, def in pairs(minetest.registered_nodes) do
      if yatm_core.string_starts_with(name, "yatm_") then
        i = i + 1
        yatm_core.TOML.write(file, {
          [name] = {
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
          }
        })
      end
    end
    iio.close(file)
    print("Exported Nodes count=" .. i)
  end)
end
