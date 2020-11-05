local sounds = assert(yatm.sounds)
local Groups = assert(foundation.com.Groups)
local data_network = assert(yatm.data_network)
local fspec = assert(foundation.com.formspec.api)
local Rect = assert(foundation.com.Rect)
local is_table_empty = assert(foundation.com.is_table_empty)

local function render_component(row, rect, pos, player, pointed_thing, assigns)
  if row.component == "io_ports" then
    local options = {
      x = rect.x,
      y = rect.y,
      width = rect.w,
    }

    local meta = minetest.get_meta(pos)

    local formspec, r = yatm_data_logic.get_io_port_formspec(pos, meta, row.mode, options)

    r.x = rect.x
    r.w = rect.w
    r.h = rect.h - r.h

    return formspec, r
  elseif row.component == "row" then
    local count = #row.items

    local r = Rect.copy(rect)

    local y = r.y
    r.w = r.w / count

    local formspec = ""
    for index, item in ipairs(row.items) do
      r.x = rect.x + r.w * (index - 1)
      local frag, new_r =
        render_component(item, r, pos, player, pointed_thing, assigns)

      if new_r and new_r.y > y then
        y = r.y
      end
      formspec = formspec .. frag
    end

    r.x = rect.x
    r.y = y
    r.w = rect.w
    r.h = rect.h - r.y - rect.y

    return formspec, r
  elseif row.component == "field" then
    local r = Rect.copy(rect)

    local value = ""

    if row.meta then
      local meta = minetest.get_meta(pos)
      if row.type == "integer" then
        value = tostring(meta:get_int(row.name))
      else
        value = meta:get_string(row.name)
      end
    end

    local formspec =
      fspec.field_area(r.x, r.y, r.w, 1,
                       row.name,
                       row.label or row.name,
                       minetest.formspec_escape(value))

    r.y = r.y + 1
    r.h = r.h - 1

    return formspec, r
  else
    error("unexpected component " .. row.component)
  end
end

local function render_tab(tab, rect, pos, player, pointed_thing, assigns)
  local formspec = ""

  local r = Rect.copy(rect)

  if tab.header then
    formspec =
      formspec ..
      fspec.label(r.x, r.y, tab.header)

    r.y = r.y + 0.5
    r.h = r.h - 0.5
  end

  local t = type(tab.render)
  if t == "function" then
    local frag, new_r = tab.render(r, pos, player, pointed_thing, assigns)
    if new_r then
      r = new_r
    end
    formspec = formspec .. frag
  elseif t == "table" then
    for _, row in ipairs(tab.render) do
      local frag, new_r = render_component(row, r, pos, player, pointed_thing, assigns)
      if new_r then
        r = new_r
      end
      formspec = formspec .. frag
    end
  else
    error("expected tab.render to be either table or function")
  end

  return formspec
end

local function render_table_formspec(spec, pos, player, pointed_thing, assigns)
  local default_tab_name = spec.default_tab

  local formspec =
    yatm_data_logic.layout_formspec()

  -- check tab_index has already been initialized
  if not assigns.tab_index and default_tab_name then
    for tab_index, tab in ipairs(spec.tabs) do
      -- match the tab_id to the default_tab_name
      if tab.tab_id == default_tab_name then
        assigns.tab_index = tab_index
        break
      end
    end
  end

  -- if not, default to the first tab
  if not assigns.tab_index then
    assigns.tab_index = 1
  end

  -- retrieve the tab by index
  local tab = spec.tabs[assigns.tab_index]

  if tab then
    -- a tab is present, use its background if available
    formspec =
      formspec ..
      yatm.formspec_bg_for_player(player:get_player_name(), tab.bg or "module")
  else
    -- TODO: return an error form
    -- no tab was present, default to the module background
    formspec =
      formspec .. yatm.formspec_bg_for_player(player:get_player_name(), "module")
  end

  -- check if there are multiple tabs available
  if #spec.tabs > 1 then
    local tab_titles = {}

    for _, tab in ipairs(spec.tabs) do
      table.insert(tab_titles, tab.title or tab.header or tab.tab_id)
    end

    formspec =
      formspec ..
      fspec.tabheader(0, 0, nil, 1, "tab_index", tab_titles, assigns.tab_index)
  end

  if tab then
    local s = yatm_data_logic.FORMSPEC_SIZE
    formspec = formspec .. render_tab(tab, Rect.new(0.5, 0.75, s.w - 1, s.h - 1.5),
                                           pos, player, pointed_thing, assigns)
  end

  return formspec
