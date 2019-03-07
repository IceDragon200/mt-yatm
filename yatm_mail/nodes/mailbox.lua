local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

colors = yatm_core.list_concat({{"default", "Default"}}, colors)

local mailbox_nodebox  = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.4375, 0.375, 0.25, 0.4375}, -- NodeBox1
    {-0.375, -0.5, -0.5, -0.3125, 0.25, -0.4375}, -- NodeBox2
    {0.3125, -0.5, -0.5, 0.375, 0.25, -0.4375}, -- NodeBox4
    {-0.3125, 0.1875, -0.5, 0.3125, 0.25, -0.4375}, -- NodeBox5
    {-0.3125, 0.1875, 0.4375, 0.3125, 0.25, 0.5}, -- NodeBox6
    {0.3125, -0.5, 0.4375, 0.375, 0.25, 0.5}, -- NodeBox7
    {-0.375, -0.5, 0.4375, -0.3125, 0.25, 0.5}, -- NodeBox8
  }
}

--[[
  return "size[8,8.5]"..
    "list[context;src;2.75,0.5;1,1;]"..
    "list[context;fuel;2.75,2.5;1,1;]"..
    "image[2.75,1.5;1,1;default_furnace_fire_bg.png^[lowpart:"..
    (100-fuel_percent)..":default_furnace_fire_fg.png]"..
    "image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
    (item_percent)..":gui_furnace_arrow_fg.png^[transformR270]"..
    "list[context;dst;4.75,0.96;2,2;]"..
    "list[current_player;main;0,4.25;8,1;]"..
    "list[current_player;main;0,5.5;8,3;8]"..
    "listring[context;dst]"..
    "listring[current_player;main]"..
    "listring[context;src]"..
    "listring[current_player;main]"..
    "listring[context;fuel]"..
    "listring[current_player;main]"..
    default.get_hotbar_bg(0, 4.25)
]]

local mailbox_form = yatm_core.UI.Form.new()
mailbox_form:set_size(8, 8.5)
mailbox_form:new_label(0, 0, "Mailbox")
mailbox_form:new_list("context", "access_key", 0, 0.5, 1, 1, "")
mailbox_form:new_list("context", "dropoff", 2, 0.5, 4, 1, "")
mailbox_form:new_list("context", "inbox", 0, 2.0, 8, 2, "")
mailbox_form:new_list("current_player", "main", 0, 4.25, 8, 1, "")
mailbox_form:new_list("current_player", "main", 0, 5.5, 8, 3, 8)
mailbox_form:new_list_ring("context", "access_key")
mailbox_form:new_list_ring("current_player", "main")
mailbox_form:new_list_ring("context", "dropoff")
mailbox_form:new_list_ring("current_player", "main")

print(mailbox_form:to_formspec())
local function mailbox_get_formspec()
  local formspec =
    default.gui_bg ..
    default.gui_bg_img ..
    default.gui_slots ..
    mailbox_form:to_formspec() ..
    default.get_hotbar_bg(0, 4.25)
  return formspec
end

local function mailbox_configure_inventory(meta)
  local inv = meta:get_inventory()

  inv:set_size("access_key", 1) -- slot used for the mailbox key, unless it's an open box
  inv:set_size("dropoff", 4) -- dropoff will just transfer it to the inbox /shrug
  inv:set_size("inbox", 16)
end

local function mailbox_configure_formspec(meta)
  meta:set_string("formspec", mailbox_get_formspec())
end

local function mailbox_on_construct(pos)
  local meta = minetest.get_meta(pos)

  mailbox_configure_formspec(meta)
  mailbox_configure_inventory(meta)
end

local function mailbox_on_destruct(pos)
end

for _,pair in ipairs(colors) do
  local basename = pair[1]
  local name = pair[2]

  local mailbox_basename = "yatm_mail:mailbox_wood_" .. basename
  minetest.register_node(mailbox_basename, {
    description = "Wood Mailbox (" .. name .. ")",
    groups = { mailbox = 1, cracky = 1 },
    tiles = {
      "yatm_mailbox_wood_" .. basename .. "_top.png",
      "yatm_mailbox_wood_" .. basename .. "_bottom.png",
      "yatm_mailbox_wood_" .. basename .. "_side.png",
      "yatm_mailbox_wood_" .. basename .. "_side.png^[transformFX",
      "yatm_mailbox_wood_" .. basename .. "_back.png",
      "yatm_mailbox_wood_" .. basename .. "_front.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = mailbox_nodebox,

    on_construct = mailbox_on_construct,
    on_destruct = mailbox_on_destruct,
  })

  local mailbox_basename = "yatm_mail:mailbox_metal_" .. basename
  minetest.register_node(mailbox_basename, {
    description = "Metal Mailbox (" .. name .. ")",
    groups = { mailbox = 1, cracky = 1 },
    tiles = {
      "yatm_mailbox_metal_" .. basename .. "_top.png",
      "yatm_mailbox_metal_" .. basename .. "_bottom.png",
      "yatm_mailbox_metal_" .. basename .. "_side.png",
      "yatm_mailbox_metal_" .. basename .. "_side.png^[transformFX",
      "yatm_mailbox_metal_" .. basename .. "_back.png",
      "yatm_mailbox_metal_" .. basename .. "_front.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = mailbox_nodebox,

    on_construct = mailbox_on_construct,
    on_destruct = mailbox_on_destruct,
  })
end
