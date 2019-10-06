--
-- All minetest hooks
--
minetest.register_on_mods_loaded(yatm.computers:method("setup"))
minetest.register_globalstep(yatm.computers:method("update"))
minetest.register_on_shutdown(yatm.computers:method("terminate"))
