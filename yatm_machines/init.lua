
-- YATM

yatm_machines = {}

local cell_types = {"basic", "normal", "dense"}

for _, cell_type in ipairs(cell_types) do
	minetest.register_node("yatm_machines:energy_cell_"..cell_type, {
		description = "Energy Cell ("..cell_type..")",
		groups = {cracky = 1},
		tiles = {
			{
				name = "yatm_energy_cell_"..cell_type.."_stage0.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 1.0
				},
			},
		},
		paramtype = "light",
		paramtype2 = "facedir",
		legacy_facedir_simple = true,
	})

	minetest.register_node("yatm_machines:energy_cell_"..cell_type.."_creative", {
		description = "Energy Cell ("..cell_type..") [Creative]",
		groups = {cracky = 1},
		tiles = {
			{
				name = "yatm_energy_cell_"..cell_type.."_creative.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 1.0
				},
			},
		},
		paramtype = "light",
		paramtype2 = "facedir",
		legacy_facedir_simple = true,
	})
end

minetest.register_node("yatm_machines:coal_generator", {
	description = "Coal Generator",
	groups = {cracky = 1},
	tiles = {
		"yatm_coal_generator_top.on.png",
		"yatm_coal_generator_bottom.png",
		"yatm_coal_generator_side.png",
		"yatm_coal_generator_side.png",
		"yatm_coal_generator_side.png",
		"yatm_coal_generator_front.on.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:flux_furnace", {
	description = "Flux Furnace",
	groups = {cracky = 1},
	tiles = {
		"yatm_flux_furnace_top.on.png",
		"yatm_flux_furnace_bottom.png",
		"yatm_flux_furnace_side.on.png",
		"yatm_flux_furnace_side.on.png",
		"yatm_flux_furnace_back.png",
		"yatm_flux_furnace_front.on.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:heater", {
	description = "Heater",
	groups = {cracky = 1},
	tiles = {
		"yatm_heater_top.on.png",
		"yatm_heater_bottom.png",
		"yatm_heater_side.on.png",
		"yatm_heater_side.on.png",
		"yatm_heater_side.on.png",
		"yatm_heater_side.on.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:auto_crafter", {
	description = "Auto Crafter",
	groups = {cracky = 1},
	tiles = {
		-- "yatm_auto_crafter_top.off.png",
		{
			name = "yatm_auto_crafter_top.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0
			},
		},
		"yatm_auto_crafter_bottom.png",
		"yatm_auto_crafter_side.png",
		"yatm_auto_crafter_side.png",
		"yatm_auto_crafter_back.png",
		-- "yatm_auto_crafter_front.off.png"
		{
			name = "yatm_auto_crafter_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:auto_grinder", {
	description = "Auto Grinder",
	groups = {cracky = 1},
	tiles = {
		"yatm_auto_grinder_top.on.png",
		"yatm_auto_grinder_bottom.png",
		"yatm_auto_grinder_side.png",
		"yatm_auto_grinder_side.png",
		"yatm_auto_grinder_back.png",
		-- "yatm_auto_grinder_front.off.png"
		{
			name = "yatm_auto_grinder_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.25
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:battery_bank", {
	description = "Battery Bank",
	groups = {cracky = 1},
	tiles = {
		-- "yatm_battery_bank_top.on.png",
		{
			name = "yatm_battery_bank_top.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			},
		},
		"yatm_battery_bank_bottom.png",
		"yatm_battery_bank_side.png",
		"yatm_battery_bank_side.png^[transformFX",
		"yatm_battery_bank_back.level.4.png",
		"yatm_battery_bank_front.level.4.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:compactor", {
	description = "Compactor",
	groups = {cracky = 1},
	tiles = {
		"yatm_compactor_top.on.png",
		"yatm_compactor_bottom.png",
		"yatm_compactor_side.png",
		"yatm_compactor_side.png",
		"yatm_compactor_back.png",
		-- {"yatm_compactor_front.off.png"}
		{
			name = "yatm_compactor_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0
			},
		}
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:crusher", {
	description = "Crusher",
	groups = {cracky = 1},
	tiles = {
		"yatm_crusher_top.on.png",
		"yatm_crusher_bottom.png",
		"yatm_crusher_side.on.png",
		"yatm_crusher_side.on.png",
		"yatm_crusher_back.png",
		--"yatm_crusher_front.off.png"
		{
			name = "yatm_crusher_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:mixer", {
	description = "Mixer",
	groups = {cracky = 1},
	tiles = {
		"yatm_mixer_top.on.png",
		"yatm_mixer_bottom.png",
		"yatm_mixer_side.on.png",
		"yatm_mixer_side.on.png",
		"yatm_mixer_back.png",
		-- "yatm_mixer_front.off.png"
		{
			name = "yatm_mixer_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.25
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:roller", {
	description = "Roller",
	groups = {cracky = 1},
	tiles = {
		"yatm_roller_top.on.png",
		"yatm_roller_bottom.png",
		"yatm_roller_side.on.png",
		"yatm_roller_side.on.png",
		"yatm_roller_back.png",
		--"yatm_roller_front.off.png"
		{
			name = "yatm_roller_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.25
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:server_rack", {
	description = "Server Rack",
	groups = {cracky = 1},
	tiles = {
		"yatm_server_rack_top.png",
		"yatm_server_rack_bottom.png",
		"yatm_server_rack_side.on.png",
		"yatm_server_rack_side.on.png",
		"yatm_server_rack_back.on.png",
		-- "yatm_server_rack_front.off.png"
		{
			name = "yatm_server_rack_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0
			},
		}
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox1
		}
	}
})

minetest.register_node("yatm_machines:server", {
	description = "Server",
	groups = {cracky = 1},
	tiles = {
		"yatm_server_top.png",
		"yatm_server_bottom.png",
		"yatm_server_side.png",
		"yatm_server_side.png",
		-- "yatm_server_back.off.png",
		{
			name = "yatm_server_back.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			},
		},
		-- "yatm_server_front.off.png"
		{
			name = "yatm_server_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0
			},
		}
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, 0.3125, 0.4375}, -- InnerCore
			{-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- Rack4
			{-0.5, 0.0625, -0.5, 0.5, 0.25, 0.5}, -- Rack3
			{-0.5, -0.1875, -0.5, 0.5, 0, 0.5}, -- Rack2
			{-0.5, -0.4375, -0.5, 0.5, -0.25, 0.5}, -- Rack1
			{-0.4375, -0.4375, 0.4375, 0.0625, 0.3125, 0.5}, -- BackPanel
		}
	}
})



minetest.register_node("yatm_machines:wireless_emitter", {
	description = "Wireless Emitter",
	groups = {cracky = 1},
	tiles = {
		"yatm_wireless_emitter_top.on.png",
		"yatm_wireless_emitter_bottom.png",
		"yatm_wireless_emitter_side.on.png",
		"yatm_wireless_emitter_side.on.png",
		-- "yatm_wireless_emitter_back.on.png",
		{
			name = "yatm_wireless_emitter_back.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0
			},
		},
		-- "yatm_wireless_emitter_front.off.png"
		{
			name = "yatm_wireless_emitter_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:wireless_receiver", {
	description = "Wireless Receiver",
	groups = {cracky = 1},
	tiles = {
		"yatm_wireless_receiver_top.on.png",
		"yatm_wireless_receiver_bottom.png",
		"yatm_wireless_receiver_side.on.png",
		"yatm_wireless_receiver_side.on.png",
		--"yatm_wireless_receiver_back.on.png",
		{
			name = "yatm_wireless_receiver_back.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0
			},
		},
		-- "yatm_wireless_receiver_front.off.png",
		{
			name = "yatm_wireless_receiver_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})


minetest.register_node("yatm_machines:fluid_replicator", {
	description = "Fluid Replicator",
	groups = {cracky = 1},
	tiles = {
		"yatm_fluid_replicator_top.on.png",
		"yatm_fluid_replicator_bottom.png",
		"yatm_fluid_replicator_side.on.png",
		"yatm_fluid_replicator_side.on.png",
		-- "yatm_fluid_replicator_back.off.png",
		{
			name = "yatm_fluid_replicator_back.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0
			},
		},
		-- "yatm_fluid_replicator_front.off.png"
		{
			name = "yatm_fluid_replicator_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:item_replicator", {
	description = "Item Replicator",
	groups = {cracky = 1},
	tiles = {
		"yatm_item_replicator_top.on.png",
		"yatm_item_replicator_bottom.png",
		"yatm_item_replicator_side.on.png",
		"yatm_item_replicator_side.on.png",
		-- "yatm_item_replicator_back.off.png",
		{
			name = "yatm_item_replicator_back.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0
			},
		},
		-- "yatm_item_replicator_front.off.png"
		{
			name = "yatm_item_replicator_front.on.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
})
