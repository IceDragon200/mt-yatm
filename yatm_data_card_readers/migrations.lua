local migrations = {
  ["yatm_mesecon_locks:data_card_reader_off"] = "yatm_data_card_readers:data_card_reader_off",
  ["yatm_mesecon_locks:data_card_reader_on"] = "yatm_data_card_readers:data_card_reader_on",
  ["yatm_mesecon_locks:data_card_swiper_off"] = "yatm_data_card_readers:data_card_swiper_off",
  ["yatm_mesecon_locks:data_card_swiper_on"] = "yatm_data_card_readers:data_card_swiper_on",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_data_card_readers:migrate_" .. string.gsub(from, ":", "_"),
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
