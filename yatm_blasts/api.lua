yatm.blasts = yatm.blasts or {}

yatm_blasts.blasts_system = yatm_blasts.BlastsSystem:new()
yatm.blasts.system = yatm_blasts.blasts_system

minetest.register_on_mods_loaded(yatm.blasts.system:method("init"))
minetest.register_globalstep(yatm.blasts.system:method("update"))
minetest.register_on_shutdown(yatm.blasts.system:method("terminate"))
