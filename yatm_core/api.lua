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

local nokore_player_inv = rawget(_G, "nokore_player_inv")
if nokore_player_inv then
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
    result[name] = {tool_name, tooldef}
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
    result[name] = {craftitem_name, craftitemdef}
  end
  return result
end

yatm_core:require("api/building_blocks.lua")
yatm_core:require("api/colors.lua")
yatm_core:require("api/formspec_backgrounds.lua")
