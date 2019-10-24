--
-- Migrate old 'control rods' to their respective fuel rods, as they should be.
--
local migrations = {
  ["yatm_reactors:control_rod_open"] = "yatm_reactors:fuel_rod_case_open",
  ["yatm_reactors:control_rod_case"] = "yatm_reactors:fuel_rod_case_open",
  ["yatm_reactors:fuel_rod_case"] = "yatm_reactors:fuel_rod_case_open",

  ["yatm_reactors:control_rod_close_uranium_off"] = "yatm_reactors:fuel_rod_case_uranium_off",
  ["yatm_reactors:control_rod_close_uranium_on"] = "yatm_reactors:fuel_rod_case_uranium_on",
  ["yatm_reactors:control_rod_close_uranium_error"] = "yatm_reactors:fuel_rod_case_uranium_error",

  ["yatm_reactors:control_rod_close_plutonium_off"] = "yatm_reactors:fuel_rod_case_plutonium_off",
  ["yatm_reactors:control_rod_close_plutonium_on"] = "yatm_reactors:fuel_rod_case_plutonium_on",
  ["yatm_reactors:control_rod_close_plutonium_error"] = "yatm_reactors:fuel_rod_case_plutonium_error",

  ["yatm_reactors:control_rod_close_radium_off"] = "yatm_reactors:fuel_rod_case_radium_off",
  ["yatm_reactors:control_rod_close_radium_on"] = "yatm_reactors:fuel_rod_case_radium_on",
  ["yatm_reactors:control_rod_close_radium_error"] = "yatm_reactors:fuel_rod_case_radium_error",
}

for from, to in pairs(migrations) do
  minetest.register_lbm({
    name = "yatm_reactors:migrate_" .. string.gsub(from, ":", "_"),

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
