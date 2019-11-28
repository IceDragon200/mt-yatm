--
-- YATM Mesecon Card Readers
--
yatm_mesecon_card_readers = rawget(_G, "yatm_mesecon_card_readers") or {}
yatm_mesecon_card_readers.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_mesecon_card_readers.modpath .. "/items.lua")
dofile(yatm_mesecon_card_readers.modpath .. "/nodes.lua")

dofile(yatm_mesecon_card_readers.modpath .. "/migrations.lua")
