-- Binary Serializer
yatm_core.binary_types = {}
dofile(yatm_core.modpath .. "/util/bin_types/array.lua")
dofile(yatm_core.modpath .. "/util/bin_types/bytes.lua")
dofile(yatm_core.modpath .. "/util/bin_types/map.lua")
dofile(yatm_core.modpath .. "/util/bin_types/marshall_value.lua")
dofile(yatm_core.modpath .. "/util/bin_types/naive_datetime.lua")
dofile(yatm_core.modpath .. "/util/bin_types/scalars.lua")
