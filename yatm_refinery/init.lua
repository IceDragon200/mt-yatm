yatm_refinery = rawget(_G, "yatm_refinery") or {}
yatm_refinery.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_refinery.modpath .. "/fluids.lua")
dofile(yatm_refinery.modpath .. "/nodes.lua")

local migrations = {
  ["yatm_machines:pump_off"] = "yatm_refinery:pump_off",
  ["yatm_machines:pump_on"] = "yatm_refinery:pump_on",
  ["yatm_machines:pump_error"] = "yatm_refinery:pump_error",
  ["yatm_machines:boiler_off"] = "yatm_refinery:boiler_off",
  ["yatm_machines:boiler_on"] = "yatm_refinery:boiler_on",
  ["yatm_machines:boiler_error"] = "yatm_refinery:boiler_error",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_refinery:migrate_" .. string.gsub(from, ":", "_"),
    nodenames = {
      from,
    },
    run_at_every_load = true,
    action = function (pos, node)
      node.name = to
      minetest.swap_node(pos, node)
    end
  })
end
