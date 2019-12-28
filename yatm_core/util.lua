dofile(yatm_core.modpath .. "/util/value.lua")
dofile(yatm_core.modpath .. "/util/number.lua")
dofile(yatm_core.modpath .. "/util/vector.lua")
dofile(yatm_core.modpath .. "/util/direction.lua")
dofile(yatm_core.modpath .. "/util/table.lua")
dofile(yatm_core.modpath .. "/util/cuboid.lua")
dofile(yatm_core.modpath .. "/util/list.lua")
dofile(yatm_core.modpath .. "/util/iodata.lua")
dofile(yatm_core.modpath .. "/util/string.lua")
dofile(yatm_core.modpath .. "/util/path.lua")
dofile(yatm_core.modpath .. "/util/pretty_units.lua")
dofile(yatm_core.modpath .. "/util/random.lua")
dofile(yatm_core.modpath .. "/util/item_stack.lua")
dofile(yatm_core.modpath .. "/util/node_timer.lua")
dofile(yatm_core.modpath .. "/util/inventory_list.lua")
dofile(yatm_core.modpath .. "/util/meta_ref.lua")
dofile(yatm_core.modpath .. "/util/time.lua")
dofile(yatm_core.modpath .. "/util/type_conversion.lua")
dofile(yatm_core.modpath .. "/util/toml.lua")
dofile(yatm_core.modpath .. "/util/string_buf.lua")
dofile(yatm_core.modpath .. "/util/bin_buf.lua")
-- Binary Serializer
dofile(yatm_core.modpath .. "/util/byte_decoder.lua")
if yatm_core.ByteDecoder then
  dofile(yatm_core.modpath .. "/util/byte_buf.lua")
else
  yatm.warn("yatm_core.ByteDecoder is unavailable, skipping ByteBuf module")
end
if yatm_core.ByteBuf then
  dofile(yatm_core.modpath .. "/util/bin_schema.lua")
  dofile(yatm_core.modpath .. "/util/bin_types.lua")
else
  yatm.warn("yatm_core.ByteBuf is unavailable, skipping all binary related modules")
end
