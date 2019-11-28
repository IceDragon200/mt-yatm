--
-- YATM Mesecon Sequencer
--
yatm_mesecon_sequencer = rawget(_G, "yatm_mesecon_sequencer") or {}
yatm_mesecon_sequencer.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_mesecon_sequencer.modpath .. "/nodes.lua")
