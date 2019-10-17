--
-- Callbacks when everything has loaded
--
local iio = yatm.io

--[[minetest.register_on_mods_loaded(function ()
  -- Export yatm specific nodes for documentation purposes
  local file = iio.open("yatm_exported_nodes.toml", "w")
  for name, def in pairs(minetest.registered_nodes) do
    if yatm_core.string_starts_with(name, "yatm_") then
      yatm_core.TOML.write(file, {
        [name] = {
          description = def.description,
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
end)]]
