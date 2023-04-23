local mod = assert(yatm_item_storage)

local fspec = assert(foundation.com.formspec.api)
local Directions = assert(foundation.com.Directions)
local ItemInterface = assert(yatm.items.ItemInterface)
local string_starts_with = assert(foundation.com.string_starts_with)
local string_trim_leading = assert(foundation.com.string_trim_leading)
local ItemExchange = assert(yatm.items.ItemExchange)
local Vector3 = assert(foundation.com.Vector3)

local FILTER_ROWS = 6
local IO_STATE_INPUT_ONLY = 0
local IO_STATE_OUTPUT_ONLY = 1

local INDEX_TO_DIR = {
  [1] = Directions.D_UP,
  [2] = Directions.D_SOUTH,
  [3] = Directions.D_NORTH,
  [4] = Directions.D_WEST,
  [5] = Directions.D_EAST,
  [6] = Directions.D_DOWN,
}

local DIR_TO_INDEX = {}
for idx, dir in pairs(INDEX_TO_DIR) do
  DIR_TO_INDEX[dir] = idx
end

local function directional_to_inventory_id(pos, dir)
  local node = minetest.get_node_or_nil(pos)
  if node then
    local local_dir = Directions.facedir_to_face(node.param2, dir)
    return DIR_TO_INDEX[local_dir]
  end

  return nil
end

local function allow_item_stack_with_filter(item_stack, filter_stack)
  if filter_stack:is_empty() then
    return true
  end

  return filter_stack:get_name() == item_stack:get_name()
end

local item_interface = ItemInterface.new_directional(function (self, pos, dir)
  local id = directional_to_inventory_id(pos, dir)

  if id then
    return "inv_" .. id
  end

  return nil
end)

function item_interface:allow_extract_item(pos, dir, item_stack)
  local inv_slot = directional_to_inventory_id(pos, dir)

  if inv_slot then
    local meta = minetest.get_meta(pos)

    if meta:get_int("active_"..inv_slot) > 0 then
      return true
    end
  end

  return false
end

function item_interface:allow_insert_item(pos, dir, item_stack)
  local inv_slot = directional_to_inventory_id(pos, dir)

  if inv_slot then
    local meta = minetest.get_meta(pos)

    local inv = meta:get_inventory()

    if meta:get_int("active_"..inv_slot) > 0 then
      local filter_stack = inv:get_stack("filter_" .. inv_slot, 1)

      return allow_item_stack_with_filter(item_stack, filter_stack)
    end
  end

  return false
end

local function refresh_timer(pos)
  local timer = minetest.get_node_timer(pos)

  --- 1/4 second
  timer:start(0.25)
end

