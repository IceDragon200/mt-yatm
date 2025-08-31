--
-- All minetest hooks
--
if not yatm.computers then
  yatm.warn("yatm.computers is unavailable, will not set hooks")
  return
end

core.register_on_mods_loaded(yatm.computers:method("setup"))
nokore_proxy.register_globalstep("yatm_oku.update/1", yatm.computers:method("update"))
core.register_on_shutdown(yatm.computers:method("terminate"))

core.register_lbm({
  label = "Reload YATM Computers",
  name = "yatm_oku:reload_computers",

  nodenames = {
    "group:yatm_computer",
  },

  run_at_every_load = true,

  action = function (pos, node)
    local nodedef = core.registered_nodes[node.name]
    if nodedef then
      core.log("info", "registering computer node " .. core.pos_to_string(pos))
      nodedef.register_computer(pos, node)
    else
      core.log("error", "not a valid computer node " .. core.pos_to_string(pos))
    end
  end
})
