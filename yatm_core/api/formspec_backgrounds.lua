--
-- All of YATM's standard formspec backgrounds
--
local fspec = assert(foundation.com.formspec.api)
local Rect = assert(foundation.com.Rect)

-- @namespace yatm

yatm.bg_name = {}
yatm.bg9_name = {}

yatm.bg_base =
  "no_prepend[]" ..
  "bgcolor[#080808BB;true]" ..
  "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]"

yatm.bg_name.default = "yatm_gui_formbg_default.png"
yatm.bg_name.computer = "yatm_gui_formbg_default.computer.png"
yatm.bg_name.data = "yatm_gui_formbg_default.data.png"
yatm.bg_name.codex = "yatm_gui_formbg_codex.png"
yatm.bg_name.display = "yatm_gui_formbg_display.data.png"
yatm.bg_name.machine = "yatm_gui_formbg_machine.png"
yatm.bg_name.machine_heated = "yatm_gui_formbg_machine.heated.png"
yatm.bg_name.machine_cooled = "yatm_gui_formbg_machine.cooled.png"
yatm.bg_name.machine_radioactive = "yatm_gui_formbg_machine.radioactive.png"
yatm.bg_name.machine_chemical = "yatm_gui_formbg_machine.chemical.png"
yatm.bg_name.module = "yatm_gui_formbg_module.data.png"
yatm.bg_name.other = "yatm_gui_formbg_other.png"
yatm.bg_name.wood = "yatm_gui_formbg_wood.png"
yatm.bg_name.cardboard = "yatm_gui_formbg_cardboard.png"
yatm.bg_name.dscs = "yatm_gui_formbg_dscs.png"
yatm.bg_name.inventory = "yatm_gui_formbg_inventory.png"

yatm.bg9_name.default = "yatm_gui_formbg_default.9s.png"
yatm.bg9_name.computer = "yatm_gui_formbg_default.computer.9s.png"
yatm.bg9_name.data = "yatm_gui_formbg_default.data.9s.png"
yatm.bg9_name.codex = "yatm_gui_formbg_codex.9s.png"
yatm.bg9_name.display = "yatm_gui_formbg_display.data.9s.png"
yatm.bg9_name.machine = "yatm_gui_formbg_machine.9s.png"
yatm.bg9_name.machine_heated = "yatm_gui_formbg_machine.heated.9s.png"
yatm.bg9_name.machine_cooled = "yatm_gui_formbg_machine.cooled.9s.png"
yatm.bg9_name.machine_radioactive = "yatm_gui_formbg_machine.radioactive.9s.png"
yatm.bg9_name.machine_chemical = "yatm_gui_formbg_machine.chemical.9s.png"
yatm.bg9_name.module = "yatm_gui_formbg_module.data.9s.png"
yatm.bg9_name.other = "yatm_gui_formbg_other.9s.png"
yatm.bg9_name.wood = "yatm_gui_formbg_wood.9s.png"
yatm.bg9_name.cardboard = "yatm_gui_formbg_cardboard.9s.png"
yatm.bg9_name.dscs = "yatm_gui_formbg_dscs.9s.png"
yatm.bg9_name.inventory = "yatm_gui_formbg_inventory.9s.png"

-- @spec formspec_bg_for_player(
--   player_name: String,
--   background_id: String,
--   x?: Number,
--   y?: Number,
--   w?: Number,
--   h?: Number,
--   auto_clip?: Boolean
-- ): String
function yatm.formspec_bg_for_player(player_name, background_id, x, y, w, h, auto_clip)
  assert(type(player_name) == "string", "expected player_name as string")

  x = x or 0
  y = y or 0
  w = w or 1
  h = h or 1

  if auto_clip == nil then
    auto_clip = false
  end

  local info = minetest.get_player_information(player_name)
  local texture_name

  if info.formspec_version then
    if info.formspec_version >= 2 then
      texture_name = yatm.bg9_name[background_id]
      return fspec.background9(x, y, w, h, texture_name, auto_clip, 32)
    end
  end

  texture_name = yatm.bg_name[background_id]
  return fspec.background(x, y, w, h, texture_name, auto_clip)
end

-- @spec formspec_render_split_inv_panel(
--   Player,
--   main_cols: Integer,
--   main_rows: Integer,
--   options: Table,
--   callback: function (slot: String, rect: Rect) => String
-- ): String
function yatm.formspec_render_split_inv_panel(player, main_cols, main_rows, options, callback)
  assert(player, "expected player")
  assert(type(main_cols) == "number", "expected a column count")
  assert(type(main_rows) == "number", "expected a row count")

  options = options or {}

  local device_bg = options.bg or "default"

  local inv_size = yatm.player_inventory_size2(player)

  -- device form size
  local dform_size = fspec.calc_form_inventory_size(main_cols, main_rows)
  -- player form size
  local pform_size = fspec.calc_form_inventory_size(inv_size.x, inv_size.y)

  local padding = 0.5 -- from one edge

  local dev_form_w = dform_size.x + padding * 2
  local dev_form_h = dform_size.y + padding * 2

  local player_form_w = pform_size.x + padding * 2
  local player_form_h = pform_size.y + padding * 2

  local w = math.max(dev_form_w, player_form_w)
  local h = dev_form_h + player_form_h

  local device_rect = Rect.new((w - dform_size.x) / 2, padding, dform_size.x, dform_size.y)
  local inv_rect = Rect.new((w - pform_size.x) / 2, dev_form_h + padding, pform_size.x, pform_size.y)
  local full_rect = Rect.new(padding, padding, w - padding * 2, h - padding * 2)

  local formspec =
    fspec.formspec_version(4) ..
    callback("before_size", full_rect) ..
    fspec.size(w, h) ..
    callback("header", full_rect) ..
    yatm.formspec_bg_for_player(player:get_player_name(), device_bg, 0, 0, w, dev_form_h) ..
    callback("main_body", device_rect) ..
    yatm.formspec_bg_for_player(player:get_player_name(), "inventory", 0, dev_form_h, w, player_form_h) ..
    yatm.player_inventory_lists_fragment(player, inv_rect.x, inv_rect.y)
    callback("footer", full_rect)

  return formspec
end
