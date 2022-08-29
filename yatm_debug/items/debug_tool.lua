--
-- The debug tool displays information on nodes
--
local fspec = assert(foundation.com.formspec.api)
local sounds = assert(yatm.sounds)
local is_table_empty = assert(foundation.com.is_table_empty)
local string_split = assert(foundation.com.string_split)
local string_starts_with = assert(foundation.com.string_starts_with)
local list_sort = assert(foundation.com.list_sort)
local table_keys = assert(foundation.com.table_keys)

local function render_formspec(pos, user, state)
  state.tab = state.tab or 1

  local meta = minetest.get_meta(pos)
  local node = minetest.get_node_or_nil(pos)
  local nodedef
  if node then
    nodedef = minetest.registered_nodes[node.name]
  end

  local w = 16
  local h = 12

  local tabs = {}

  --is_table_empty()

  table.insert(tabs, "Meta")
  table.insert(tabs, "Inventory")
  -- table.insert(tabs, "YATM Energy")
  -- table.insert(tabs, "YATM Thermal")
  -- table.insert(tabs, "YATM Fluids")
  -- table.insert(tabs, "YATM Items")
  -- table.insert(tabs, "YATM DATA")

  local formspec =
    fspec.formspec_version(6) ..
    fspec.size(w, h) ..
    fspec.tabheader(0, 0, nil, nil, "current_tab", tabs, state.tab, false, false) ..
    yatm.formspec_bg_for_player(user:get_player_name(), "machine", 0, 0, w, h) ..
    fspec.scrollbar(w-1.0, 0.5, 0.5, h-1, "vertical", "cluster_scrollbar") ..
    fspec.scroll_container(0.5, 0.5, w-2, h, "cluster_scrollbar", "vertical")

  local current_tab = tabs[state.tab]

  local metadata_table = meta:to_table()

  if current_tab == "Meta" then
    local i = 0
    local keys = list_sort(table_keys(metadata_table.fields))

    for _,key in ipairs(keys) do
      local value = metadata_table.fields[key]
      local rows = string_split(tostring(value), "\n")

      formspec =
        formspec ..
        fspec.button(0, i, 1, 1, "delete_meta_" .. key, "X") ..
        fspec.label(1.5, 0.5 + i, key)

      for _, line in ipairs(rows) do
        formspec =
          formspec ..
          fspec.label(0.5 + math.floor(w/4), 0.5 + i, tostring(line))

        i = i + 1
      end
    end
  elseif current_tab == "Inventory" then
    local inv = meta:get_inventory()

    if metadata_table.inventory then
      local i = 0
      for name, _ in pairs(metadata_table.inventory) do
        formspec =
          formspec ..
          fspec.label(0, i, name)

        i = i + 1
      end
    end
  end

  formspec = formspec .. fspec.scroll_container_end()

  -- TODO: display each metadata field in the formspec appropriately
  -- TODO: it should likely be scrollable
  -- TODO: it should have other tabs, for things like fluids, other interfaces etc...
  -- NOTE: this is the Almighty Debug Tool afterall

  return formspec
end

local function on_receive_fields(user, form_name, fields, state)
  local needs_refresh = false

  local meta = minetest.get_meta(state.pos)

  for key, value in pairs(fields) do
    if key == "current_tab" then
      state.tab = tonumber(fields["current_tab"])
      needs_refresh = true
    elseif string_starts_with(key, "delete_meta_") then
      meta:set_string(string.sub(key, 13), "")
      needs_refresh = true
    end
  end

  if needs_refresh then
    return true, render_formspec(state.pos, user, state)
  else
    return true
  end
end

yatm_debug:register_tool("debug_tool", {
  description = "YADT\nYATM Almighty Debug Thing, err I mean Tool.",

  groups = {
    debug_tool = 1,
  },

  inventory_image = "yatm_debug_tool.png",

  on_place = function (itemstack, user, pointed_thing)
    -- get the position below the cursor
    local pos = pointed_thing.under

    if pos then
      -- iterate each cluster at the specified position
      -- the accumulator is the list of all the clusters at the position
      -- this will be used to populate a list for the formspec
      sounds:play("action_open", { to_player = user:get_player_name() })
      local node = minetest.get_node_or_nil(pos)
      local state = {
        pos = pos,
        node = node,
      }
      nokore.formspec_bindings:show_formspec(
        user:get_player_name(),
        "yatm_core:debug_tool_formspec",
        render_formspec(pos, user, state),
        {
          state = state,
          on_receive_fields = on_receive_fields,
        }
      )
    else
      sounds:play("action_error", { to_player = user:get_player_name() })
    end

    return itemstack
  end,
})
