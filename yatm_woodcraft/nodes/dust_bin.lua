--
-- Dust bins attach to any sawmill, or milling tool and collects the fallen dust
--
-- For now it only connects to the sawmill
local ItemInterface = assert(yatm.items.ItemInterface)
local ItemDevice = assert(yatm.items.ItemDevice)

local dust_bin_item_interface = ItemInterface.new_simple("main")

function dust_bin_item_interface:allow_insert_item(pos, dir, item_stack)
  local def = item_stack:get_definition()
  return yatm_core.groups.has_group(def, "dust")
end

function dust_bin_item_interface:on_insert_item(pos, dir, item_stack)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  if not inv:is_empty("main") then
    local node = minetest.get_node(pos)
    local new_name = "yatm_woodcraft:dust_bin_sawdust"
    if new_name ~= node.name then
      node.name = new_name
      minetest.swap_node(pos, node)
    end
  end
end

function dust_bin_item_interface:on_extract_item(pos, dir, count_or_item_stack)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  if inv:is_empty("main") then
    local node = minetest.get_node(pos)
    local new_name = "yatm_woodcraft:dust_bin_empty"
    if new_name ~= node.name then
      node.name = new_name
      minetest.swap_node(pos, node)
    end
  end
end

local function dust_bin_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  inv:set_size("main", 9)
end

local function dust_bin_on_rightclick(pos, node, clicker, item_stack, _pointed_thing)
  if item_stack:is_empty() then
    -- extract any item from self, we don't care, just give us something
    local saw_dust = ItemDevice.extract_item(pos, yatm_core.D_UP, 1, true)
    if saw_dust then
      clicker:get_inventory():add_item("main", saw_dust)
    end
  else
    -- But if you have something in hand
    local def = item_stack:get_definition()
    if yatm_core.groups.has_group(def, "dust") then
      -- It's dust, we can place it in the bin
      local stack = item_stack:peek_item(1)
      local remaining = ItemDevice.insert_item(pos, yatm_core.D_UP, stack, true)
      if remaining and remaining:is_empty() then
        item_stack:take_item(1)
      end
    end
  end
end

local groups = {
  cracky = 1,
  dust_bin = 1, -- so neighbour nodes what it is.
  item_interface_in = 1, -- in just for the bins
  item_interface_out = 1,
}

yatm.register_stateful_node("yatm_woodcraft:dust_bin", {
  basename = "yatm_woodcraft:dust_bin",

  description = "Dust Bin",

  groups = groups,

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",

  item_interface = dust_bin_item_interface,

  on_construct = dust_bin_on_construct,
  on_rightclick = dust_bin_on_rightclick,
}, {
  empty = {
    groups = yatm_core.table_merge(groups, { empty_dust_bin = 1 }),

    tiles = {
      "yatm_dust_bin_top.png",
      "yatm_dust_bin_bottom.png",
      "yatm_dust_bin_side.png",
      "yatm_dust_bin_side.png^[transformFX",
      "yatm_dust_bin_back.png",
      "yatm_dust_bin_front.png",
    },

    node_box = {
      type = "fixed",
      fixed = {
        yatm_core.Cuboid:new( 0,  0,  0, 16, 16,  2):fast_node_box(),
        yatm_core.Cuboid:new( 0,  0,  0,  2, 16, 16):fast_node_box(),
        yatm_core.Cuboid:new( 0,  0, 14, 16, 16,  2):fast_node_box(),
        yatm_core.Cuboid:new(14,  0,  0,  2, 16, 16):fast_node_box(),

        yatm_core.Cuboid:new( 2,  0,  2, 12,  1, 12):fast_node_box(),
      },
    },
  },

  sawdust = {
    groups = yatm_core.table_merge(groups, { not_in_creative_inventory = 1 }),

    tiles = {
      "yatm_dust_bin_top.png^(yatm_sawdust_base.png^[mask:yatm_dust_bin_top.mask.png)",
      "yatm_dust_bin_bottom.png",
      "yatm_dust_bin_side.png",
      "yatm_dust_bin_side.png^[transformFX",
      "yatm_dust_bin_back.png",
      "yatm_dust_bin_front.png",
    },

    node_box = {
      type = "fixed",
      fixed = {
        yatm_core.Cuboid:new( 0,  0,  0, 16, 16,  2):fast_node_box(),
        yatm_core.Cuboid:new( 0,  0,  0,  2, 16, 16):fast_node_box(),
        yatm_core.Cuboid:new( 0,  0, 14, 16, 16,  2):fast_node_box(),
        yatm_core.Cuboid:new(14,  0,  0,  2, 16, 16):fast_node_box(),

        yatm_core.Cuboid:new( 2,  0,  2, 12, 14, 12):fast_node_box(),
      },
    },
  }
})
