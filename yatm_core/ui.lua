--
-- Utility module for dealing with formspecs, or rather to not deal with them.
--
-- I don't particularly enjoy messing with strings all day you know.
--
local iodata_to_string = assert(foundation.com.iodata_to_string)
local string_starts_with = assert(foundation.com.string_starts_with)
local table_intersperse = assert(foundation.com.table_intersperse)

local Form = foundation.com.Class:extends("yatm.Form")

local c = Form.instance_class

-- @spec c:initialize(kind :: "form" | "container")
function c:initialize(kind)
  self.kind = kind or "form"
  self.name = ""
  self.size = { w = 0, h = 0, fixed_size = nil }
  self.position = { x = 0.5, y = 0.5 }
  self.anchor = { x = 0.5, y = 0.5 }
  self.no_prepend = false
  self.starting_item_index = nil
  self.elements = {}
  self.fullscreen_background = false
  self.colors = {
    background = nil,
    font = nil,
  }
  self.slot_colors = {
    normal = nil,
    hover = nil,
    border = nil,
  }
  self.tooltip_colors = {
    background = nil,
    font = nil,
  }
end

function c:set_size(w, h, fixed_size)
  self.size = { w = w, h = h, fixed_size = fixed_size }
  return self
end

function c:set_position(x, y)
  self.position = { x = x or self.position.x, y = y or self.position.y }
  return self
end

function c:set_anchor(x, y)
  self.anchor = { x = x or self.anchor.x, y = y or self.anchor.y }
  return self
end

function c:set_no_prepend(bool)
  self.no_prepend = bool
  return self
end

function c:new_element(kind)
  local element = Form:new(kind)
  table.insert(self.elements, element)
  return element
end

function c:new_container(x, y)
  local container = self:new_element("container")
  container:set_position(x or 0, y or 0)
  return container
end

function c:build_container(x, y, cb)
  local container = self:new_container(x, y)
  cb(container)
  return self
end

function c:new_list(inventory_location, list_name, x, y, w, h, starting_item_index)
  local list = self:new_element("list")
  list.inventory_location = inventory_location
  list.list_name = list_name
  list:set_position(x, y)
  list:set_size(w, h)
  list.starting_item_index = starting_item_index
  return list
end

function c:build_list(inventory_location, list_name, x, y, w, h, start_item_index, cb)
  local list = self:new_list(inventory_location, list_name, x, y, w, h, start_item_index)
  if cb then
    cb(list)
  end
  return self
end

function c:new_list_ring(inventory_location, name)
  local list_ring = self:new_element("list_ring")
  list_ring.inventory_location = inventory_location
  list_ring.list_name = name
  return list_ring
end

function c:new_list_colors(normal_color, hover_color, border_color)
  local list_colors = self:new_element("list_colors")
  list_colors.slot_colors.normal = normal_color
  list_colors.slot_colors.hover = hover_color
  list_colors.slot_colors.border = border_color
  return list_colors
end

function c:build_list_ring(inventory_location, list_name, cb)
  local list_ring = self:new_list_ring(inventory_location, list_name)
  if cb then
    cb(list_ring)
  end
  return self
end

function c:new_element_tooltip(element_name, text, bg_color, font_color)
  local tooltip = self:new_element("element_tooltip")
  tooltip.element_name = element_name
  tooltip.text = text
  tooltip.colors.background = bg_color
  tooltip.colors.font = font_color
  return tooltip
end

function c:new_tooltip(x, y, w, h, text, bg_color, font_color)
  local tooltip = self:new_element("tooltip")
  tooltip:set_position(x, y)
  tooltip:set_size(w, h)
  tooltip.text = text
  tooltip.colors.background = bg_color
  tooltip.colors.font = font_color
  return tooltip
end

function c:new_image(x, y, w, h, texture_name)
  local image = self:new_element("image")
  image:set_position(x, y)
  image:set_size(w, h)
  image.texture_name = texture_name
  return image
end

function c:new_item_image(x, y, w, h, item_name)
  local image = self:new_element("item_image")
  image:set_position(x, y)
  image:set_size(w, h)
  image.item_name = item_name
  return image
end

function c:set_background_color(color, fullscreen)
  self.use_background_color = true
  self.colors.background = color
  self.fullscreen_background = fullscreen or false
  return self
end

function c:new_background_image(x, y, w, h, texture_name, auto_clip)
  local background = self:new_element("background")
  background:set_position(x, y)
  background:set_size(w, h)
  background.texture_name = texture_name
  background.auto_clip = auto_clip
  return background
end

function c:new_password_field(x, y, w, h, name, label)
  local password = self:new_element("password_field")
  password:set_position(x, y)
  password:set_size(w, h)
  password.name = name
  password.label = label
  return password
