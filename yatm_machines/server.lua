-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test

minetest.register_node("test:node_1", {
	tiles = {
		"yatm_server_top.png",
		"yatm_server_bottom.png",
		"yatm_server_side.png",
		"yatm_server_side.png",
		"yatm_server_back.off.png",
		"yatm_server_front.off.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
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

