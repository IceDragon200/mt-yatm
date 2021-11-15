--
-- All minetest hooks
--
if not yatm.computers then
  yatm.warn("yatm.computers is unavailable, cannot set hooks")
  return
end

minetest.register_on_mods_loaded(yatm.computers:method("setup"))
nokore_proxy.register_globalstep("yatm_oku.update/1", yatm.computers:method("update"))
minetest.register_on_shutdown(yatm.computers:method("terminate"))

minetest.register_lbm({
  label = "Reload YATM Computers",
  name = "yatm_oku:reload_computers",

  nodenames = {
    "group:yatm_computer",
  },

  run_at_every_load = true,

  action = function (pos, node)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      minetest.log("info", "registering computer node " .. minetest.pos_to_string(pos))
      nodedef.register_computer(pos, node)
    else
      minetest.log("error", "not a valid computer node " .. minetest.pos_to_string(pos))
    end
  end
})