end

function c:new_positioned_text_field(x, y, w, h, name, label, default)
  local text = self:new_element("positioned_text_field")
  text:set_position(x, y)
  text:set_size(w, h)
  text.name = name
  text.label = label
  text.default = default
  return text
end

function c:new_text_field(name, label, default)
  local text = self:new_element("text_field")
  text.name = name
  text.label = label
  text.default = default
  return text
end

function c:field_close_on_enter(name, close_on_enter)
  local fcoe = self:new_element("field_close_on_enter")
  fcoe.name = name
  fcoe.close_on_enter = close_on_enter
  return fcoe
end

function c:new_textarea(x, y, w, h, name, label, default)
  local textarea = self:new_element("textarea")
  textarea:set_position(x, y)
  textarea:set_size(w, h)
  textarea.name = name
  textarea.label = label
  textarea.default = default
  return textarea
end

function c:new_label(x, y, label)
  local element = self:new_element("label")
  element:set_position(x, y)
  element.label = label
  return label
end

function c:new_vertical_label(x, y, label)
  local label = self:new_element("vertical_label")
  label:set_position(x, y)
  label.label = label
  return label
end

function c:new_button(x, y, w, h, name, label)
  local button = self:new_element("button")
  button:set_position(x, y)
  button:set_size(w, h)
  button.name = name
  button.label = label
  return button
end

function c:new_image_button(x, y, w, h, texture_name, name, label, no_clip, draw_border, pressed_texture_name)
  local button = self:new_element("image_button")
  button:set_position(x, y)
  button:set_size(w, h)
  button.texture_name = texture_name
  button.name = name
  button.label = label
  -- optionals
  button.no_clip = no_clip or false
  button.draw_border = draw_border
  button.pressed_texture_name = pressed_texture_name
  return button
end

function c:new_item_image_button(x, y, w, h, item_name, name, label)
  local button = self:new_element("item_image_button")
  button:set_position(x, y)
  button:set_size(w, h)
  button.item_name = item_name
  button.name = name
  button.label = label
  return button
end

function c:new_exit_button(x, y, w, h, name, label)
  local button = self:new_element("exit_button")
  button:set_position(x, y)
  button:set_size(w, h)
  button.name = name
  button.label = label
  return button
end

function c:new_exit_image_button(x, y, w, h, texture_name, name, label)
  local button = self:new_element("exit_image_button")
  button:set_position(x, y)
  button:set_size(w, h)
  button.texture_name = texture_name
  button.name = name
  button.label = label
  return button
end

function c:new_text_list(x, y, w, h, name, items, selected_index, transparent)
  local text_list = self:new_element("text_list")
  text_list:set_position(x, y)
  text_list:set_size(w, h)
  text_list.name = name
  text_list.items = items
  text_list.selected_index = selected_index
  text_list.transparent = transparent
  return text_list
end

function c:new_tab_header(x, y, name, captions, current_tab, transparent, draw_border)
  local tab_header = self:new_element("tab_header")
  tab_header:set_position(x, y)
  tab_header.name = name
  tab_header.captions = captions
  tab_header.current_tab = current_tab
  tab_header.transparent = transparent
  tab_header.draw_border = draw_border
  return tab_header
end

function c:new_box(x, y, w, h, color)
  local box = self:new_element("box")
  box:set_position(x, y)
  box:set_size(w, h)
  box.color = color
  return box
end

function c:new_dropdown(x, y, w, name, items, selected_index)
  local dropdown = self:new_element("dropdown")
  dropdown:set_position(x, y)
  dropdown:set_size(w, 1)
  dropdown.name = name
  dropdown.items = items
  dropdown.selected_index = selected_index
  return dropdown
end

function c:new_checkbox(x, y, name, label, selected)
  local checkbox = self:new_element("checkbox")
  checkbox:set_position(x, y)
  checkbox.name = name
  checkbox.label = label
  checkbox.selected = selected
  return checkbox
end

function c:new_scrollbar(x, y, w, h, orientation, name, value)
  local scrollbar = self:new_element("scrollbar")
  scrollbar:set_position(x, y)
  scrollbar:set_size(w, h)
  scrollbar.orientation = orientation
  scrollbar.name = name
  scrollbar.value = value
  return scrollbar
end

function c:new_table(x, y, w, h, name, cells, selected_index)
  local t = self:new_element("table")
  t:set_position(x, y)
  t:set_size(w, h)
  t.name = name
  t.cells = cells
  t.selected_index = selected_index
  return t
end

function c:new_table_options(options)
  local t = self:new_element("table_options")
  t.table_options = options
  return t
end

function c:new_table_columns(columns)
  local t = self:new_element("table_columns")
  t.table_columns = columns
  return t
