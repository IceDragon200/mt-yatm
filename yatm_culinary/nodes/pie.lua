local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local function pie_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef.pie_stage > 1 then
    -- TODO: add a pie slice to clicker's inventory
    node.name = "yatm_culinary:pie_" .. (nodedef.pie_stage - 1)

    minetest.swap_node(pos, node)
  else
    minetest.remove_node(pos)
  end
end

local pie_node_box = {
  type = "fixed",
  fixed = {
    ng( 2, 0,  2,  12, 5, 12),
    ng( 1, 3,  1,  14, 1, 14),
  }
}

minetest.register_node("yatm_culinary:pie_8", {
  codex_entry_id = "yatm_culinary:pie",

  basename = "yatm_culinary:pie",

  description = "Pie",

  groups = {
    cracky = 1,
  },

  tiles = {
    "yatm_pie_top.png",
    "yatm_pie_bottom.png",
    "yatm_pie_side.png",
    "yatm_pie_side.png",
    "yatm_pie_side.png",
    "yatm_pie_side.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = pie_node_box,

  pie_stage = 8,
  on_rightclick = pie_on_rightclick,
})

for i = 1,7 do
  local sliced_pie_node_box = {
    type = "fixed",
    fixed = {
      ng( 2, 0,  2,  12 * i / 8, 5, 12),
      ng( 1, 3,  1,  13 * i / 8, 1, 14),
    }
  }

  minetest.register_node("yatm_culinary:pie_" .. i, {
    codex_entry_id = "yatm_culinary:pie",

    basename = "yatm_culinary:pie",

    description = "Pie",

    groups = {
      cracky = 1,
      not_in_creative_inventory = 1,
    },

    tiles = {
      "yatm_pie_top.png",
      "yatm_pie_bottom.png",
      "yatm_pie_side.cut.png",
      "yatm_pie_side.png",
      "yatm_pie_side.png",
      "yatm_pie_side.png"
    },

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = sliced_pie_node_box,

    pie_stage = i,
    on_rightclick = pie_on_rightclick,
  })
end
