local path_join = assert(foundation.com.path_join)

yatm.blasts = yatm.blasts or {}

yatm_blasts.blasts_system = yatm_blasts.BlastsSystem:new{
  filename = path_join(path_join(core.get_worldpath(), "yatm"), "blasts")
}
yatm.blasts.system = yatm_blasts.blasts_system

core.register_on_mods_loaded(yatm.blasts.system:method("init"))
nokore_proxy.register_globalstep("yatm_blasts.update/1", yatm.blasts.system:method("update"))
core.register_on_shutdown(yatm.blasts.system:method("terminate"))
