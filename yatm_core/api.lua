--[[

  The public API exposed by the yatm_core

]]
local table_merge = assert(foundation.com.table_merge)
local fspec = assert(foundation.com.formspec.api)

-- alias foundation modules into yatm, they were originally yatm modules to begin with
yatm.Luna = foundation.com.Luna
yatm.MetaSchema = foundation.com.MetaSchema
yatm.ByteBuf = foundation.com.ByteBuf
yatm.BinSchema = foundation.com.BinSchema
yatm.ByteDecoder = foundation.com.ByteDecoder
yatm.ByteEncoder = foundation.com.ByteEncoder
yatm.Vector2 = foundation.com.Vector2
yatm.Vector3 = foundation.com.Vector3
yatm.Vector4 = foundation.com.Vector4
yatm.Cuboid = foundation.com.Cuboid

if rawget(_G, "nokore_player_inv") then
  yatm.player_inventory_lists_fragment = nokore_player_inv.player_inventory_lists_fragment

  function yatm.get_player_hotbar_size(_player)
    return nokore_player_inv.player_hotbar_size
  end
else
  function yatm.get_player_hotbar_size(_player)
    -- minetest game's default size
    return 8
  end

  function yatm.player_inventory_lists_fragment(player, x, y)
    local size = yatm.get_player_hotbar_size(player)
    local inv = player:get_inventory()

    local h = 0

    local main_size = inv:get_size("main")
    local offhand_size = main_size - size

    local result = ""

    result = result .. fspec.list("current_player", "main", x, y, size, 1)

    h = 1.25

    if offhand_size > 0 then
      local rows = math.ceil(offhand_size / size)
      result = result .. fspec.list("current_player", "main", x, h + y, size, rows, size)
      h = h + rows
    end

    return result, h
  end
end

function yatm.register_stateful_node(basename, base, states)
  local result = {}
  for name, changes in pairs(states) do
    local nodedef = table_merge(base, changes)
    nodedef.basename = nodedef.basename or basename
    local node_name = basename .. "_" .. name
    minetest.register_node(node_name, nodedef)
    result[name] = {node_name, nodedef}
  end
  return result
end

function yatm.register_stateful_tool(basename, base, states)
  local result = {}
  for name, changes in pairs(states) do
    local tooldef = table_merge(base, changes)
    tooldef.basename = tooldef.basename or basename
    local tool_name = basename .. "_" .. name
    minetest.register_tool(tool_name, tooldef)
    result[name] = {tool_name, nodedef}
  end
  return result
end

function yatm.register_stateful_craftitem(basename, base, states)
  local result = {}
  for name, changes in pairs(states) do
    local craftitemdef = table_merge(base, changes)
    craftitemdef.basename = craftitemdef.basename or basename
    local craftitem_name = basename .. "_" .. name
    minetest.register_craftitem(craftitem_name, craftitemdef)
    result[name] = {craftitem_name, nodedef}
  end
  return result
end

yatm.colors = {
  { name = "white",      description = "White" },
  { name = "grey",       description = "Grey" },
  { name = "dark_grey",  description = "Dark Grey" },
  { name = "black",      description = "Black" },
  { name = "violet",     description = "Violet" },
  { name = "blue",       description = "Blue" },
  { name = "light_blue", description = "Light Blue" },
  { name = "cyan",       description = "Cyan" },
  { name = "dark_green", description = "Dark Green" },
  { name = "green",      description = "Green" },
  { name = "yellow",     description = "Yellow" },
  { name = "brown",      description = "Brown" },
  { name = "orange",     description = "Orange" },
  { name = "red",        description = "Red" },
  { name = "magenta",    description = "Magenta" },
  { name = "pink",       description = "Pink" },
}

yatm.colors_with_default =
  foundation.com.list_concat({{name = "default", description = "Default"}}, yatm.colors)

yatm.bg = {}
yatm.bg9 = {}

yatm.bg.base =
  "no_prepend[]" ..
  "bgcolor[#080808BB;true]" ..
  "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"

