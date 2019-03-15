local Form = yatm_core.UI.Form
local Luna = assert(yatm_core.Luna)

local case = Luna:new("yatm_core.UI.Form")

case:describe("to_formspec/0 - form", function (t2)
  t2:test("can convert a form to a formspec string", function (t3)
    local form = Form:new()
    local formspec = form:to_formspec()
    print(dump(formspec))
    t3:assert(formspec)
  end)
end)

case:describe("to_formspec/0 - container", function (t2)
  t2:test("can convert a container to a formspec string", function (t3)
    local form = Form:new()
    local container = form:new_container()
    local formspec = container:to_formspec()
    print(dump(formspec))
    t3:assert(formspec)
  end)
end)

case:describe("to_formspec/0 - list", function (t2)
  -- body
end)

case:describe("to_formspec/0 - list_ring", function (t2)
end)

case:describe("to_formspec/0 - list_colors", function (t2)
end)

case:describe("to_formspec/0 - element_tooltip", function (t2)
end)

case:describe("to_formspec/0 - tooltip", function (t2)
end)

case:describe("to_formspec/0 - image", function (t2)
end)

case:describe("to_formspec/0 - item_image", function (t2)
end)

case:describe("to_formspec/0 - background", function (t2)
end)

case:describe("to_formspec/0 - password_field", function (t2)
end)

case:describe("to_formspec/0 - positioned_text_field", function (t2)
end)

case:describe("to_formspec/0 - text_field", function (t2)
end)

case:describe("to_formspec/0 - field_close_on_enter", function (t2)
end)

case:describe("to_formspec/0 - textarea", function (t2)
end)

case:describe("to_formspec/0 - label", function (t2)
end)

case:describe("to_formspec/0 - vertical_label", function (t2)
end)

case:describe("to_formspec/0 - button", function (t2)
end)

case:describe("to_formspec/0 - image_button", function (t2)
end)

case:describe("to_formspec/0 - item_image_button", function (t2)
end)

case:describe("to_formspec/0 - exit_button", function (t2)
end)

case:describe("to_formspec/0 - exit_image_button", function (t2)
end)

case:describe("to_formspec/0 - text_list", function (t2)
end)

case:describe("to_formspec/0 - tab_header", function (t2)
end)

case:describe("to_formspec/0 - box", function (t2)
end)

case:describe("to_formspec/0 - dropdown", function (t2)
end)

case:describe("to_formspec/0 - scrollbar", function (t2)
end)

case:describe("to_formspec/0 - table", function (t2)
end)

case:describe("to_formspec/0 - table_options", function (t2)
end)

case:describe("to_formspec/0 - table_columns", function (t2)
end)

case:execute()
case:display_stats()
case:maybe_error()
