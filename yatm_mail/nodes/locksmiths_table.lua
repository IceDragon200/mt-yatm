local table_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
    {-0.4375, -0.5, -0.4375, -0.1875, 0.3125, -0.1875}, -- NodeBox2
    {0.1875, -0.5, -0.4375, 0.4375, 0.3125, -0.1875}, -- NodeBox3
    {0.1875, -0.5, 0.1875, 0.4375, 0.3125, 0.4375}, -- NodeBox4
    {-0.4375, -0.5, 0.1875, -0.1875, 0.3125, 0.4375}, -- NodeBox5
  }
}

local locksmiths_table_form = yatm_core.UI.Form.new()
locksmiths_table_form:set_size(8, 8.5)
locksmiths_table_form:new_label(0, 0, "Locksmith's Table")
locksmiths_table_form:new_label(0, 0.5, "Lock Installation")
locksmiths_table_form:new_list("context", "item_lockable", 0, 1.0, 1, 1, "")
locksmiths_table_form:new_list("context", "item_lock", 1, 1.0, 1, 1, "")
locksmiths_table_form:new_list("context", "item_key", 2, 1.0, 1, 1, "")
locksmiths_table_form:new_label(0, 2.5, "Key Duplication")
locksmiths_table_form:new_list("context", "item_dupkey_src", 0, 3.0, 1, 1, "")
locksmiths_table_form:new_list("context", "item_dupkey_dest", 1, 3.0, 1, 1, "")
locksmiths_table_form:new_list("context", "item_result", 7, 1.5, 1, 2, "")
locksmiths_table_form:new_list("current_player", "main", 0, 4.25, 8, 1, "")
locksmiths_table_form:new_list("current_player", "main", 0, 5.5, 8, 3, 8)
locksmiths_table_form:new_list_ring("context", "item_lockable")
locksmiths_table_form:new_list_ring("current_player", "main")
locksmiths_table_form:new_list_ring("context", "item_lock")
locksmiths_table_form:new_list_ring("current_player", "main")
locksmiths_table_form:new_list_ring("context", "item_key")
locksmiths_table_form:new_list_ring("current_player", "main")
locksmiths_table_form:new_list_ring("context", "item_dupkey")
locksmiths_table_form:new_list_ring("current_player", "main")
locksmiths_table_form:new_list_ring("context", "item_result")
locksmiths_table_form:new_list_ring("current_player", "main")

local function locksmiths_table_get_formspec()
  local formspec =
    default.gui_bg ..
    default.gui_bg_img ..
    default.gui_slots ..
    locksmiths_table_form:to_formspec() ..
    default.get_hotbar_bg(0, 4.25)
  return formspec
end

local function locksmiths_table_configure_inventory(meta)
  local inv = meta:get_inventory()
  inv:set_size("item_lockable", 1) -- slot used for placing a 'lockable' item
  inv:set_size("item_lock", 1) -- slot used for the lock
  inv:set_size("item_key", 1) -- slot used for the key to match with the lock
  inv:set_size("item_dupkey_src", 1) -- slot used for duplicating keys (the source)
  inv:set_size("item_dupkey_dest", 1) -- slot used for duplicating keys (the key to copy to)
  inv:set_size("item_result", 2) -- slots used to output the result
end

local function locksmiths_table_initialize_formspec(meta)
  meta:set_string("formspec", locksmiths_table_get_formspec())
end

local function locksmiths_table_on_construct(pos)
  local meta = minetest.get_meta(pos)

  locksmiths_table_configure_inventory(meta)
  locksmiths_table_initialize_formspec(meta)
end

local function locksmiths_table_on_destruct(pos)
end

minetest.register_node("yatm_mail:locksmiths_table_wood", {
  description = "Wood Locksmiths Table",
  groups = { locksmiths_table = 1, cracky = 1 },
  tiles = {
    "yatm_locksmiths_table_wood_top.png",
    "yatm_locksmiths_table_wood_bottom.png",
    "yatm_locksmiths_table_wood_side.png",
    "yatm_locksmiths_table_wood_side.png^[transformFX",
    "yatm_locksmiths_table_wood_side.png^[transformFX",
    "yatm_locksmiths_table_wood_side.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = table_nodebox,

  sounds = default.node_sound_wood_defaults(),

  on_construct = locksmiths_table_on_construct,
  on_destruct = locksmiths_table_on_destruct,
})