local function on_timer(pos, dtime)
  local node = minetest.get_node(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local cache
  local item_name
  local filter_stack
  local stack
  local leftover
  local inv_name
  local size
  local io_state
  local is_active
  local auto_eject
  local sub_inv_name
  local sub_is_active

  local filter_map = {}
  local filter_cache = {}
  for i = 1,FILTER_ROWS do
    is_active = meta:get_int("active_"..i)
    io_state = meta:get_int("io_"..i)
    filter_stack = inv:get_stack("filter_"..i, 1)
    filter_map[i] = filter_stack
    if filter_stack:is_empty() then
      item_name = "_"
    else
      item_name = filter_stack:get_name()
    end
    filter_cache[item_name] = filter_cache[item_name] or {}
    filter_cache[item_name][i] = io_state * 2 + is_active
  end

  for i = 1,FILTER_ROWS do
    inv_name = "inv_" .. i
    is_active = meta:get_int("active_" .. i)
    io_state = meta:get_int("io_" .. i)
    size = inv:get_size(inv_name)

    if is_active > 0 then
      if io_state == IO_STATE_OUTPUT_ONLY then
        auto_eject = meta:get_int("auto_eject_" .. i)

        -- Auto-eject
        if auto_eject > 0 then
          ItemExchange.transfer_from_device_to_adjacent_device(
            pos,
            INDEX_TO_DIR[i],
            1,
            true
          )
        end
      elseif io_state == IO_STATE_INPUT_ONLY then
        for idx = 1,size do
          stack = inv:get_stack(inv_name, idx)
          if not stack:is_empty() then
            item_name = stack:get_name()

            cache = filter_cache[item_name] or filter_cache["_"]
            if cache then
              for j,flags in pairs(cache) do
                if flags == 3 then
                  -- 3 (1 active | 2 output)
                  filter_stack = filter_map[j]
                  if allow_item_stack_with_filter(stack, filter_stack) then
                    inv:set_stack(inv_name, idx, inv:add_item("inv_"..j, stack))
                  end
                end
              end
            end
          end
        end
      end
    else
      if not inv:is_empty(inv_name) and io_state == IO_STATE_OUTPUT_ONLY then
        --- The inventory is NOT empty and this side is being used as an output
        --- It should not have any items stored in it.
        --- move items to a slot that's active and outputting
        for j = 1,FILTER_ROWS do
          if j ~= i then
            sub_is_active = meta:get_int("active_" .. j)
            if sub_is_active > 0 then
              sub_inv_name = "inv_" .. j

              --- Sub slot is being used for input, items can be stored there then.
              filter_stack = filter_map[j]
              for idx = 1,size do
                stack = inv:get_stack(inv_name, idx)
                if not stack:is_empty() then
                  if allow_item_stack_with_filter(stack, filter_stack) then
                    inv:set_stack(inv_name, idx, inv:add_item(sub_inv_name, stack))
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  return true
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  for i = 1,FILTER_ROWS do
    meta:set_int("active_"..i, 0)
    meta:set_int("io_"..i, 0)
    meta:set_int("auto_eject_"..i, 0)

    inv:set_size("inv_"..i, 6)
    inv:set_size("filter_"..i, 1)
  end

  refresh_timer(pos)
end

local function render_formspec(pos, player, state)
  local spos = foundation.com.Vector3.to_string(pos)
  local meta = minetest.get_meta(pos)

  local cio = fspec.calc_inventory_offset
  local inv_name = "nodemeta:" .. spos

  return yatm.formspec.render_split_inv_panel(player, 10, FILTER_ROWS, { bg = "default" }, function (loc, rect)
    if loc == "main_body" then
      local formspec = ""
      local active_color
      local io_color
      local io_color_name
      local io_state
      local is_active
      local auto_eject
      for i = 1,FILTER_ROWS do
        is_active = meta:get_int("active_" .. i)
        io_state = meta:get_int("io_" .. i)
        auto_eject = meta:get_int("auto_eject_" .. i)
        active_color = "white"
        if is_active > 0 then
          active_color = "green"
        end
        if io_state == IO_STATE_INPUT_ONLY then
          io_color = "#0167a6" --- Blue for Insertion
          io_color_name = "blue"
        elseif io_state == IO_STATE_OUTPUT_ONLY then
          io_color = "#d1a130" --- Yellow for Extraction
          io_color_name = "yellow"
        else
          io_color = "#000000" --- Black for unknown
          io_color_name = "black"
        end

        formspec =
          formspec
          .. yatm.formspec.render_small_switch{
            x = rect.x,
            y = rect.y + cio(i - 1),
            w = 0.5,
            h = 1,
            state = is_active,
            color_name = active_color,
            name = "toggle_active_" .. i,
            label = "",
          }
          .. fspec.tooltip_element("toggle_active_"..i, "Toggle Active")
          .. fspec.image(
            rect.x + 0.5,
            rect.y + cio(i - 1),
            1,
            1,
            "yatm_filter_box_item."..i..".png"
          )
          .. fspec.list(
            inv_name,
            "inv_" .. i,
            rect.x + 0.5 + cio(1),
            rect.y + cio(i - 1),
            6,
            1
          )
          .. fspec.list(
            inv_name,
            "filter_" .. i,
            rect.x + 0.5 + cio(7.25),
            rect.y + cio(i - 1),
            1,
            1
          )
          .. fspec.image(
            rect.x + 0.5 + cio(7.25),
            rect.y + cio(i - 1),
            1,
            1,
            "yatm_item_border_die."..i..".png"
          )
          .. yatm.formspec.render_small_switch{
            x = rect.x + 0.5 + cio(8.25),
            y = rect.y + cio(i - 1),
            w = 0.5,
            h = 1,
            state = io_state,
            color_name = io_color_name,
            name = "toggle_io_" .. i,
            label = "",
          }
          .. fspec.tooltip_element("toggle_io_"..i, "Toggle IO Mode")
          .. fspec.box(
            rect.x + 1 + cio(8.25),
            rect.y + cio(i - 1),
            0.5,
            1,
            io_color
          )
          .. yatm.formspec.render_small_switch{
            x = rect.x + 1.5 + cio(8.25),
            y = rect.y + cio(i - 1),
            w = 0.5,
            h = 1,
            state = auto_eject,
            color_name = "black",
            name = "toggle_auto_eject_" .. i,
            label = "",
          }
          .. fspec.tooltip_element("toggle_auto_eject_"..i, "Toggle Auto-Eject")
      end
      return formspec
    elseif loc == "footer" then
      local formspec = ""
      for i = 1,FILTER_ROWS do
        formspec =
          formspec
          .. fspec.list_ring("current_player", "main")
          .. fspec.list_ring("current_player", "inv_"..i)
      end
      return formspec
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  local pos = state.pos
  local meta = minetest.get_meta(pos)
  local should_refresh = false
  local should_refresh_timer = false

  local idx

  for key, value in pairs(fields) do
    if string_starts_with(key, "toggle_active_") then
      idx = tonumber(string_trim_leading(key, "toggle_active_"))
      if idx >= 1 and idx <= FILTER_ROWS then
        local meta_key = "active_" .. idx
        local state = meta:get_int(meta_key)
        if state == 0 then
          state = 1
        else
          state = 0
        end
        meta:set_int(meta_key, state)
        should_refresh = true
        should_refresh_timer = true
      end
    elseif string_starts_with(key, "toggle_io_") then
      idx = tonumber(string_trim_leading(key, "toggle_io_"))
      if idx >= 1 and idx <= FILTER_ROWS then
        local meta_key = "io_" .. idx
        local state = meta:get_int(meta_key)
        if state == IO_STATE_OUTPUT_ONLY then
          state = IO_STATE_INPUT_ONLY
        else
          state = IO_STATE_OUTPUT_ONLY
        end
        meta:set_int(meta_key, state)
        should_refresh = true
        should_refresh_timer = true
      end
    elseif string_starts_with(key, "toggle_auto_eject_") then
      idx = tonumber(string_trim_leading(key, "toggle_auto_eject_"))
      if idx >= 1 and idx <= FILTER_ROWS then
        local meta_key = "auto_eject_" .. idx
        local state = meta:get_int(meta_key)
        if state == 0 then
          state = 1
        else
          state = 0
        end
        meta:set_int(meta_key, state)
        should_refresh = true
        should_refresh_timer = true
      end
    end
  end

  if should_refresh_timer then
    refresh_timer(pos)
  end

  if should_refresh then
    return false, render_formspec(pos, player, state)
  else
    return false, nil
  end
end

local function on_rightclick(pos, node, player)
  local formspec_name =
    mod:make_name("item_filter_box") .. ":" .. minetest.pos_to_string(pos)

  local meta = minetest.get_meta(pos)

  local state = {
    pos = pos,
    node = node,
  }
  local formspec = render_formspec(pos, player, state)

  nokore.formspec_bindings:show_formspec(
    player:get_player_name(),
    formspec_name,
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
    }
  )
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
  if string_starts_with(listname, "filter_") then
    return 1
  end

  return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
  if string_starts_with(listname, "filter_") then
    return 1
  end

  return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  if string_starts_with(from_list, "filter_") or string_starts_with(to_list, "filter_") then
    return 1
  end

  return count
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
  refresh_timer(pos)
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
  refresh_timer(pos)
end

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  refresh_timer(pos)
end

mod:register_node("item_filter_box", {
  description = mod.S("Item Filter Box"),

  groups = {
    cracky = nokore.dig_class("wme"),
    item_interface_out = 1,
    item_interface_in = 1,
  },

  paramtype2 = "facedir",

  tiles = {
    "yatm_filter_box_item.1.png", -- +Y
    "yatm_filter_box_item.6.png", -- -Y
    "yatm_filter_box_item.5.png", -- +X
    "yatm_filter_box_item.4.png", -- -X
    "yatm_filter_box_item.3.png", -- +Z
    "yatm_filter_box_item.2.png", -- -Z
  },

  item_interface = item_interface,

  on_construct = on_construct,
  on_timer = on_timer,

  on_rightclick = on_rightclick,

  allow_metadata_inventory_put = allow_metadata_inventory_put,
  allow_metadata_inventory_take = allow_metadata_inventory_take,
  allow_metadata_inventory_move = allow_metadata_inventory_move,

  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,
  on_metadata_inventory_move = on_metadata_inventory_move,
})
