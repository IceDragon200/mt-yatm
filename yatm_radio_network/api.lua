--- @namespace yatm_radio_network

--- @const radio_network: RadioNetwork
yatm_radio_network.radio_network = yatm_radio_network.RadioNetwork:new()

core.register_on_mods_loaded(yatm_radio_network.radio_network:method("init"))
nokore_proxy.register_globalstep(
  "yatm_radio_network.update/1",
  yatm_radio_network.radio_network:method("update")
)
core.register_on_shutdown(yatm_radio_network.radio_network:method("terminate"))
