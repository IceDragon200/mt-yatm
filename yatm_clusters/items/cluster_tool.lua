local is_table_empty = assert(foundation.com.is_table_empty)
local cluster_tool = assert(yatm.cluster_tool)
local sounds = assert(yatm.sounds)
local fspec = assert(foundation.com.formspec.api)

local function get_cluster_summary_formspec(user, assigns)
  local w = 20
  local h = 15
  local formspec =
    "formspec_version[3]" ..
    fspec.size(w, h) ..
    yatm.formspec_bg_for_player(user:get_player_name(), "default")

  if not assigns.page then
    local page_key = next(assigns.state)
    assigns.page = page_key
  end

  if assigns.page then
    formspec =
      formspec ..
      "scrollbaroptions[]" ..
      fspec.scrollbar(w-1.5, 0.5, 1, h-1, "vertical", "cluster_scrollbar") ..
      fspec.scroll_container(0.5, 0.5, w-2, h, "cluster_scrollbar", "vertical")

    local func = cluster_tool.render_functions[assigns.page]

    if func then
      local item = assigns.state[assigns.page]
      formspec = func(item, formspec, { w = w - 2 })
      if not formspec then
        error("expected render function " .. assigns.page .. " to return a formspec")
      end
    end

    formspec = formspec .. fspec.scroll_container_end()
  end

  return formspec
end

local function receive_cluster_summary_fields(user, form_name, fields, assigns)
  local formspec = false
  --formspec = get_cluster_summary_formspec(user, assigns)
  return true, formspec
end

local function show_cluster_summary(user, state)
  local assigns = {
    state = state,
  }
  local formspec = get_cluster_summary_formspec(user, assigns)
  local formspec_name = "yatm_clusters:cluster_summary"

  yatm_core.show_bound_formspec(user:get_player_name(), formspec_name, formspec, {
    state = assigns,
    on_receive_fields = receive_cluster_summary_fields
  })
end

yatm_clusters:register_tool("cluster_tool", {
  description = "YATM Cluster Tool\nRight-Click any device to view associated clusters.",

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
      local state = cluster_tool.lookup_clusters(pos, {})

      if is_table_empty(state) then
        sounds:play("double_boop0", { to_player = user:get_player_name() })
      else
        sounds:play("action_open", { to_player = user:get_player_name() })
        show_cluster_summary(user, state)
      end
    else
      sounds:play("action_error", { to_player = user:get_player_name() })
    end
  end,
})