end

function c:to_formspec(as_iodata)
  local result = {}
  if self.kind == "form" then
    -- size
    table.insert(result, {"size[", tostring(self.size.w), ",", tostring(self.size.h)})
    if self.size.fixed_size ~= nil then
      table.insert(result, {",", tostring(self.size.fixed_size)})
    end
    table.insert(result, "]")
    -- position
    table.insert(result, {"position[", tostring(self.position.x), ",", tostring(self.position.y), "]"})
    -- anchor
    table.insert(result, {"anchor[", tostring(self.anchor.x), ",", tostring(self.anchor.y), "]"})
    if self.no_prepend then
      table.insert(result, "no_prepend[]")
    end
  elseif self.kind == "container" then
    table.insert(result, {"container[", tostring(self.position.x), ",", tostring(self.position.y), "]"})
  elseif self.kind == "list" then
    table.insert(result, {
      "list[",
      tostring(self.inventory_location),";",
      tostring(self.list_name),";",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
    })
    if self.starting_item_index then
      table.insert(result, tostring(self.starting_item_index))
    end
    table.insert(result, "]")
  elseif self.kind == "list_ring" then
    if self.inventory_location then
      table.insert(result, {
        "listring[",
        tostring(self.inventory_location),";",
        tostring(self.list_name),
        "]",
      })
    else
      table.insert(result, "listring[]")
    end
  elseif self.kind == "list_colors" then
    table.insert(result, {
      "listcolors[",
      tostring(self.slot_colors.normal),";",
      tostring(self.slot_colors.hover),
    })
    if self.slot_colors.border then
      table.insert(result, {";", tostring(self.slot_colors.border)})
    end
    if self.tooltip_colors.background then
      table.insert(result, {";", tostring(self.tooltip_colors.background)})
    end
    if self.tooltip_colors.font then
      table.insert(result, {";", tostring(self.tooltip_colors.font)})
    end
    table.insert(result, "]")
  elseif self.kind == "element_tooltip" then
    table.insert(result, {
      "tooltip[",
      tostring(self.element_name),";",
      tostring(self.text),";",
      tostring(self.colors.background),";",
      tostring(self.colors.font),
      "]",
    })
  elseif self.kind == "tooltip" then
    table.insert(result, {
      "tooltip[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.text),";",
      tostring(self.colors.background),";",
      tostring(self.colors.font),
      "]",
    })
  elseif self.kind == "image" then
    table.insert(result, {
      "image[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.texture_name),
      "]",
    })
  elseif self.kind == "item_image" then
    table.insert(result, {
      "item_image[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.item_name),
      "]",
    })
  elseif self.kind == "background" then
    table.insert(result, {
      "background[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.texture_name),
    })
    if self.auto_clip ~= nil then
      table.insert(result, {";", tostring(self.auto_clip)})
    end
    table.insert(result, "]")
  elseif self.kind == "password_field" then
    table.insert(result, {
      "pwdfield[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.name),";",
      tostring(self.label),
      "]",
    })
  elseif self.kind == "positioned_text_field" then
    table.insert(result, {
      "field[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.name),";",
      tostring(self.label),";",
      tostring(self.default),
      "]",
    })
  elseif self.kind == "text_field" then
    table.insert(result, {
      "field[",
      tostring(self.name),";",
      tostring(self.label),";",
      tostring(self.default),
      "]",
    })
  elseif self.kind == "field_close_on_enter" then
    table.insert(result, {
      "field_close_on_enter[",
      tostring(self.name),";",
      tostring(self.close_on_enter),
      "]",
    })
  elseif self.kind == "textarea" then
    table.insert(result, {
      "textarea[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.name),";",
      tostring(self.label),";",
      tostring(self.default),
      "]",
    })
  elseif self.kind == "label" then
    table.insert(result, {
      "label[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.label),
      "]",
    })
  elseif self.kind == "vertical_label" then
    table.insert(result, {
      "vertlabel[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.label),
      "]",
    })
  elseif self.kind == "button" then
    table.insert(result, {
      "button[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.name),";",
      tostring(self.label),
      "]",
    })
  elseif self.kind == "image_button" then
    table.insert(result, {
      "image_button[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.texture_name),";",
      tostring(self.name),";",
      tostring(self.label),
    })

    if self.pressed_texture_name then
      table.insert(result, {
        tostring(self.no_clip),";",
        tostring(self.draw_border),";",
        tostring(self.pressed_texture_name),
      })
    end

    table.insert(result, "]")
  elseif self.kind == "item_image_button" then
    table.insert(result, {
      "item_image_button[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.item_name),";",
      tostring(self.name),";",
      tostring(self.label),
      "]",
    })
  elseif self.kind == "exit_button" then
    table.insert(result, {
      "button_exit[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.name),";",
      tostring(self.label),
      "]",
    })
  elseif self.kind == "exit_image_button" then
    table.insert(result, {
      "image_button_exit[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.texture_name),";",
      tostring(self.name),";",
      tostring(self.label),
      "]",
    })
  elseif self.kind == "text_list" then
    table.insert(result, {
      "textlist[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.name),";",
    })
    local count = #self.items
    for index,item in ipairs(self.items) do
      local is_last = count == index
      if type(item) == "table" then
        if #item == 2 then
          table.insert(result, {item[1], item[2]})
        else
          if item.color then
            table.insert(result, {"#", item.color, item.text})
          else
            if string_starts_with(item.text, "#") then
              table.insert(result, {"#", escaped})
            else
              table.insert(result, escaped)
            end
          end
        end
      else
        item = tostring(item)
        if string_starts_with(item, "#") then
          table.insert(result, {"#", item})
        else
          table.insert(result, item)
        end
      end
      if not is_last then
        table.insert(result, ",")
      end
    end
    if self.selected_index then
      table.insert(result, {
        ";", tostring(self.selected_index),
        ";", tostring(self.transparent)
      })
    end
    table.insert(result, "]")
  elseif self.kind == "tab_header" then
    table.insert(result, {
      "tabheader[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.name),";",
    })
    local count = #self.captions
    for index,caption in ipairs(self.captions) do
      local is_last = count == index
      table.insert(result, tostring(caption))
      if not is_last then
        table.insert(result, ",")
      end
    end
    table.insert(result, {
      ";", tostring(self.current_tab),
    })
    if self.draw_border ~= nil then
      table.insert(result, {
        ";", tostring(self.transparent),
        ";", tostring(self.draw_border),
      })
    elseif self.transparent ~= nil then
      table.insert(result, {
        ";", tostring(self.transparent),
      })
    end
    table.insert(result, "]")
  elseif self.kind == "box" then
    table.insert(result, {
      "box[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.color),
      "]"
    })
  elseif self.kind == "dropdown" then
    table.insert(result, {
      "dropdown[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),";",
      tostring(self.name),";",
    })
    if self.selected_index then
      table.insert(result, {";", tostring(self.selected_index)})
    end
    table.insert(result, "]")
  elseif self.kind == "checkbox" then
    table.insert(result, {
      "checkbox[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.name),";",
      tostring(self.label),
    })
    if self.selected ~= nil then
      table.insert(result, {";", tostring(self.selected)})
    end
    table.insert(result, "]")
  elseif self.kind == "scrollbar" then
    table.insert(result, {
      "scrollbar[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.orientation),";",
      tostring(self.name),";",
      tostring(self.value),
      "]"
    })
  elseif self.kind == "table" then
    table.insert(result, {
      "table[",
      tostring(self.position.x),",",
      tostring(self.position.y),";",
      tostring(self.size.w),",",
      tostring(self.size.h),";",
      tostring(self.name),";",
    })
    local count = #self.cells
    for index,cell in ipairs(self.cells) do
      local is_last = count == index
      table.insert(result, tostring(cell))
      if not is_last then
        table.insert(result, ",")
      end
    end
    table.insert(result, {";", tostring(self.selected_index)})
    table.insert(result, "]")
  elseif self.kind == "table_options" then
    table.insert(result, "tableoptions[")
    local options = {}
    for key,value in pairs(self.table_options) do
      table.insert(options, {tostring(key), "=", tostring(value)})
    end
    options = table_intersperse(options, ";")
    table.insert(result, options)
    table.insert(result, "]")
  elseif self.kind == "table_columns" then
    table.insert(result, "tablecolumns[")
    local columns = {}
    for _,column in ipairs(self.table_columns) do
      local column_type = column[1]
      local column_options = column[2]
      local options = {}
      for key,value in pairs(column_options) do
        table.insert(options, {tostring(key), "=", tostring(value)})
      end
      options = table_intersperse(options, ",")
      if #options > 0 then
        table.insert(columns, {column_type, ",", options})
      else
        table.insert(columns, column_type)
      end
    end
    columns = table_intersperse(options, ";")
    table.insert(result, columns)
    table.insert(result, "]")
  end

  if self.use_background_color then
    table.insert(result, {
      "bgcolor[",
      tostring(self.background.color),";",
      tostring(fullscreen_background),
      "]",
    })
  end

  for _,element in ipairs(self.elements) do
    table.insert(result, element:to_formspec(true))
  end

  if self.kind == "container" then
    table.insert(result, "container_end[]")
  end

  if as_iodata then
    return result
  else
    return iodata_to_string(result)
  end
end

yatm_core.UI = {
  Form = Form
}
