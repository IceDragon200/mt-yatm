--
-- The Cluster Tool is a simple tool for viewing and debugging various YATM clusters.
--
local is_table_empty = assert(foundation.com.is_table_empty)
local table_keys = assert(foundation.com.table_keys)
local list_sort = assert(foundation.com.list_sort)
local cluster_tool = assert(yatm.cluster_tool)
local sounds = assert(yatm.sounds)
local fspec = assert(foundation.com.formspec.api)

local function render_formspec(user, state)
  local w = 20
  local h = 15

  local cio = fspec.calc_inventory_offset

  local formspec =
    fspec.formspec_version(6) ..
    fspec.size(w, h) ..
    yatm.formspec_bg_for_player(user:get_player_name(), "default", 0, 0, w, h)

  local headers = {}
  local keys = list_sort(table_keys(state.clusters))

  if not state.tab_index then
    state.tab_index = 1
  end

  -- for _, key in ipairs(keys) do
  --   local cluster = state.clusters[key]
  -- end

  formspec =
    formspec ..
    fspec.tabheader(0, 0, nil, 1, "tab_index", keys, state.tab_index)

  state.page = keys[state.tab_index]

  if state.page then
    formspec =
      formspec ..
      --fspec.scrollbar_options({}) ..
      fspec.scrollbar(w-1.5, 0.5, 1, h-1, "vertical", "cluster_scrollbar") ..
      fspec.scroll_container(0.5, 0.5, w-2, h, "cluster_scrollbar", "vertical")

    local func = cluster_tool.render_functions[state.page]

    if func then
      local item = state.clusters[state.page]
      formspec = func(item, formspec, { w = w - 2 })
      if not formspec then
        error("expected render function " .. state.page .. " to return a formspec")
      end
    end

    formspec =
      formspec ..
      fspec.scroll_container_end()
  end

  return formspec
end

local function on_receive_fields(user, form_name, fields, state)
  local formspec = nil
  local refresh_formspec = false

  if fields["tab_index"] then
    state.tab_index = tonumber(fields["tab_index"])
    refresh_formspec = true
  end

  if refresh_formspec then
    formspec = render_formspec(user, state)
  end

  return true, formspec
end

local function show_cluster_summary(user, clusters)
  local state = {
    clusters = clusters,
  }
  local formspec = render_formspec(user, state)
  local formspec_name = "yatm_clusters:cluster_summary"

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    formspec_name,
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields
    }
  )
end

yatm_clusters:register_tool("cluster_tool", {
  description = "YATM Cluster Debug Tool\nRight-Click any device to view associated clusters for debugging.",

  groups = {
    cluster_tool = 1,
  },

  inventory_image = "yatm_cluster_tool.png",

  on_place = function (itemstack, user, pointed_thing)
    -- get the position below the cursor
    local pos = pointed_thing.under

    if pos then
      -- iterate each cluster at the specified position
      -- the accumulator is the list of all the clusters at the position
      -- this will be used to populate a list for the formspec
      local clusters = cluster_tool.lookup_clusters(pos, {})

      if is_table_empty(clusters) then
        sounds:play("double_boop0", { to_player = user:get_player_name() })
      else
        sounds:play("action_open", { to_player = user:get_player_name() })
        show_cluster_summary(user, clusters)
      end
    else
      sounds:play("action_error", { to_player = user:get_player_name() })
    end
  end,
})
