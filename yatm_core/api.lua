--[[

  The public API exposed by the yatm_core

]]
local table_merge = assert(foundation.com.table_merge)
local fspec = assert(foundation.com.formspec.api)

-- @namespace yatm

-- alias foundation modules into yatm, they were originally yatm modules to begin with
-- @alias Luna = foundation.com.Luna
yatm.Luna = foundation.com.Luna
-- @alias MetaSchema = foundation.com.MetaSchema
yatm.MetaSchema = foundation.com.MetaSchema
-- @alias ByteBuf = foundation.com.ByteBuf
yatm.ByteBuf = foundation.com.ByteBuf
-- @alias BinSchema = foundation.com.BinSchema
yatm.BinSchema = foundation.com.BinSchema
-- @alias ByteDecoder = foundation.com.ByteDecoder
yatm.ByteDecoder = foundation.com.ByteDecoder
-- @alias ByteEncoder = foundation.com.ByteEncoder
yatm.ByteEncoder = foundation.com.ByteEncoder
-- @alias Vector2 = foundation.com.Vector2
yatm.Vector2 = foundation.com.Vector2
-- @alias Vector3 = foundation.com.Vector3
yatm.Vector3 = foundation.com.Vector3
-- @alias Vector4 = foundation.com.Vector4
yatm.Vector4 = foundation.com.Vector4
-- @alias Cuboid = foundation.com.Cuboid
yatm.Cuboid = foundation.com.Cuboid

local nokore_player_inv = rawget(_G, "nokore_player_inv")

--
-- @spec player_inventory_lists_fragment(player: Player, x: Number, y: Number): (String, dimensions: Vector2)

--
-- @spec player_inventory_size2(Player): Vector2

if nokore_player_inv then
  yatm.player_inventory_lists_fragment = nokore_player_inv.player_inventory_lists_fragment
  yatm.player_inventory_size2 = nokore_player_inv.player_inventory_size2

  function yatm.get_player_hotbar_size(_player)
    return nokore_player_inv.player_hotbar_size
  end
else
  function yatm.get_player_hotbar_size(_player)
    -- minetest game's default size
    return 8
  end

  function yatm.player_inventory_size2(player)
    local cols = yatm.get_player_hotbar_size(player)
    local inv = player:get_inventory()
    local main_size = inv:get_size("main")
    local rows = math.ceil(main_size / cols)
    return { x = cols, y = rows }
  end

  function yatm.player_inventory_lists_fragment(player, x, y)
    local size = yatm.player_inventory_size2(player)

    local result = ""

    result = result .. fspec.list("current_player", "main", x, y, size.x, 1)

    if size.y > 1 then
      result = result .. fspec.list("current_player", "main", x, y + 1.5, size.x, size.y - 1, size.x)
    end

    return result, { x = cols, y = rows }
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

yatm_core:require("api/wrench.lua")
yatm_core:require("api/building_blocks.lua")
yatm_core:require("api/colors.lua")
yatm_core:require("api/formspec_backgrounds.lua")
