--
-- YATM Data Card Readers
-- This was split from mesecon locks with the data-only card readers
--
yatm_data_card_readers = rawget(_G, "yatm_data_card_readers") or {}
yatm_data_card_readers.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_data_card_readers.modpath .. "/api.lua")

dofile(yatm_data_card_readers.modpath .. "/nodes.lua")
dofile(yatm_data_card_readers.modpath .. "/items.lua")

dofile(yatm_data_card_readers.modpath .. "/migrations.lua")
