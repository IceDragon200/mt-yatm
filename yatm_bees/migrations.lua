local migrations = {
  ["yatm_bees:apiary_wood"] = "yatm_bees:bee_box_wood",
  ["yatm_bees:apiary_metal"] = "yatm_bees:bee_box_metal",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_dscs:migrate_" .. string.gsub(from, ":", "_"),
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
