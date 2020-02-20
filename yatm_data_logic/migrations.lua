local migrations = {
  ["yatm_data_logic:data_pulser"] = "yatm_data_logic:data_pulser_off",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_data_logic:migrate_" .. string.gsub(from, ":", "_"),
    nodenames = {
      from,
    },
    run_at_every_load = false,
    action = function (pos, node)
      node.name = to
      minetest.swap_node(pos, node)
    end
  })
end