local auto_clip = "true"

local bg = "background[0,0;1,1;"

yatm.bg.default = yatm.bg.base .. bg .. "yatm_gui_formbg_default.png;" .. auto_clip .. "]"
yatm.bg.computer = yatm.bg.base .. bg .. "yatm_gui_formbg_default.computer.png;" .. auto_clip .. "]"
yatm.bg.data = yatm.bg.base .. bg .. "yatm_gui_formbg_default.data.png;" .. auto_clip .. "]"
yatm.bg.codex = yatm.bg.base .. bg .. "yatm_gui_formbg_codex.png;" .. auto_clip .. "]"
yatm.bg.display = yatm.bg.base .. bg .. "yatm_gui_formbg_display.data.png;" .. auto_clip .. "]"
yatm.bg.machine = yatm.bg.base .. bg .. "yatm_gui_formbg_machine.png;" .. auto_clip .. "]"
yatm.bg.machine_heated = yatm.bg.base .. bg .. "yatm_gui_formbg_machine.heated.png;" .. auto_clip .. "]"
yatm.bg.machine_cooled = yatm.bg.base .. bg .. "yatm_gui_formbg_machine.cooled.png;" .. auto_clip .. "]"
yatm.bg.machine_radioactive = yatm.bg.base .. bg .. "yatm_gui_formbg_machine.radioactive.png;" .. auto_clip .. "]"
yatm.bg.machine_chemical = yatm.bg.base .. bg .. "yatm_gui_formbg_machine.chemical.png;" .. auto_clip .. "]"
yatm.bg.module = yatm.bg.base .. bg .. "yatm_gui_formbg_module.data.png;" .. auto_clip .. "]"
yatm.bg.other = yatm.bg.base .. bg .. "yatm_gui_formbg_other.png;" .. auto_clip .. "]"
yatm.bg.wood = yatm.bg.base .. bg .. "yatm_gui_formbg_wood.png;" .. auto_clip .. "]"
yatm.bg.cardboard = yatm.bg.base .. bg .. "yatm_gui_formbg_cardboard.png;" .. auto_clip .. "]"
yatm.bg.dscs = yatm.bg.base .. bg .. "yatm_gui_formbg_dscs.png;" .. auto_clip .. "]"

local bg9  = "background9[0,0;1,1;"

yatm.bg9.default = yatm.bg.base .. bg9 .. "yatm_gui_formbg_default.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.computer = yatm.bg.base .. bg9 .. "yatm_gui_formbg_default.computer.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.data = yatm.bg.base .. bg9 .. "yatm_gui_formbg_default.data.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.codex = yatm.bg.base .. bg9 .. "yatm_gui_formbg_codex.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.display = yatm.bg.base .. bg9 .. "yatm_gui_formbg_display.data.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.machine = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.machine_heated = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.heated.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.machine_cooled = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.cooled.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.machine_radioactive = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.radioactive.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.machine_chemical = yatm.bg.base .. bg9 .. "yatm_gui_formbg_machine.chemical.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.module = yatm.bg.base .. bg9 .. "yatm_gui_formbg_module.data.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.other = yatm.bg.base .. bg9 .. "yatm_gui_formbg_other.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.wood = yatm.bg.base .. bg9 .. "yatm_gui_formbg_wood.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.cardboard = yatm.bg.base .. bg9 .. "yatm_gui_formbg_cardboard.9s.png;" .. auto_clip .. ";32]"
yatm.bg9.dscs = yatm.bg.base .. bg9 .. "yatm_gui_formbg_dscs.9s.png;" .. auto_clip .. ";32]"

function yatm.formspec_bg_for_player(player_name, background_name)
  assert(type(player_name) == "string", "expected player_name as string")

  local info = minetest.get_player_information(player_name)

  if info.formspec_version then
    if info.formspec_version >= 2 then
      return yatm.bg9[background_name]
    end
  end

  return yatm.bg[background_name]
end
