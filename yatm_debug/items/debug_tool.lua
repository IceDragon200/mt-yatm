--
-- The debug tool displays information on nodes
--
local fspec = assert(foundation.com.formspec.api)
local sounds = assert(yatm.sounds)
local is_table_empty = assert(foundation.com.is_table_empty)

local function receive_fields(user, form_name, fields, assigns)
  print(dump(fields))
  return true
end

local function get_formspec(pos, user, assigns)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node_or_nil(pos)
  local nodedef
  if node then
    nodedef = minetest.registered_nodes[node.name]
  end
  local metadata_table = meta:to_table()

  local w = 16
  local h = 12

  local tabs = {"Meta"}

  --is_table_empty()

  table.insert(tabs, "Inventory")
  table.insert(tabs, "YATM Energy")
  table.insert(tabs, "YATM Thermal")
  table.insert(tabs, "YATM Fluids")
  table.insert(tabs, "YATM Items")
  table.insert(tabs, "YATM DATA")

  local formspec =
    fspec.size(w, h) ..
    fspec.formspec_version(3) ..
    fspec.tabheader(0, 0, nil, nil, "current_tab", tabs, 1, false, false) ..
    yatm.formspec_bg_for_player(user:get_player_name(), "machine") ..
    fspec.scrollbar(w-1.0, 0.5, 0.5, h-1, "vertical", "cluster_scrollbar") ..
    fspec.scroll_container(0.5, 0.5, w-2, h, "cluster_scrollbar", "vertical")

  local i = 0
  for key,value in pairs(metadata_table.fields) do
    formspec =
      formspec ..
      fspec.label(0, i, key) ..
      fspec.label(math.floor(w/4), i, tostring(value))

    i = i + 1
  end

  formspec = formspec .. fspec.scroll_container_end()

  -- TODO: display each metadata field in the formspec appropriately
  -- TODO: it should likely be scrollable
  -- TODO: it should have other tabs, for things like fluids, other interfaces etc...
  -- NOTE: this is the Almighty Debug Tool afterall

  return formspec
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
      local assigns = {
        pos = pos,
      }
      yatm_core.show_bound_formspec(user:get_player_name(), "yatm_core:debug_tool_formspec", get_formspec(pos, user, assigns), {
        state = assigns,
        on_receive_fields = receive_fields,
      })
    else
      sounds:play("action_error", { to_player = user:get_player_name() })
    end

    return itemstack
  end,
})