end

local function get_programmer_formspec(di, pos, player, pointed_thing, assigns)
  local t = type(di.get_programmer_formspec)
  if t == "function" then
    return di:get_programmer_formspec(pos, player, pointed_thing, assigns)
  elseif t == "table" then
    -- data interface formspecs are normally tabbed
    return render_table_formspec(di.get_programmer_formspec, pos, player, pointed_thing, assigns)
  else
    error("expected get_programmer_formspec on data interface to be table or function")
  end
end

local function on_receive_fields(player, form_name, fields, assigns)
  local di = assigns.interface

  local keep_bubbling, formspec_or_refresh

  local t = type(di.receive_programmer_fields)
  if t == "function" then
    keep_bubbling, formspec_or_refresh =
      di:receive_programmer_fields(player, form_name, fields, assigns)
  elseif t == "table" then
    local meta = minetest.get_meta(assigns.pos)

    local spec = di.receive_programmer_fields

    if spec.tabbed then
      if fields["tab_index"] then
        local tab_index = tonumber(fields["tab_index"])
        if tab_index ~= assigns.tab_index then
          assigns.tab_index = tab_index
          formspec_or_refresh = true
        end
      end
    end

    if spec.tabs then
      local tab = spec.tabs[assigns.tab_index]
      if tab then
        for _, component in ipairs(tab.components) do
          if component.component == "io_ports" then
            local ichg, ochg =
              yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, component.mode)

            if ichg and not is_table_empty(ichg) then
              formspec_or_refresh = true
            end

            if ochg and not is_table_empty(ochg) then
              formspec_or_refresh = true
            end
          elseif component.component == "field" then
            local value = fields[component.name]
            if value then
              if component.meta then
                if component.type == "integer" then
                  meta:set_int(component.name, tonumber(value))
                else
                  meta:set_string(component.name, value)
                end
              end
            end
          end
        end
      end
    end
  end

  local formspec = formspec_or_refresh

  if type(formspec_or_refresh) == "boolean" and formspec_or_refresh then
    formspec = get_programmer_formspec(di, assigns.pos, player, assigns.pointed_thing, assigns)
  end

  if fields.quit then
    sounds:play("action_close", { to_player = player:get_player_name() })
  end

  return keep_bubbling, formspec
end

local function on_formspec_quit(player, form_name, assigns)
  local di = assigns.interface

  if di.on_programmer_formspec_quit then
    di:on_programmer_formspec_quit(assigns.pos, player, assigns)
  end
end

minetest.register_tool("yatm_data_logic:data_programmer", {
  description = "Data Programmer\nRight-click on programmable DATA device.",

  groups = {
    data_programmer = 1,
  },

  inventory_image = "yatm_data_programmer.png",

  on_place = function (itemstack, user, pointed_thing)
    local pos = pointed_thing.under
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if Groups.get_item(nodedef, "data_programmable") then
        local di = data_network:get_data_interface(pos)
        if di then
          local formname = "yatm_data_logic:programmer:" .. minetest.pos_to_string(pos)
          local assigns = {
            pos = pos,
            node = node,
            interface = di,
            formname = formname,
            pointed_thing = pointed_thing,
          }
          local formspec = get_programmer_formspec(di, pos, user, pointed_thing, assigns)

          sounds:play("action_open", { to_player = user:get_player_name() })

          yatm_core.show_bound_formspec(user:get_player_name(), formname, formspec, {
            state = assigns,
            on_receive_fields = on_receive_fields,
            on_quit = on_formspec_quit,
          })
        else
          minetest.chat_send_player(user:get_player_name(), "This node cannot be programmed")
        end
        -- TODO: determine data configuration and display programming interface
        minetest.log("action", user:get_player_name() .. " readies to program " .. node.name)
      end
    end
  end,
})
